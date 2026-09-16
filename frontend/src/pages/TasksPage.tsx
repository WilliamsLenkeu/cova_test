import { useEffect, useState, type FormEvent } from 'react'
import { Navigate } from 'react-router-dom'
import { api, type Task, type TaskStatus } from '../lib/api'
import { useAuth } from '../lib/auth'

const STATUSES: TaskStatus[] = ['TODO', 'IN_PROGRESS', 'DONE']
const LABEL: Record<TaskStatus, string> = {
  TODO: 'À faire',
  IN_PROGRESS: 'En cours',
  DONE: 'Terminé',
}
const empty = { title: '', description: '', status: 'TODO' as TaskStatus }
const input = 'w-full rounded-md border border-zinc-200 px-3 py-2 text-sm'

export function TasksPage() {
  const { session, logout } = useAuth()
  const [tasks, setTasks] = useState<Task[]>([])
  const [status, setStatus] = useState('')
  const [q, setQ] = useState('')
  const [form, setForm] = useState(empty)
  const [editId, setEditId] = useState<number | null>(null)
  const [msg, setMsg] = useState('')

  async function load() {
    try {
      setTasks(await api.listTasks(status, q))
      setMsg('')
    } catch (err) {
      setMsg(err instanceof Error ? err.message : 'Erreur')
    }
  }

  useEffect(() => {
    if (session) void load()
  }, [session, status, q])

  if (!session) return <Navigate to="/login" replace />

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    try {
      await api.saveTask(form, editId ?? undefined)
      setForm(empty)
      setEditId(null)
      await load()
    } catch (err) {
      setMsg(err instanceof Error ? err.message : 'Erreur')
    }
  }

  async function remove(id: number) {
    if (!confirm('Supprimer ?')) return
    try {
      await api.deleteTask(id)
      if (editId === id) {
        setEditId(null)
        setForm(empty)
      }
      await load()
    } catch (err) {
      setMsg(err instanceof Error ? err.message : 'Erreur')
    }
  }

  return (
    <div className="mx-auto min-h-screen max-w-3xl px-4 py-8">
      <header className="mb-6 flex items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold">Mes tâches</h1>
          <p className="text-sm text-zinc-500">
            {session.name} · {session.email}
          </p>
        </div>
        <button type="button" onClick={logout} className="rounded-md border border-zinc-200 bg-white px-3 py-1.5 text-sm">
          Déconnexion
        </button>
      </header>

      {msg && <p className="mb-4 rounded-md bg-red-50 px-3 py-2 text-sm text-red-700">{msg}</p>}

      <div className="mb-4 flex flex-wrap gap-2">
        <select
          className="rounded-md border border-zinc-200 bg-white px-3 py-2 text-sm"
          value={status}
          onChange={(e) => setStatus(e.target.value)}
        >
          <option value="">Tous</option>
          {STATUSES.map((s) => (
            <option key={s} value={s}>
              {LABEL[s]}
            </option>
          ))}
        </select>
        <input
          className="min-w-48 flex-1 rounded-md border border-zinc-200 bg-white px-3 py-2 text-sm"
          placeholder="Recherche"
          value={q}
          onChange={(e) => setQ(e.target.value)}
        />
      </div>

      <form onSubmit={onSubmit} className="mb-6 space-y-3 rounded-lg border border-zinc-200 bg-white p-4">
        <p className="text-sm font-medium">{editId == null ? 'Nouvelle tâche' : `Modifier #${editId}`}</p>
        <input
          className={input}
          placeholder="Titre"
          required
          value={form.title}
          onChange={(e) => setForm({ ...form, title: e.target.value })}
        />
        <textarea
          className={input}
          placeholder="Description"
          rows={2}
          value={form.description}
          onChange={(e) => setForm({ ...form, description: e.target.value })}
        />
        <select
          className={input}
          value={form.status}
          onChange={(e) => setForm({ ...form, status: e.target.value as TaskStatus })}
        >
          {STATUSES.map((s) => (
            <option key={s} value={s}>
              {LABEL[s]}
            </option>
          ))}
        </select>
        <div className="flex gap-2">
          <button type="submit" className="rounded-md bg-teal-700 px-3 py-2 text-sm text-white">
            {editId == null ? 'Ajouter' : 'Enregistrer'}
          </button>
          {editId != null && (
            <button
              type="button"
              className="rounded-md border border-zinc-200 px-3 py-2 text-sm"
              onClick={() => {
                setEditId(null)
                setForm(empty)
              }}
            >
              Annuler
            </button>
          )}
        </div>
      </form>

      <ul className="space-y-2">
        {tasks.length === 0 && <li className="text-sm text-zinc-500">Aucune tâche.</li>}
        {tasks.map((t) => (
          <li key={t.id} className="flex justify-between gap-2 rounded-lg border border-zinc-200 bg-white p-4">
            <div>
              <p className="font-medium">{t.title}</p>
              {t.description && <p className="mt-1 text-sm text-zinc-500">{t.description}</p>}
              <p className="mt-1 text-xs text-zinc-400">{LABEL[t.status]}</p>
            </div>
            <div className="flex h-fit gap-2">
              <button
                type="button"
                className="rounded-md border border-zinc-200 px-2 py-1 text-xs"
                onClick={() => {
                  setEditId(t.id)
                  setForm({ title: t.title, description: t.description ?? '', status: t.status })
                }}
              >
                Éditer
              </button>
              <button
                type="button"
                className="rounded-md border border-red-200 px-2 py-1 text-xs text-red-700"
                onClick={() => void remove(t.id)}
              >
                Supprimer
              </button>
            </div>
          </li>
        ))}
      </ul>
    </div>
  )
}
