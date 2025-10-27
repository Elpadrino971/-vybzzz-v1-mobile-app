import { NextRequest, NextResponse } from 'next/server'
import Stripe from 'stripe'
import { createServerClient } from '@/lib/supabase/server'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2023-10-16',
})

const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!

export async function POST(req: NextRequest) {
  try {
    const body = await req.text()
    const sig = req.headers.get('stripe-signature')!

    let event: Stripe.Event

    try {
      event = stripe.webhooks.constructEvent(body, sig, webhookSecret)
    } catch (err: any) {
      console.error('Webhook signature verification failed:', err.message)
      return NextResponse.json({ error: err.message }, { status: 400 })
    }

    const supabase = createServerClient()

    // Handle the event
    switch (event.type) {
      case 'payment_intent.succeeded': {
        const paymentIntent = event.data.object as Stripe.PaymentIntent
        const { event_id, user_id, type } = paymentIntent.metadata

        if (type === 'ticket_purchase') {
          // Confirmer le ticket
          await supabase
            .from('tickets')
            .update({ status: 'valid' })
            .eq('event_id', event_id)
            .eq('user_id', user_id)

          // Enregistrer la transaction
          await supabase.from('transactions').insert({
            user_id,
            transaction_type: 'ticket_sale',
            amount: paymentIntent.amount / 100,
            platform_fee: (paymentIntent.application_fee_amount || 0) / 100,
            net_amount: (paymentIntent.amount - (paymentIntent.application_fee_amount || 0)) / 100,
            stripe_transaction_id: paymentIntent.id,
            related_entity_id: event_id,
            status: 'completed',
          })
        } else if (type === 'tip') {
          // Enregistrer le pourboire
          await supabase.from('tips').update({
            status: 'completed',
          }).eq('stripe_payment_intent_id', paymentIntent.id)
        }
        break
      }

      case 'payment_intent.payment_failed': {
        const paymentIntent = event.data.object as Stripe.PaymentIntent
        const { event_id, user_id } = paymentIntent.metadata

        // Annuler le ticket
        await supabase
          .from('tickets')
          .update({ status: 'cancelled' })
          .eq('event_id', event_id)
          .eq('user_id', user_id)

        // Décrémenter tickets_sold
        await supabase.rpc('decrement_tickets_sold', { event_id })
        break
      }

      default:
        console.log(`Unhandled event type ${event.type}`)
    }

    return NextResponse.json({ received: true })
  } catch (error: any) {
    console.error('Webhook error:', error)
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}
