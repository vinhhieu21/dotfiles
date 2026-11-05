import type { Category } from '../types'

export const ORANGE_AT = 30
export const RED_AT = 50

export function fillColor(pct: number): string {
  if (pct > RED_AT) return 'error'
  if (pct > ORANGE_AT) return '#ff8c00'
  return 'success'
}

export function bar(pct: number, width: number): string {
  const p = Math.max(0, Math.min(100, pct))
  const full = Math.round((p / 100) * width)
  return '█'.repeat(full) + '░'.repeat(width - full)
}

export function fmtTokens(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`
  if (n >= 1000) return `${Math.round(n / 1000)}k`
  return `${n}`
}

const UNUSED = new Set(['Free space', 'Autocompact buffer'])

export type Segment = { color: string; cells: number }

// Splits round(used/window * width) cells across the used categories, in order, by cumulative rounding.
export function segments(categories: Category[], window: number, width: number): { used: Segment[]; empty: number } {
  const used: Segment[] = []
  if (window <= 0) return { used, empty: width }
  let acc = 0
  let drawn = 0
  for (const c of categories) {
    if (UNUSED.has(c.name)) continue
    acc += c.tokens
    const end = Math.min(width, Math.round((acc / window) * width))
    if (end > drawn) used.push({ color: c.color, cells: end - drawn })
    drawn = Math.max(drawn, end)
  }
  return { used, empty: width - drawn }
}

const SHORT: Record<string, string> = {
  'System prompt': 'sys',
  'System tools': 'tools',
  'MCP tools': 'mcp',
  'MCP server instructions': 'mcp-instr',
  'Custom agents': 'agents',
  'Memory files': 'memory',
  'Skills': 'skills',
  'Messages': 'msgs',
  'Free space': 'free',
  'Autocompact buffer': 'buffer',
}

export function shortName(c: Category): string {
  return SHORT[c.name] ?? c.name.toLowerCase()
}

export function baseName(path: string): string {
  const parts = path.split('/').filter(Boolean)
  return parts.at(-1) ?? '/'
}
