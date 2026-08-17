#!/usr/bin/env bash
# Build the Slidev deck and publish it to the gh-pages branch on origin.
#
# Usage:
#   ./slide/deploy.sh        (from anywhere in the repo)
#
# Every run: builds slides.md fresh, syncs the output onto an up-to-date
# gh-pages branch (removing anything that's no longer produced), commits,
# and pushes. Safe to re-run — if the build output hasn't changed, it exits
# without creating an empty commit.
set -euo pipefail

ROUTER_MODE="hash"
BRANCH="gh-pages"
REMOTE="origin"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"
OUT_DIR="$SCRIPT_DIR/dist"

# Derive the GitHub Pages base path ("/repo-name/") from the origin remote,
# so this keeps working if the repo is ever renamed or forked.
ORIGIN_URL="$(git -C "$REPO_ROOT" remote get-url "$REMOTE")"
REPO_NAME="$(basename "$ORIGIN_URL" .git)"
BASE_PATH="/${REPO_NAME}/"

if [ -n "$(git -C "$REPO_ROOT" status --porcelain -- slide)" ]; then
  echo "warning: slide/ has uncommitted changes — deploying from the working tree anyway," >&2
  echo "         but the deploy commit's source hash won't correspond to a real commit." >&2
fi

echo "==> Building slides (base: ${BASE_PATH}, router: ${ROUTER_MODE})"
cd "$SCRIPT_DIR"
rm -rf "$OUT_DIR"
bunx slidev build --base "$BASE_PATH" --router-mode "$ROUTER_MODE" --out "$OUT_DIR"

echo "==> Preparing ${BRANCH} worktree"
WORKTREE_DIR="$(mktemp -d)"
cleanup() {
  git -C "$REPO_ROOT" worktree remove --force "$WORKTREE_DIR" >/dev/null 2>&1 || true
  rm -rf "$WORKTREE_DIR"
}
trap cleanup EXIT

cd "$REPO_ROOT"
git fetch "$REMOTE" "$BRANCH" >/dev/null 2>&1 || true

if git show-ref --verify --quiet "refs/remotes/${REMOTE}/${BRANCH}"; then
  git worktree add "$WORKTREE_DIR" "$BRANCH" >/dev/null
elif git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
  git worktree add "$WORKTREE_DIR" "$BRANCH" >/dev/null
else
  echo "==> No ${BRANCH} branch yet — creating it"
  git worktree add --detach "$WORKTREE_DIR" >/dev/null
  (cd "$WORKTREE_DIR" && git checkout --orphan "$BRANCH" >/dev/null 2>&1 && git rm -rf . >/dev/null 2>&1 || true)
fi

echo "==> Syncing build output"
find "$WORKTREE_DIR" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
cp -R "$OUT_DIR"/. "$WORKTREE_DIR"/
touch "$WORKTREE_DIR/.nojekyll"

cd "$WORKTREE_DIR"
git add -A

if git diff --cached --quiet; then
  echo "==> Nothing changed — slide output on ${BRANCH} is already up to date."
  exit 0
fi

SRC_COMMIT="$(git -C "$REPO_ROOT" rev-parse --short HEAD)"
git commit -q -m "deploy: publish slides from ${SRC_COMMIT}"
git push "$REMOTE" "$BRANCH"

OWNER="$(dirname "$ORIGIN_URL" | sed -E 's#.*[:/]##' | tr '[:upper:]' '[:lower:]')"
echo "==> Deployed: https://${OWNER}.github.io/${REPO_NAME}/"
