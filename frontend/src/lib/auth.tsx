import { createContext, useContext, useState, type ReactNode } from 'react'
import { api, getSession, setSession, type Session } from './api'

type AuthCtx = {
  session: Session | null
  login: (email: string, password: string) => Promise<void>
  register: (name: string, email: string, password: string) => Promise<void>
  logout: () => void
}

const Ctx = createContext<AuthCtx | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, set] = useState<Session | null>(() => getSession())

  const value: AuthCtx = {
    session,
    async login(email, password) {
      const s = await api.login({ email, password })
      setSession(s)
      set(s)
    },
    async register(name, email, password) {
      const s = await api.register({ name, email, password })
      setSession(s)
      set(s)
    },
    logout() {
      setSession(null)
      set(null)
    },
  }

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>
}

export function useAuth() {
  const ctx = useContext(Ctx)
  if (!ctx) throw new Error('useAuth outside provider')
  return ctx
}
