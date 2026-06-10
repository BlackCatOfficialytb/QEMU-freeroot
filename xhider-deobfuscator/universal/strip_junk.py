#!/usr/bin/env python3
"""Strip junk do...end blocks from XHider psu_max chunk_1 source.

Junk blocks are identified by containing metatable-trap patterns like
(expr)._  —  these appear ONLY in dead-code blocks and never in real code.
The real VM code uses normal table indexing like _[key] or _["str"].

Usage:  python3 strip_junk.py <input.lua> [output.lua]

Algorithm:
  1. Strip strings and comments from a copy of the source (preserve positions).
  2. Tokenise block keywords: do / end / function / then.
  3. Track depth; match every standalone 'do' with its closing 'end'.
  4. Flag a pair as junk when the block body contains ')._' (metatable trap).
  5. Remove all junk ranges from the original source (back-to-front).
"""

import re
import sys


# ───────────────────────── string / comment stripper ─────────────────────────

def _strip(src):
    """Return a copy of *src* where every string literal and comment is replaced
    with spaces (same length), so keyword search won't match inside them."""
    out = list(src)
    i, n = 0, len(src)

    while i < n:
        c = src[i]

        # ── long bracket comment  --[==[ ... ]==] ──
        if c == '-' and i + 1 < n and src[i + 1] == '-':
            m = re.match(r'\[(=*)\[', src[i + 2:])
            if m:
                eq, close = m.group(1), ']' + m.group(1) + ']'
                j = src.find(close, i + 2 + len(m.group(0)))
                j = n if j < 0 else j + len(close)
                for k in range(i, min(j, n)):
                    out[k] = ' '
                i = j
                continue
            else:
                # short comment
                j = src.find('\n', i)
                j = n if j < 0 else j
                for k in range(i, j):
                    out[k] = ' '
                i = j
                continue

        # ── long bracket string  [==[ ... ]==] ──
        if c == '[':
            m = re.match(r'\[(=*)\[', src[i:])
            if m:
                eq, close = m.group(1), ']' + m.group(1) + ']'
                j = src.find(close, i + len(m.group(0)))
                j = n if j < 0 else j + len(close)
                for k in range(i, min(j, n)):
                    out[k] = ' '
                i = j
                continue

        # ── quoted string  "..." / '...' ──
        if c in ('"', "'"):
            j = i + 1
            while j < n:
                if src[j] == '\\':
                    j += 2
                elif src[j] == c:
                    j += 1
                    break
                else:
                    j += 1
            for k in range(i, min(j, n)):
                out[k] = ' '
            i = j
            continue

        i += 1

    return ''.join(out)


# ───────────────────────── do…end pair finder ──────────────────────────────────

def find_do_end_pairs(src):
    """Return a list of (do_start, end_exclusive) for every ``do…end`` pair."""
    stripped = _strip(src)

    # Collect block-keyword tokens
    tokens = []
    for m in re.finditer(r'\b(do|end|function|then)\b', stripped):
        tokens.append((m.start(), m.group()))

    depth = 0
    do_stack = []          # [(do_pos, depth_right_after_do)]
    pairs = []

    for pos, kw in tokens:
        if kw in ('do', 'function', 'then'):
            depth += 1
            if kw == 'do':
                do_stack.append((pos, depth))
        elif kw == 'end':
            # An 'end' that returns us to a depth where an unmatched 'do' was
            if do_stack and depth == do_stack[-1][1]:
                do_pos, _ = do_stack.pop()
                pairs.append((do_pos, pos + 3))   # 'end' is 3 chars
            depth -= 1

    return pairs


# ───────────────────────── junk detection ────────────────────────────────────

def _is_junk(src, start, end):
    """A block is *junk* when its body contains the metatable-trap pattern
    ``)._`` — which only ever appears in dead-code blocks, never in the
    real VM interpreter."""
    return re.search(r'\)\._', src[start:end]) is not None


# ───────────────────────── main stripper ─────────────────────────────────────

def strip_junk(src):
    """Remove every junk ``do…end`` block from *src* and return the cleaned
    source."""
    pairs = find_do_end_pairs(src)
    junk = [(s, e) for s, e in pairs if _is_junk(src, s, e)]

    if not junk:
        return src

    # Merge overlapping ranges (outer block contains inner blocks)
    junk.sort()
    merged = [junk[0]]
    for s, e in junk[1:]:
        if s <= merged[-1][1]:
            merged[-1] = (merged[-1][0], max(merged[-1][1], e))
        else:
            merged.append((s, e))

    # Extend each range to also swallow any trailing ';' separator
    cleaned_ranges = []
    for s, e in merged:
        # skip trailing whitespace
        trail = src[e:]
        m = re.match(r'[ \t]*\;?', trail)
        if m:
            e += m.end()
        cleaned_ranges.append((s, e))

    # Remove back-to-front so earlier offsets stay valid
    for s, e in reversed(cleaned_ranges):
        src = src[:s] + src[e:]

    # Collapse multiple blank lines into at most one
    src = re.sub(r'\n{3,}', '\n\n', src)

    return src


# ───────────────────────── constant folding helpers ───────────────────────────

def fold_calculate(src):
    """Replace ``Calculate(t(A,B),t(C,D))`` and ``t(A,B)`` calls with their
    pre-computed integer values.  *t* is ``bit32.bxor`` and *Calculate* is
    ``bit32.band``.

    Also folds lazy-decoder calls like
        (l[KEY] or o[500910416](t(A,B),t,l,KEY))
    by extracting the key and noting that the result is deterministic once
    we know the decoder output for that key.
    """
    import ctypes

    MASK = 0xFFFFFFFF

    def to_u32(x):
        return x & MASK

    def bxor(a, b):
        return to_u32(int(a) ^ int(b))

    def band(a, b):
        return to_u32(int(a) & int(b))

    # Phase 1: fold t(A,B) → constant  (t is the bxor alias)
    def _fold_t(m):
        inner = m.group(1)
        # Try to parse two numeric arguments separated by comma
        parts = [p.strip() for p in inner.split(',', 1)]
        if len(parts) != 2:
            return m.group(0)
        try:
            a = int(parts[0], 0) if not parts[0].startswith('"') and not parts[0].startswith("'") else None
            b = int(parts[1], 0) if not parts[1].startswith('"') and not parts[1].startswith("'") else None
        except (ValueError, TypeError):
            a = b = None
        if a is not None and b is not None:
            return str(bxor(a, b))
        return m.group(0)

    src = re.sub(r'\bt\(([^)]+)\)', _fold_t, src)

    # Phase 2: fold Calculate(A,B) → constant
    def _fold_calc(m):
        inner = m.group(1)
        parts = [p.strip() for p in inner.split(',', 1)]
        if len(parts) != 2:
            return m.group(0)
        try:
            a = int(parts[0])
            b = int(parts[1])
        except (ValueError, TypeError):
            return m.group(0)
        return str(band(a, b))

    src = re.sub(r'\bCalculate\(([^)]+)\)', _fold_calc, src)

    return src


# ───────────────────────── CLI ────────────────────────────────────────────────

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 strip_junk.py <input.lua> [output.lua]",
              file=sys.stderr)
        sys.exit(1)

    inp = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else None

    with open(inp, 'r', encoding='utf-8', errors='replace') as fh:
        src = fh.read()

    cleaned = strip_junk(src)
    cleaned = fold_calculate(cleaned)

    if out:
        with open(out, 'w', encoding='utf-8') as fh:
            fh.write(cleaned)
        print(f"Wrote {len(cleaned)} bytes → {out}", file=sys.stderr)
    else:
        sys.stdout.write(cleaned)

    removed = len(src) - len(cleaned)
    pct = 100 * removed / len(src) if len(src) else 0
    print(f"Stripped {removed} bytes ({pct:.1f}%) of junk", file=sys.stderr)


if __name__ == '__main__':
    main()
