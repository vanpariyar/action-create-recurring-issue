#!/bin/bash
set -euo pipefail

MONTH=$(date +'%B %Y')
TITLE="${TITLE_PREFIX} - ${MONTH}"
REPO="${GITHUB_REPOSITORY}"

# Convert comma-separated labels into JSON array
LABEL_JSON=$(jq -R 'split(",")' <<< "$LABELS")

BODY=$(cat <<EOF
### 🏠 ${TITLE_PREFIX} Checklist for ${MONTH}

Please update the checklist as you complete tasks:

${CHECKLIST_TEMPLATE}

> 💡 Reminder: Upload receipts or mark completed items after each payment.
EOF
)

echo "📝 Creating issue '$TITLE' in $REPO..."

curl -s -X POST \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d "$(jq -n \
      --arg title "$TITLE" \
      --arg body "$BODY" \
      --argjson labels "$LABEL_JSON" \
      '{title: $title, body: $body, labels: $labels}')" \
  "https://api.github.com/repos/${REPO}/issues"

echo "✅ Done. Issue created: '$TITLE'"