export type Limit = { kind: string; pct: number; resetsAt?: string }
export type Category = { name: string; tokens: number; color: string }
export type Snapshot = {
  tokens?: number
  window: number
  limits: Limit[]
  categories: Category[]
  model: string
  folder: string
  branch: string | null
}

declare module 'claude-code' {
  interface PluginState {
    'usage-band': { snapshot: Snapshot | null }
  }
}
