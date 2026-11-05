import { expect, test } from 'claude-code/testing'

import { bar, baseName, fillColor, fmtTokens, segments } from './format'

test('fill colour: green ≤30, orange >30, red >50', () => {
  expect(fillColor(0)).toBe('success')
  expect(fillColor(30)).toBe('success')
  expect(fillColor(31)).toBe('#ff8c00')
  expect(fillColor(50)).toBe('#ff8c00')
  expect(fillColor(51)).toBe('error')
})

test('bar is fixed width and clamped', () => {
  expect(bar(50, 10)).toBe('█████░░░░░')
  expect(bar(150, 4)).toBe('████')
  expect(bar(-5, 4)).toBe('░░░░')
})

test('token formatting', () => {
  expect(fmtTokens(950)).toBe('950')
  expect(fmtTokens(68_400)).toBe('68k')
  expect(fmtTokens(1_000_000)).toBe('1.0M')
})

test('segments split the bar by category, skipping free and buffer', () => {
  const cats = [
    { name: 'System prompt', tokens: 20_000, color: 'a' },
    { name: 'Messages', tokens: 60_000, color: 'b' },
    { name: 'Free space', tokens: 87_000, color: 'c' },
    { name: 'Autocompact buffer', tokens: 33_000, color: 'd' },
  ]
  expect(segments(cats, 200_000, 10)).toEqual({ used: [{ color: 'a', cells: 1 }, { color: 'b', cells: 3 }], empty: 6 })
  expect(segments(cats, 0, 4)).toEqual({ used: [], empty: 4 })
})

test('folder is the last path segment', () => {
  expect(baseName('/Users/me/Dev/app')).toBe('app')
  expect(baseName('/Users/me/Dev/app/')).toBe('app')
  expect(baseName('/')).toBe('/')
})
