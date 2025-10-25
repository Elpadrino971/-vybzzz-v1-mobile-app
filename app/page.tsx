'use client'

import { Button } from '@/components/ui/Button'
import { Logo } from '@/components/ui/Logo'
import Link from 'next/link'
import {
  Zap,
  DollarSign,
  Video,
  MessageCircle,
  Users,
  TrendingUp,
  Check,
  ArrowRight,
  Play
} from 'lucide-react'

export default function HomePage() {
  return (
    <div className="min-h-screen bg-vybzzz-dark text-white">
      {/* Navbar */}
      <nav className="fixed top-0 w-full z-50 bg-vybzzz-dark/80 backdrop-blur-lg border-b border-gray-800">
        <div className="max-w-7xl mx-auto px-4 py-4 flex items-center justify-between">
          <Logo />
          <div className="flex items-center gap-4">
            <Link href="/login">
              <Button variant="ghost">Connexion</Button>
            </Link>
            <Link href="/signup">
              <Button>Commencer</Button>
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="pt-32 pb-20 px-4">
        <div className="max-w-7xl mx-auto text-center">
          <div className="inline-block mb-6 px-4 py-2 bg-vybzzz-purple/20 border border-vybzzz-purple/50 rounded-full">
            <span className="text-sm font-medium">⚡ Transfert immédiat des recettes</span>
          </div>

          <h1 className="text-6xl md:text-7xl font-bold mb-6 leading-tight">
            Concerts Live.<br />
            <span className="gradient-text">Paiement Immédiat.</span>
          </h1>

          <p className="text-xl text-gray-400 mb-8 max-w-2xl mx-auto">
            La première plateforme qui paie les artistes <strong className="text-white">instantanément</strong> après leur concert.
            Fini l&apos;attente de 7-30 jours.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-12">
            <Link href="/signup?type=artist">
              <Button size="lg" className="gap-2">
                Je suis artiste
                <ArrowRight className="w-5 h-5" />
              </Button>
            </Link>
            <Link href="/signup?type=fan">
              <Button size="lg" variant="outline" className="gap-2">
                <Play className="w-5 h-5" />
                Je suis fan
              </Button>
            </Link>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-3 gap-8 max-w-3xl mx-auto">
            <div>
              <p className="text-4xl font-bold text-vybzzz-orange mb-2">300+</p>
              <p className="text-gray-400">Artistes</p>
            </div>
            <div>
              <p className="text-4xl font-bold text-vybzzz-orange mb-2">600+</p>
              <p className="text-gray-400">Fans</p>
            </div>
            <div>
              <p className="text-4xl font-bold text-vybzzz-orange mb-2">10%</p>
              <p className="text-gray-400">Commission</p>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 px-4 bg-gradient-to-b from-vybzzz-dark to-vybzzz-purple/10">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4">Pourquoi VyBzzZ ?</h2>
            <p className="text-xl text-gray-400">La révolution du concert live</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {/* Feature 1 */}
            <div className="p-8 bg-vybzzz-dark border border-gray-800 rounded-xl hover:border-vybzzz-purple transition-all">
              <div className="w-12 h-12 bg-vybzzz-purple/20 rounded-lg flex items-center justify-center mb-4">
                <Zap className="w-6 h-6 text-vybzzz-purple" />
              </div>
              <h3 className="text-xl font-bold mb-2">Transfert Immédiat</h3>
              <p className="text-gray-400">
                Reçois ton argent <strong className="text-white">instantanément</strong> après le concert.
                Pas d&apos;attente de 7-30 jours comme chez les concurrents.
              </p>
            </div>

            {/* Feature 2 */}
            <div className="p-8 bg-vybzzz-dark border border-gray-800 rounded-xl hover:border-vybzzz-purple transition-all">
              <div className="w-12 h-12 bg-vybzzz-orange/20 rounded-lg flex items-center justify-center mb-4">
                <DollarSign className="w-6 h-6 text-vybzzz-orange" />
              </div>
              <h3 className="text-xl font-bold mb-2">Commission 10%</h3>
              <p className="text-gray-400">
                La commission la plus basse du marché. Tu gardes <strong className="text-white">90%</strong> de tes revenus.
              </p>
            </div>

            {/* Feature 3 */}
            <div className="p-8 bg-vybzzz-dark border border-gray-800 rounded-xl hover:border-vybzzz-purple transition-all">
              <div className="w-12 h-12 bg-blue-500/20 rounded-lg flex items-center justify-center mb-4">
                <Video className="w-6 h-6 text-blue-500" />
              </div>
              <h3 className="text-xl font-bold mb-2">Streaming HD</h3>
              <p className="text-gray-400">
                Diffuse tes concerts en <strong className="text-white">haute qualité</strong> avec une latence minimale.
              </p>
            </div>

            {/* Feature 4 */}
            <div className="p-8 bg-vybzzz-dark border border-gray-800 rounded-xl hover:border-vybzzz-purple transition-all">
              <div className="w-12 h-12 bg-green-500/20 rounded-lg flex items-center justify-center mb-4">
                <MessageCircle className="w-6 h-6 text-green-500" />
              </div>
              <h3 className="text-xl font-bold mb-2">Chat Temps Réel</h3>
              <p className="text-gray-400">
                Interagis avec ton public pendant le live grâce au <strong className="text-white">chat en direct</strong>.
              </p>
            </div>

            {/* Feature 5 */}
            <div className="p-8 bg-vybzzz-dark border border-gray-800 rounded-xl hover:border-vybzzz-purple transition-all">
              <div className="w-12 h-12 bg-pink-500/20 rounded-lg flex items-center justify-center mb-4">
                <Users className="w-6 h-6 text-pink-500" />
              </div>
              <h3 className="text-xl font-bold mb-2">Pourboires</h3>
              <p className="text-gray-400">
                Tes fans peuvent t&apos;envoyer des <strong className="text-white">pourboires</strong> pendant le concert.
              </p>
            </div>

            {/* Feature 6 */}
            <div className="p-8 bg-vybzzz-dark border border-gray-800 rounded-xl hover:border-vybzzz-purple transition-all">
              <div className="w-12 h-12 bg-purple-500/20 rounded-lg flex items-center justify-center mb-4">
                <TrendingUp className="w-6 h-6 text-purple-500" />
              </div>
              <h3 className="text-xl font-bold mb-2">Analytics</h3>
              <p className="text-gray-400">
                Suis tes <strong className="text-white">stats en temps réel</strong> : viewers, revenus, engagement.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* How it works */}
      <section className="py-20 px-4">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4">Comment ça marche ?</h2>
            <p className="text-xl text-gray-400">Simple, rapide, efficace</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-12">
            {/* Step 1 */}
            <div className="text-center">
              <div className="w-16 h-16 bg-vybzzz-gradient rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-4">
                1
              </div>
              <h3 className="text-xl font-bold mb-2">Crée ton événement</h3>
              <p className="text-gray-400">
                Configure ton concert : date, prix, description. C&apos;est prêt en 2 minutes.
              </p>
            </div>

            {/* Step 2 */}
            <div className="text-center">
              <div className="w-16 h-16 bg-vybzzz-gradient rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-4">
                2
              </div>
              <h3 className="text-xl font-bold mb-2">Lance ton live</h3>
              <p className="text-gray-400">
                Diffuse ton concert en HD. Tes fans te regardent et interagissent en direct.
              </p>
            </div>

            {/* Step 3 */}
            <div className="text-center">
              <div className="w-16 h-16 bg-vybzzz-gradient rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-4">
                3
              </div>
              <h3 className="text-xl font-bold mb-2">Reçois ton argent</h3>
              <p className="text-gray-400">
                Dès la fin du concert, l&apos;argent est transféré sur ton compte. Instantanément.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Pricing */}
      <section className="py-20 px-4 bg-gradient-to-b from-vybzzz-dark to-vybzzz-purple/10">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4">Tarifs transparents</h2>
            <p className="text-xl text-gray-400">Pas de frais cachés</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto">
            {/* Pour les Fans */}
            <div className="p-8 bg-vybzzz-dark border border-gray-800 rounded-xl">
              <h3 className="text-2xl font-bold mb-4">Pour les Fans</h3>
              <div className="mb-6">
                <span className="text-5xl font-bold">Gratuit</span>
              </div>
              <ul className="space-y-3 mb-8">
                <li className="flex items-center gap-2">
                  <Check className="w-5 h-5 text-green-500" />
                  <span>Inscription gratuite</span>
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-5 h-5 text-green-500" />
                  <span>Accès à tous les concerts</span>
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-5 h-5 text-green-500" />
                  <span>Chat en direct</span>
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-5 h-5 text-green-500" />
                  <span>Streaming HD</span>
                </li>
              </ul>
              <Link href="/signup?type=fan">
                <Button variant="outline" className="w-full">
                  Créer un compte
                </Button>
              </Link>
            </div>

            {/* Pour les Artistes */}
            <div className="p-8 bg-vybzzz-gradient border-2 border-vybzzz-orange rounded-xl relative">
              <div className="absolute -top-4 left-1/2 -translate-x-1/2 px-4 py-1 bg-vybzzz-orange text-white text-sm font-bold rounded-full">
                POPULAIRE
              </div>
              <h3 className="text-2xl font-bold mb-4">Pour les Artistes</h3>
              <div className="mb-6">
                <span className="text-5xl font-bold">10%</span>
                <span className="text-gray-300 ml-2">de commission</span>
              </div>
              <ul className="space-y-3 mb-8">
                <li className="flex items-center gap-2">
                  <Check className="w-5 h-5 text-green-500" />
                  <span>Transfert immédiat</span>
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-5 h-5 text-green-500" />
                  <span>Concerts illimités</span>
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-5 h-5 text-green-500" />
                  <span>Analytics en temps réel</span>
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-5 h-5 text-green-500" />
                  <span>Support prioritaire</span>
                </li>
              </ul>
              <Link href="/signup?type=artist">
                <Button className="w-full bg-white text-vybzzz-purple hover:bg-gray-100">
                  Devenir artiste
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Final */}
      <section className="py-20 px-4">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-5xl font-bold mb-6">
            Prêt à révolutionner<br />tes concerts live ?
          </h2>
          <p className="text-xl text-gray-400 mb-8">
            Rejoins les 300+ artistes qui ont déjà choisi VyBzzZ
          </p>
          <Link href="/signup">
            <Button size="lg" className="gap-2">
              Commencer maintenant
              <ArrowRight className="w-5 h-5" />
            </Button>
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-12 px-4 border-t border-gray-800">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col md:flex-row items-center justify-between gap-4">
            <Logo />
            <p className="text-gray-400 text-sm">
              © 2025 VyBzzZ. Tous droits réservés.
            </p>
            <div className="flex gap-6 text-sm text-gray-400">
              <a href="#" className="hover:text-white transition-colors">CGU</a>
              <a href="#" className="hover:text-white transition-colors">Confidentialité</a>
              <a href="#" className="hover:text-white transition-colors">Contact</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}
