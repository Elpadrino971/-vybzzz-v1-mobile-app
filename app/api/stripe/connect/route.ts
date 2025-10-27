import { NextRequest, NextResponse } from 'next/server'
import Stripe from 'stripe'
import { createServerClient } from '@/lib/supabase/server'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2023-10-16',
})

export async function POST(req: NextRequest) {
  try {
    const { userId, email } = await req.json()
    const supabase = createServerClient()

    // Vérifier que l'utilisateur est un artiste
    const { data: profile } = await supabase
      .from('profiles')
      .select('user_type')
      .eq('id', userId)
      .single()

    if (profile?.user_type !== 'artist') {
      return NextResponse.json({ error: 'Not an artist' }, { status: 403 })
    }

    // Créer un compte Stripe Connect
    const account = await stripe.accounts.create({
      type: 'express',
      country: 'FR',
      email,
      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true },
      },
    })

    // Mettre à jour le profil
    await supabase
      .from('profiles')
      .update({ stripe_account_id: account.id })
      .eq('id', userId)

    // Créer un lien d'onboarding
    const accountLink = await stripe.accountLinks.create({
      account: account.id,
      refresh_url: `${process.env.NEXT_PUBLIC_APP_URL}/artist/dashboard`,
      return_url: `${process.env.NEXT_PUBLIC_APP_URL}/artist/dashboard`,
      type: 'account_onboarding',
    })

    return NextResponse.json({ url: accountLink.url })
  } catch (error: any) {
    console.error('Stripe Connect error:', error)
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}
