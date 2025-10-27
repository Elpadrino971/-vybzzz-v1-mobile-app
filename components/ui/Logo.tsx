'use client'

import { motion } from 'framer-motion'
import Link from 'next/link'

export function Logo() {
  return (
    <Link href="/" className="flex items-center gap-2">
      <motion.div
        className="relative w-10 h-10"
        whileHover={{ scale: 1.1, rotate: 10 }}
        transition={{ type: 'spring', stiffness: 400, damping: 10 }}
      >
        {/* Abeille stylisée */}
        <div className="absolute inset-0 bg-vybzzz-gradient rounded-full" />
        <div className="absolute inset-0 flex items-center justify-center text-2xl">
          🐝
        </div>
      </motion.div>
      <span className="text-2xl font-bold gradient-text">VyBzzZ</span>
    </Link>
  )
}
