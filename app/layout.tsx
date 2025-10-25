import './globals.css'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'VyBzzZ - Concerts Live avec Paiement Immédiat',
  description: 'La première plateforme qui paie les artistes instantanément après leur concert. Fini l\'attente de 7-30 jours.',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr">
      <body className={inter.className}>{children}</body>
    </html>
  )
}
