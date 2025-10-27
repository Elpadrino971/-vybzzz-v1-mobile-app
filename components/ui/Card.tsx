import { cn } from '@/lib/utils'
import { HTMLAttributes, forwardRef } from 'react'

interface CardProps extends HTMLAttributes<HTMLDivElement> {}

export const Card = forwardRef<HTMLDivElement, CardProps>(
  ({ className, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn(
          'p-6 bg-vybzzz-dark border border-gray-800 rounded-xl',
          className
        )}
        {...props}
      />
    )
  }
)

Card.displayName = 'Card'
