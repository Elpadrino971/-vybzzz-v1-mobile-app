import { NextRequest, NextResponse } from 'next/server'

export async function POST(req: NextRequest) {
  try {
    const { roomId, userId, role } = await req.json()

    // Générer un token HMS (100MS)
    // Note: Vous devrez implémenter la génération de token selon la doc 100MS
    const response = await fetch('https://prod-in2.100ms.live/api/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.HMS_MANAGEMENT_TOKEN}`,
      },
      body: JSON.stringify({
        room_id: roomId,
        user_id: userId,
        role: role || 'viewer',
        type: 'app',
      }),
    })

    const data = await response.json()

    return NextResponse.json({ token: data.token })
  } catch (error: any) {
    console.error('HMS token error:', error)
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}
