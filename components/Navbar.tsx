'use client'

import { Logo } from '@/components/ui/Logo'
import { Button } from '@/components/ui/Button'
import { useAuth } from '@/lib/hooks/useAuth'
import Link from 'next/link'
import { User, LogOut } from 'lucide-react'

export function Navbar() {
  const { user, loading, signOut } = useAuth()

  return (
    <nav className="fixed top-0 w-full z-50 bg-vybzzz-dark/80 backdrop-blur-lg border-b border-gray-800">
      <div className="max-w-7xl mx-auto px-4 py-4 flex items-center justify-between">
        <Logo />

        <div className="flex items-center gap-4">
          {loading ? (
            <div className="w-8 h-8 border-2 border-vybzzz-purple border-t-transparent rounded-full animate-spin" />
          ) : user ? (
            <>
              <Link href={user.profile?.user_type === 'artist' ? '/artist/dashboard' : '/dashboard'}>
                <Button variant="ghost" className="gap-2">
                  <User className="w-5 h-5" />
                  {user.profile?.username || 'Mon compte'}
                </Button>
              </Link>
              <Button variant="ghost" onClick={signOut} className="gap-2">
                <LogOut className="w-5 h-5" />
                Déconnexion
              </Button>
            </>
          ) : (
            <>
              <Link href="/login">
                <Button variant="ghost">Connexion</Button>
              </Link>
              <Link href="/signup">
                <Button>Commencer</Button>
              </Link>
            </>
          )}
        </div>
      </div>
    </nav>
  )
}
