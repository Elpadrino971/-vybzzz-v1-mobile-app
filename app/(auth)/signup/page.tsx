'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Logo } from '@/components/ui/Logo'
import { supabase } from '@/lib/supabase/client'
import Link from 'next/link'
import { useRouter, useSearchParams } from 'next/navigation'
import { Mail, Lock, User } from 'lucide-react'

export default function SignupPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const typeParam = searchParams.get('type') || 'fan'

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [username, setUsername] = useState('')
  const [fullName, setFullName] = useState('')
  const [userType, setUserType] = useState<'fan' | 'artist'>(typeParam as 'fan' | 'artist')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    // 1. Créer l'utilisateur
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          username,
          full_name: fullName,
          user_type: userType,
        },
      },
    })

    if (authError) {
      setError(authError.message)
      setLoading(false)
      return
    }

    // 2. Créer le profil
    const { error: profileError } = await supabase
      .from('profiles')
      .insert({
        id: authData.user!.id,
        username,
        full_name: fullName,
        user_type: userType,
      })

    if (profileError) {
      setError(profileError.message)
      setLoading(false)
      return
    }

    // 3. Si artiste, créer l'entrée artist
    if (userType === 'artist') {
      await supabase.from('artists').insert({
        id: authData.user!.id,
        stage_name: fullName,
      })
    }

    // 4. Rediriger
    if (userType === 'artist') {
      router.push('/artist/dashboard')
    } else {
      router.push('/dashboard')
    }
  }

  const handleGoogleSignup = async () => {
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback?type=${userType}`,
      },
    })

    if (error) {
      setError(error.message)
    }
  }

  return (
    <div className="min-h-screen bg-vybzzz-dark flex items-center justify-center p-4">
      <div className="max-w-md w-full">
        <div className="text-center mb-8">
          <Logo />
          <h1 className="text-3xl font-bold mt-4 mb-2">Rejoins VyBzzZ</h1>
          <p className="text-gray-400">Crée ton compte en quelques secondes</p>
        </div>

        <div className="bg-gray-900 rounded-xl p-8 border border-gray-800">
          {/* Type de compte */}
          <div className="flex gap-4 mb-6">
            <button
              onClick={() => setUserType('fan')}
              className={`flex-1 p-4 rounded-lg border-2 transition-all ${
                userType === 'fan'
                  ? 'border-vybzzz-purple bg-vybzzz-purple/10'
                  : 'border-gray-700 hover:border-gray-600'
              }`}
            >
              <p className="font-bold mb-1">Fan</p>
              <p className="text-sm text-gray-400">Découvre des concerts</p>
            </button>
            <button
              onClick={() => setUserType('artist')}
              className={`flex-1 p-4 rounded-lg border-2 transition-all ${
                userType === 'artist'
                  ? 'border-vybzzz-purple bg-vybzzz-purple/10'
                  : 'border-gray-700 hover:border-gray-600'
              }`}
            >
              <p className="font-bold mb-1">Artiste</p>
              <p className="text-sm text-gray-400">Crée tes concerts</p>
            </button>
          </div>

          <form onSubmit={handleSignup} className="space-y-6">
            {error && (
              <div className="p-3 bg-red-500/10 border border-red-500 rounded-lg text-red-500 text-sm">
                {error}
              </div>
            )}

            <Input
              label="Nom d'utilisateur"
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder="@tonpseudo"
              icon={<User className="w-5 h-5" />}
              required
            />

            <Input
              label="Nom complet"
              type="text"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              placeholder="Jean Dupont"
              icon={<User className="w-5 h-5" />}
              required
            />

            <Input
              label="Email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="ton@email.com"
              icon={<Mail className="w-5 h-5" />}
              required
            />

            <Input
              label="Mot de passe"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              icon={<Lock className="w-5 h-5" />}
              required
            />

            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? 'Création...' : 'Créer mon compte'}
            </Button>
          </form>

          <div className="mt-6">
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-700"></div>
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-gray-900 text-gray-400">Ou</span>
              </div>
            </div>

            <Button
              variant="outline"
              className="w-full mt-4"
              onClick={handleGoogleSignup}
            >
              <svg className="w-5 h-5 mr-2" viewBox="0 0 24 24">
                <path
                  fill="currentColor"
                  d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                />
                <path
                  fill="currentColor"
                  d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                />
                <path
                  fill="currentColor"
                  d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                />
                <path
                  fill="currentColor"
                  d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                />
              </svg>
              Continuer avec Google
            </Button>
          </div>

          <p className="text-center text-gray-400 text-sm mt-6">
            Déjà un compte ?{' '}
            <Link href="/login" className="text-vybzzz-purple hover:text-vybzzz-orange transition-colors">
              Connecte-toi
            </Link>
          </p>
        </div>
      </div>
    </div>
  )
}
