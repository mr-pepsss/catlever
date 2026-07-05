#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

REPO_NAME="catlever"

if [ ! -f config.local.js ]; then
  echo "config.local.js missing. Create it with GH_TOKEN and GH_USER before pushing." >&2
  exit 1
fi

GH_TOKEN=$(node -e "import('./config.local.js').then(m => process.stdout.write(m.GH_TOKEN || ''))")
GH_USER=$(node -e "import('./config.local.js').then(m => process.stdout.write(m.GH_USER || ''))")

if [ -z "$GH_TOKEN" ] || [ -z "$GH_USER" ]; then
  echo "GH_TOKEN / GH_USER not set in config.local.js." >&2
  exit 1
fi

if [ ! -d .git ]; then
  git init
  git branch -M main
fi

git add -A
git diff --cached --quiet || git commit -m "catlever: initial one-page site"

CREATE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: token $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d "{\"name\":\"$REPO_NAME\",\"private\":false}")

if [ "$CREATE_RESPONSE" = "201" ]; then
  echo "Created GitHub repo $GH_USER/$REPO_NAME"
elif [ "$CREATE_RESPONSE" = "422" ]; then
  echo "Repo $GH_USER/$REPO_NAME already exists, continuing"
else
  echo "GitHub repo create returned HTTP $CREATE_RESPONSE, continuing anyway"
fi

REMOTE_URL="https://$GH_TOKEN@github.com/$GH_USER/$REPO_NAME.git"

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REMOTE_URL"
else
  git remote add origin "$REMOTE_URL"
fi

git push -u origin main

npx vercel --prod
