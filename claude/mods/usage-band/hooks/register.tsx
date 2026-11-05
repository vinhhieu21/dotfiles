import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, SessionContextUsage, SessionRateLimit } from 'claude-code'

import type { Snapshot } from '../types'
import { baseName, fillColor, fmtTokens, segments, shortName } from './format'

const snapshot = atom({ plugin: 'usage-band', key: 'snapshot' } as const, null)

const BAR_WIDTH = 12

const CTX_SCOPE = 'usage-band-context'

const LIMIT_LABEL: Record<string, string> = { five_hour: '5h', seven_day: 'wk' }

// Breakdown uses the local estimate ("summary"): no token-count API calls.
// Branch name, or the short commit when detached; null outside a repository.
async function gitBranch($: EngineInterface, cwd: string): Promise<string | null> {
  try {
    const head = await $.process.run(['git', 'symbolic-ref', '--short', '-q', 'HEAD'], { cwd, timeoutMs: 2000 })
    if (head.exitCode === 0) return head.stdout.trim()
    const sha = await $.process.run(['git', 'rev-parse', '--short', 'HEAD'], { cwd, timeoutMs: 2000 })
    return sha.exitCode === 0 ? sha.stdout.trim() : null
  } catch {
    return null
  }
}

async function refresh($: EngineInterface, ctx?: SessionContextUsage, limits?: SessionRateLimit[]) {
  const [usage, model, cwd] = await Promise.all([$.session.usage({ breakdown: 'summary' }), $.session.model(), $.session.cwd()])
  const branch = await gitBranch($, cwd)
  const context = ctx ?? usage.context
  const bd = usage.context.breakdown
  const next: Snapshot = {
    tokens: context.tokens,
    // Measure against the autocompact window when one is set (e.g. 200k on a 1M model).
    window: bd?.rawMaxTokens ?? context.window,
    limits: (limits ?? usage.rateLimits).map(l => ({ kind: l.kind, pct: l.percentUsed, resetsAt: l.resetsAt })),
    categories: (bd?.categories ?? [])
      .filter(c => c.kind !== 'deferred' && c.tokens > 0)
      .map(c => ({ name: c.name, tokens: c.tokens, color: c.color })),
    model,
    folder: baseName(cwd),
    branch,
  }
  await update($, snapshot, () => next)
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const r = await next(e)
    await refresh($)
    return r
  })

  on('session.measure', async ($, e, next) => {
    await refresh($, e.context, e.rateLimits)
    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const s = await read($, snapshot)
    if (e.props.hasSurvey || s === null) return next(e)

    const { Box, Text } = $.ui.resolve(e)
    const used = s.tokens ?? 0
    const pct = s.window > 0 ? Math.round((used / s.window) * 100) : 0

    const { used: segs, empty } = segments(s.categories, s.window, BAR_WIDTH)

    const pctLabel = ` ${pct}%`
    const breakdown = s.categories.map((c, i) => (
      <Text key={c.name}>
        {i > 0 ? ' ' : ''}
        <Text color={c.color}>{shortName(c)}</Text> {fmtTokens(c.tokens)}
      </Text>
    ))

    // One row. Hovering the bar reveals the context breakdown over the rest of the row;
    // the card shares the bar's hover scope, so it stays up while the pointer is on it.
    return (
      <Box flexDirection="row">
        <Box flexShrink={0} hover={{ scope: CTX_SCOPE }}>
          <Text>
            {segs.map((g, i) => (
              <Text key={String(i)} color={g.color}>{'█'.repeat(g.cells)}</Text>
            ))}
            <Text dimColor>{'░'.repeat(empty)}</Text>
            <Text color={fillColor(pct)}>{pctLabel}</Text>
          </Text>
        </Box>
        <Text wrap="truncate-end">
          <Text dimColor> {fmtTokens(used)}</Text>
          {s.limits.map(l => (
            <Text key={l.kind}>
              <Text dimColor> · </Text>
              <Text color={fillColor(l.pct)}>{LIMIT_LABEL[l.kind] ?? l.kind} {Math.round(l.pct)}%</Text>
            </Text>
          ))}
          <Text dimColor> │ </Text>
          <Text color="claude">{s.model}</Text>
          <Text dimColor> · </Text>
          <Text bold>{s.folder}</Text>
          {s.branch !== null && <Text color="permission"> ⎇ {s.branch}</Text>}
        </Text>
        {s.categories.length > 0 && (
          <Box
            position="absolute"
            top={0}
            left={BAR_WIDTH + pctLabel.length}
            right={0}
            display="none"
            hover={{ scope: CTX_SCOPE, display: 'flex' }}
          >
            {/* Trailing spaces overwrite the row underneath to the edge. */}
            <Text wrap="truncate-end" dimColor>
              {' '}
              {breakdown}
              {' '.repeat(400)}
            </Text>
          </Box>
        )}
      </Box>
    )
  })
}
