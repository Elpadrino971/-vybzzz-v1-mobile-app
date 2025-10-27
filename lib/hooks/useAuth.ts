'use client'

import { useEffect, useState } from 'react'
import { User } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase/client'

interface Profile {
  id: string
  username: string
  full_name: string | null
  avatar_url: string | null
  bio: string | null
  user_type: 'fan' | 'artist'
  stripe_account_id: string | null
  stripe_customer_id: string | null
}

export function useAuth() {
  const [user, setUser] = useState<(User & { profile?: Profile }) | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Récupérer l'utilisateur actuel
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (user) {
        // Récupérer le profil
        supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single()
          .then(({ data: profile }) => {
            setUser({ ...user, profile: profile || undefined })
            setLoading(false)
          })
      } else {
        setLoading(false)
      }
    })

    // Écouter les changements d'authentification
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(async (event, session) => {
      if (session?.user) {
        const { data: profile } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', session.user.id)
          .single()

        setUser({ ...session.user, profile: profile || undefined })
      } else {
        setUser(null)
      }
      setLoading(false)
    })

    return () => {
      subscription.unsubscribe()
    }
  }, [])

  const signOut = async () => {
    await supabase.auth.signOut()
    setUser(null)
  }

  const isArtist = user?.profile?.user_type === 'artist'
  const isFan = user?.profile?.user_type === 'fan'

  return {
    user,
    loading,
    signOut,
    isArtist,
    isFan,
  }
}
