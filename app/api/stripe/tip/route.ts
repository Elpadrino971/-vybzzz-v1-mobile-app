import { NextRequest, NextResponse } from 'next/server'
import Stripe from 'stripe'
import { createServerClient } from '@/lib/supabase/server'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2023-10-16',
})

export async function POST(req: NextRequest) {
  try {
    const { artistId, amount, message, eventId, userId } = await req.json()
    const supabase = createServerClient()

    // Récupérer l'artiste
    const { data: artist } = await supabase
      .from('artists')
      .select('*, profile:profiles(*)')
      .eq('id', artistId)
      .single()

    if (!artist || !artist.profile.stripe_account_id) {
      return NextResponse.json({ error: 'Artist not found' }, { status: 404 })
    }

    // Créer un Payment Intent direct vers l'artiste
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100),
      currency: 'eur',
      application_fee_amount: Math.round(amount * 0.05 * 100), // 5% frais plateforme
      transfer_data: {
        destination: artist.profile.stripe_account_id,
      },
      metadata: {
        type: 'tip',
        artist_id: artistId,
        event_id: eventId,
        user_id: userId,
      },
    })

    // Enregistrer le tip
    await supabase.from('tips').insert({
      from_user_id: userId,
      to_artist_id: artistId,
      event_id: eventId,
      amount,
      message,
      stripe_payment_intent_id: paymentIntent.id,
    })

    return NextResponse.json({ clientSecret: paymentIntent.client_secret })
  } catch (error: any) {
    console.error('Tip error:', error)
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}
