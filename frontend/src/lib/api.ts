export type TaskStatus = 'TODO' | 'IN_PROGRESS' | 'DONE'

export type Session = { token: string; email: string; name: string }

export type Task = {
  id: number
  title: string
  description: string | null
  status: TaskStatus
}

const KEY = 'tm_session'

export function getSession(): Session | null {
  const raw = localStorage.getItem(KEY)
  return raw ? (JSON.parse(raw) as Session) : null
}

export function setSession(session: Session | null) {
  if (session) localStorage.setItem(KEY, JSON.stringify(session))
  else localStorage.removeItem(KEY)
}

async function request<T>(path: string, init: RequestInit = {}): Promise<T> {
  const headers = new Headers(init.headers)
  headers.set('Content-Type', 'application/json')
  const token = getSession()?.token
  if (token) headers.set('Authorization', `Bearer ${token}`)

  const res = await fetch(path, { ...init, headers })
  const text = await res.text()
  const data = text ? JSON.parse(text) : null
  if (!res.ok) throw new Error(data?.message ?? `Erreur ${res.status}`)
  return data as T
}

export const api = {
  register: (body: { name: string; email: string; password: string }) =>
    request<Session>('/api/auth/register', { method: 'POST', body: JSON.stringify(body) }),
  login: (body: { email: string; password: string }) =>
    request<Session>('/api/auth/login', { method: 'POST', body: JSON.stringify(body) }),
  listTasks: (status = '', q = '') => {
    const p = new URLSearchParams()
    if (status) p.set('status', status)
    if (q.trim()) p.set('q', q.trim())
    const qs = p.toString()
    return request<Task[]>(`/api/tasks${qs ? `?${qs}` : ''}`)
  },
  saveTask: (body: { title: string; description: string; status: TaskStatus }, id?: number) =>
    request<Task>(id ? `/api/tasks/${id}` : '/api/tasks', {
      method: id ? 'PUT' : 'POST',
      body: JSON.stringify(body),
    }),
  deleteTask: (id: number) => request<void>(`/api/tasks/${id}`, { method: 'DELETE' }),
}
