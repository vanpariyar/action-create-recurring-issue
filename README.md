Excellent idea 💡 — you can publish a **reusable GitHub Action** that anyone can include in their workflow to auto-create a monthly recurring issue (like rent, bills, or any checklist).

Let’s build it cleanly and professionally 👇

---

## 🧱 1. Folder structure for your reusable action

In a new repository (e.g. `vanpariyar/create-recurring-issue`):

```
.github/
  workflows/
    test.yml          # for testing your action
action.yml            # defines the reusable Action
entrypoint.sh         # logic to create the recurring issue
README.md             # usage documentation
```

---

## ⚙️ `action.yml`

```yaml
name: "Create Recurring Issue"
description: "Creates a recurring GitHub Issue with a predefined checklist each month"
author: "Ronak Vanpariyar"
branding:
  icon: "calendar"
  color: "blue"

inputs:
  github_token:
    description: "GitHub token with 'issues: write' permission"
    required: true
  title_prefix:
    description: "Prefix for the issue title"
    required: true
    default: "Monthly Rent & Bills"
  labels:
    description: "Comma-separated labels to add to the issue"
    required: false
    default: "monthly,rent"
  checklist_template:
    description: "Multiline checklist for the issue body"
    required: false
    default: |
      - [ ] Office Rent Paid
      - [ ] Home Rent Paid
      - [ ] Maintenance Paid
      - [ ] Light Bill Paid
      - [ ] Internet Bill Paid
      - [ ] Other Expenses Reviewed

runs:
  using: "composite"
  steps:
    - name: Create Monthly Issue
      shell: bash
      env:
        GH_TOKEN: ${{ inputs.github_token }}
        TITLE_PREFIX: ${{ inputs.title_prefix }}
        LABELS: ${{ inputs.labels }}
        CHECKLIST_TEMPLATE: ${{ inputs.checklist_template }}
      run: bash $GITHUB_ACTION_PATH/entrypoint.sh
```

---

## 🧠 `entrypoint.sh`

```bash
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
```

> Make sure to give `entrypoint.sh` execute permission:
> `chmod +x entrypoint.sh`

---

## 🧪 `.github/workflows/test.yml` (for your own repo testing)

```yaml
name: Test Recurring Issue

on:
  workflow_dispatch:
  schedule:
    - cron: '0 0 1 * *' # 1st of every month

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ./ # use local action for testing
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

---

## 💡 Example Usage (for other repos)

Once you push this to GitHub, anyone can use it like this in **their** workflows:

```yaml
name: Monthly Rent Issue

on:
  schedule:
    - cron: '0 0 1 * *'
  workflow_dispatch:

jobs:
  rent:
    runs-on: ubuntu-latest
    steps:
      - name: Create Monthly Rent Issue
        uses: vanpariyar/action-create-recurring-issue@v1.0
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          title_prefix: "Monthly Rent & Bills"
          labels: "monthly,rent"
          checklist_template: |
            - [ ] Office Rent Paid
            - [ ] Home Rent Paid
            - [ ] Maintenance Paid
            - [ ] Light Bill Paid
            - [ ] Internet Bill Paid
```

---

## 🚀 Optional Enhancements

You can later add:

* **auto-close last month’s issue**
* **custom templates from `.github/ISSUE_TEMPLATE.md`**
* **Slack or email notification**

---

Would you like me to include an **auto-close last month’s issue** feature inside this reusable action (as an optional input)?
That makes it even more “hands-free” each month.
