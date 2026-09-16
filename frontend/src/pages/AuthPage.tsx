import { useState, type FormEvent } from 'react'
import { Link, Navigate, useNavigate } from 'react-router-dom'
import { useAuth } from '../lib/auth'

const field = 'mt-1 w-full rounded-md border border-zinc-200 px-3 py-2'
const btn =
  'w-full rounded-md bg-teal-700 px-3 py-2 text-sm font-medium text-white hover:bg-teal-600 disabled:opacity-60'

export function AuthPage({ mode }: { mode: 'login' | 'register' }) {
  const { session, login, register } = useAuth()
  const navigate = useNavigate()
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)
  const isRegister = mode === 'register'

  if (session) return <Navigate to="/" replace />

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError('')
    setBusy(true)
    try {
      if (isRegister) await register(name, email, password)
      else await login(email, password)
      navigate('/', { replace: true })
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Échec')
    } finally {
      setBusy(false)
    }
  }

  return (
    <main className="mx-auto flex min-h-screen max-w-md flex-col justify-center px-4">
      <h1 className="mb-1 text-2xl font-semibold">Task Manager</h1>
      <p className="mb-6 text-sm text-zinc-500">{isRegister ? 'Créer un compte' : 'Connexion'}</p>
      <form onSubmit={onSubmit} className="space-y-3 rounded-lg border border-zinc-200 bg-white p-5">
        {error && <p className="rounded-md bg-red-50 px-3 py-2 text-sm text-red-700">{error}</p>}
        {isRegister && (
          <label className="block text-sm">
            Nom
            <input className={field} required maxLength={100} value={name} onChange={(e) => setName(e.target.value)} />
          </label>
        )}
        <label className="block text-sm">
          Email
          <input className={field} type="email" required value={email} onChange={(e) => setEmail(e.target.value)} />
        </label>
        <label className="block text-sm">
          Mot de passe
          <input
            className={field}
            type="password"
            required
            minLength={6}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </label>
        <button type="submit" disabled={busy} className={btn}>
          {busy ? '…' : isRegister ? 'Créer le compte' : 'Se connecter'}
        </button>
      </form>
      <p className="mt-4 text-center text-sm text-zinc-500">
        {isRegister ? (
          <>Déjà inscrit ? <Link className="text-teal-700 underline" to="/login">Se connecter</Link></>
        ) : (
          <>Pas de compte ? <Link className="text-teal-700 underline" to="/register">S’inscrire</Link></>
        )}
      </p>
    </main>
  )
}
