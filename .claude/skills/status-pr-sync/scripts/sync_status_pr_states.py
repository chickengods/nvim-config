#!/usr/bin/env python3
"""Sync STATUS.md checkbox states from GitHub PR status.

State mapping:
- open PR -> [-]
- merged PR -> [x]
- closed-unmerged PR -> [ ]

The script looks for lines like:
- PR: https://github.com/org/repo/pull/123

It updates the nearest parent checklist item (typically a PR group) and all
nested checklist items under that parent. Then it rolls up parent checklist
items (for example milestone lines) from child states.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple

CHECKBOX_RE = re.compile(r"^(?P<indent>\s*)-\s\[(?P<state>[ x-])\]\s(?P<rest>.*?)(?P<nl>\r?\n)?$")
PR_URL_RE = re.compile(r"PR:\s*(?:\[[^\]]+\]\()?((https?://[^)\s]+))", re.IGNORECASE)
PR_PATH_RE = re.compile(r"^/([^/]+)/([^/]+)/pull/(\d+)(?:$|[/?#])")


@dataclass
class CheckboxLine:
    index: int
    indent_len: int


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Sync STATUS.md PR states from GitHub.")
    parser.add_argument("status_path", help="Path to STATUS.md")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show planned updates without writing the file.",
    )
    parser.add_argument(
        "--no-rollup",
        action="store_true",
        help="Do not roll up parent checklist states from child states.",
    )
    return parser.parse_args()


def state_of_line(line: str) -> Optional[str]:
    match = CHECKBOX_RE.match(line)
    return match.group("state") if match else None


def set_line_state(line: str, new_state: str) -> str:
    if new_state not in {" ", "-", "x"}:
        raise ValueError(f"invalid state: {new_state}")
    return CHECKBOX_RE.sub(lambda m: f"{m.group('indent')}- [{new_state}] {m.group('rest')}{m.group('nl') or ''}", line, count=1)


def checkbox_lines(lines: List[str]) -> List[CheckboxLine]:
    out: List[CheckboxLine] = []
    for idx, line in enumerate(lines):
        match = CHECKBOX_RE.match(line)
        if not match:
            continue
        indent_len = len(match.group("indent").replace("\t", "  "))
        out.append(CheckboxLine(index=idx, indent_len=indent_len))
    return out


def parse_pr_url(line: str) -> Optional[str]:
    match = PR_URL_RE.search(line)
    if not match:
        return None
    return match.group(1)


def parse_repo_from_pr_url(url: str) -> Tuple[str, str, str, str]:
    from urllib.parse import urlparse

    parsed = urlparse(url)
    host = parsed.hostname or "github.com"
    m = PR_PATH_RE.match(parsed.path)
    if not m:
        raise ValueError(f"unsupported PR URL format: {url}")
    owner, repo, number = m.group(1), m.group(2), m.group(3)
    return host, owner, repo, number


def gh_pr_state(url: str) -> str:
    host, owner, repo, number = parse_repo_from_pr_url(url)
    cmd = [
        "gh",
        "api",
        "--hostname",
        host,
        f"repos/{owner}/{repo}/pulls/{number}",
        "--jq",
        "{state: .state, merged: .merged, merged_at: .merged_at}",
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.strip() or f"gh api failed for {url}")

    payload = json.loads(proc.stdout)
    if payload.get("merged") or payload.get("merged_at"):
        return "x"
    if payload.get("state") == "open":
        return "-"
    return " "


def nearest_parent_checkbox(
    pr_line_index: int,
    pr_indent_len: int,
    checks: List[CheckboxLine],
) -> Optional[CheckboxLine]:
    for check in reversed(checks):
        if check.index >= pr_line_index:
            continue
        if check.indent_len < pr_indent_len:
            return check
    return None


def descendant_check_indexes(parent: CheckboxLine, checks: List[CheckboxLine]) -> List[int]:
    out: List[int] = []
    for check in checks:
        if check.index <= parent.index:
            continue
        if check.indent_len <= parent.indent_len:
            break
        out.append(check.index)
    return out


def build_checkbox_tree(checks: List[CheckboxLine]) -> Tuple[Dict[int, Optional[int]], Dict[int, List[int]]]:
    by_index = {c.index: c for c in checks}
    parents: Dict[int, Optional[int]] = {}
    children: Dict[int, List[int]] = {c.index: [] for c in checks}
    stack: List[CheckboxLine] = []

    for check in checks:
        while stack and check.indent_len <= stack[-1].indent_len:
            stack.pop()
        parent = stack[-1].index if stack else None
        parents[check.index] = parent
        if parent is not None:
            children[parent].append(check.index)
        stack.append(check)

    for idx in by_index:
        children.setdefault(idx, [])
    return parents, children


def aggregate_state(child_states: List[str]) -> str:
    if not child_states:
        raise ValueError("aggregate_state requires at least one child")
    if all(s == "x" for s in child_states):
        return "x"
    if any(s == "-" for s in child_states):
        return "-"
    if any(s == "x" for s in child_states):
        return "-"
    return " "


def main() -> int:
    args = parse_args()
    status_path = Path(args.status_path)
    if not status_path.exists():
        print(f"ERROR: file not found: {status_path}", file=sys.stderr)
        return 1

    lines = status_path.read_text(encoding="utf-8").splitlines(keepends=True)
    checks = checkbox_lines(lines)
    _, tree_children = build_checkbox_tree(checks)

    pr_state_cache: Dict[str, str] = {}
    updated: List[Tuple[int, str, str, str]] = []
    parent_pr_map: Dict[int, str] = {}

    # First pass: update PR-group lines and descendant tasks from PR URL lines.
    for idx, line in enumerate(lines):
        pr_url = parse_pr_url(line)
        if not pr_url:
            continue

        pr_indent_len = len((line[: len(line) - len(line.lstrip())]).replace("\t", "  "))
        parent = nearest_parent_checkbox(idx, pr_indent_len, checks)
        if not parent:
            continue

        if pr_url not in pr_state_cache:
            pr_state_cache[pr_url] = gh_pr_state(pr_url)
        target_state = pr_state_cache[pr_url]
        parent_pr_map[parent.index] = pr_url

        targets = [parent.index] + descendant_check_indexes(parent, checks)
        for target_idx in targets:
            old_state = state_of_line(lines[target_idx])
            if old_state is None:
                continue
            if old_state == target_state:
                continue
            lines[target_idx] = set_line_state(lines[target_idx], target_state)
            updated.append((target_idx + 1, old_state, target_state, pr_url))

    # Second pass: roll up parent states from child states.
    if not args.no_rollup:
        for check in sorted(checks, key=lambda c: c.indent_len, reverse=True):
            child_indexes = tree_children.get(check.index, [])
            if not child_indexes:
                continue
            child_states = [state_of_line(lines[i]) for i in child_indexes]
            child_states = [s for s in child_states if s is not None]
            if not child_states:
                continue
            rolled = aggregate_state(child_states)
            old_state = state_of_line(lines[check.index])
            if old_state is None or old_state == rolled:
                continue
            lines[check.index] = set_line_state(lines[check.index], rolled)
            source = parent_pr_map.get(check.index, "rollup")
            updated.append((check.index + 1, old_state, rolled, source))

    if not updated:
        print(f"No updates needed for {status_path}")
        return 0

    print(f"Planned updates for {status_path}:")
    for line_no, old, new, source in sorted(updated, key=lambda x: x[0]):
        print(f"  line {line_no}: [{old}] -> [{new}]  source={source}")

    if args.dry_run:
        print("Dry run only; no file changes written.")
        return 0

    status_path.write_text("".join(lines), encoding="utf-8")
    print(f"Updated {status_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
