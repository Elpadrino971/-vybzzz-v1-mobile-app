import { NextRequest, NextResponse } from 'next/server'
import Stripe from 'stripe'
import { createServerClient } from '@/lib/supabase/server'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2023-10-16',
})

export async function POST(req: NextRequest) {
  try {
    const { eventId, userId } = await req.json()
    const supabase = createServerClient()

    // 1. Récupérer l'événement
    const { data: event, error: eventError } = await supabase
      .from('events')
      .select('*, artist:artists(*)')
      .eq('id', eventId)
      .single()

    if (eventError || !event) {
      return NextResponse.json({ error: 'Event not found' }, { status: 404 })
    }

    // 2. Vérifier la disponibilité
    if (event.tickets_sold >= event.ticket_quantity) {
      return NextResponse.json({ error: 'Sold out' }, { status: 400 })
    }

    // 3. Calculer le prix
    const finalPrice = event.ticket_price

    // 4. Calculer les commissions
    const platformFee = finalPrice * 0.10 // 10% plateforme
    const artistAmount = finalPrice - platformFee

    // 5. Créer le Payment Intent avec Stripe Connect
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(finalPrice * 100), // en centimes
      currency: 'eur',
      application_fee_amount: Math.round(platformFee * 100),
      transfer_data: {
        destination: event.artist.stripe_account_id,
      },
      metadata: {
        event_id: eventId,
        user_id: userId,
        type: 'ticket_purchase',
      },
    })

    // 6. Créer le ticket (status pending)
    const { data: ticket } = await supabase
      .from('tickets')
      .insert({
        event_id: eventId,
        user_id: userId,
        ticket_type: event.event_type === 'physical' ? 'physical' : 'digital',
        qr_code: `${eventId}-${userId}-${Date.now()}`,
        price_paid: finalPrice,
        status: 'valid',
      })
      .select()
      .single()

    // 7. Incrémenter tickets_sold
    await supabase
      .from('events')
      .update({ tickets_sold: event.tickets_sold + 1 })
      .eq('id', eventId)

    return NextResponse.json({
      clientSecret: paymentIntent.client_secret,
      ticket,
    })
  } catch (error: any) {
    console.error('Stripe checkout error:', error)
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}
