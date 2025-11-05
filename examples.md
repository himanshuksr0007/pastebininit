# PastebinInit - Examples

#### THIS FILE HAS BEEN GENRATED WITH THE HELP OF AI

Complete examples for common use cases.

## Getting Started

First, get your API key from: https://pastebin.com/doc_api

## Basic Examples

### Example 1: Upload a File

```bash
python3 pastebininit --api-key YOUR_API_KEY --content myfile.txt
```

**Output:**
```
ℹ Preparing upload...
ℹ Uploading to Pastebin...

✓ PASTE UPLOADED SUCCESSFULLY!
📋 Paste Details:
   ├─ Name:          Untitled
   ├─ Key:           abc12345
   ├─ Size:          1024 bytes
   ├─ Format:        text
   ├─ Privacy:       Public
   ├─ Expiration:    Never
   └─ Authenticated: False

🔗 URLs:
   ├─ Paste URL:     https://pastebin.com/abc12345
   └─ Raw URL:       https://pastebin.com/raw/abc12345
```

### Example 2: Upload Text Directly

```bash
python3 pastebininit --api-key YOUR_API_KEY --content "Hello, World!"
```

### Example 3: Add a Title

```bash
python3 pastebininit --api-key YOUR_API_KEY \
  --content myfile.txt \
  --name "Important Configuration"
```

### Example 4: Syntax Highlighting

```bash
# Python code
python3 pastebininit --api-key YOUR_API_KEY \
  --content script.py \
  --format python \
  --name "Python Script"

# JavaScript
python3 pastebininit --api-key YOUR_API_KEY \
  --content app.js \
  --format javascript \
  --name "Node.js App"

# Bash script
python3 pastebininit --api-key YOUR_API_KEY \
  --content deploy.sh \
  --format bash \
  --name "Deployment Script"

# JSON data
python3 pastebininit --api-key YOUR_API_KEY \
  --content data.json \
  --format json \
  --name "Configuration Data"

# SQL query
python3 pastebininit --api-key YOUR_API_KEY \
  --content query.sql \
  --format sql \
  --name "Database Query"
```

## Privacy and Expiration

### Example 5: Unlisted Paste

Accessible via URL but not shown in public listings:

```bash
python3 pastebininit --api-key YOUR_API_KEY \
  --content myfile.txt \
  --privacy 1
```

### Example 6: Temporary Paste (Expires in 1 Hour)

```bash
python3 pastebininit --api-key YOUR_API_KEY \
  --content temp_notes.txt \
  --name "Temporary Notes" \
  --expiration 1H
```

### Example 7: Daily Backup (Expires in 1 Day)

```bash
python3 pastebininit --api-key YOUR_API_KEY \
  --content backup.sql \
  --name "Daily Backup $(date +%Y-%m-%d)" \
  --expiration 1D
```

## Private Pastes (Requires Authentication)

### Example 8: Private Paste

Only visible to you:

```bash
python3 pastebininit --api-key YOUR_API_KEY \
  --username your_username \
  --password your_password \
  --content secret.txt \
  --name "Secret Data" \
  --privacy 2
```

### Example 9: Private with Expiration

```bash
python3 pastebininit --api-key YOUR_API_KEY \
  --username your_username \
  --password your_password \
  --content credentials.txt \
  --privacy 2 \
  --expiration 1H
```

## Automation and Scripting

### Example 10: Quiet Mode (Just Get the URL)

Perfect for automation:

```bash
URL=$(python3 pastebininit --api-key YOUR_API_KEY --content file.txt --quiet)
echo "Paste available at: $URL"
```

### Example 11: JSON Output

For parsing in scripts:

```bash
python3 pastebininit --api-key YOUR_API_KEY \
  --content data.txt \
  --json | jq '.paste_url'
```

### Example 12: Monitor and Upload Logs

```bash
#!/bin/bash
# Upload error log and send URL via email

LOG_FILE="/var/log/app.log"
API_KEY="your_api_key"

echo "Uploading log..."
PASTE_URL=$(python3 pastebininit \
  --api-key "$API_KEY" \
  --content "$LOG_FILE" \
  --name "App Error Log $(date)" \
  --quiet)

echo "Log uploaded: $PASTE_URL"

# Send email (optional)
echo "Error log: $PASTE_URL" | mail -s "App Error" admin@example.com
```

### Example 13: Git Integration

```bash
#!/bin/bash
# Create a paste from git diff

git diff > /tmp/changes.diff

python3 pastebininit \
  --api-key YOUR_API_KEY \
  --content /tmp/changes.diff \
  --name "Git Diff $(date)" \
  --format diff \
  --quiet
```

## Real-World Use Cases

### Example 14: Share Error Logs from Server

```bash
# Upload recent errors from a console-only server
ssh user@server \
  "tail -n 100 /var/log/error.log | python3 pastebininit \
  --api-key KEY \
  --content /dev/stdin \
  --name 'Server Errors' \
  --quiet"
```

### Example 15: Backup Configuration Files

```bash
#!/bin/bash
# Backup important config files privately

CONFIGS=(
  "/etc/nginx/nginx.conf"
  "/etc/mysql/my.cnf"
  "/etc/postgresql/postgresql.conf"
)

for config in "${CONFIGS[@]}"; do
  if [ -f "$config" ]; then
    echo "Backing up $config..."
    python3 pastebininit \
      --api-key $PASTEBIN_KEY \
      --username $PASTEBIN_USER \
      --password $PASTEBIN_PASS \
      --content "$config" \
      --name "Backup: $(basename $config) $(date)" \
      --privacy 2 \
      --quiet
  fi
done
```

### Example 16: Share Code for Code Review

```bash
# Create a paste from a specific git commit
git show abc123def456 > /tmp/commit.patch

python3 pastebininit \
  --api-key YOUR_API_KEY \
  --content /tmp/commit.patch \
  --name "Code Review: Commit abc123d" \
  --format diff
```

### Example 17: CI/CD Pipeline Integration

```bash
# In .github/workflows/build.yml
- name: Upload build log on failure
  if: failure()
  run: |
    python3 pastebininit \
      --api-key ${{ secrets.PASTEBIN_API_KEY }} \
      --content build.log \
      --name "Build Failed: $(date)" \
      --privacy 1 \
      --quiet
```

### Example 18: Share Database Dump

```bash
# Create a paste from mysqldump
mysqldump -u user -p database | python3 pastebininit \
  --api-key YOUR_API_KEY \
  --content /dev/stdin \
  --name "Database Dump $(date +%Y-%m-%d)" \
  --format sql \
  --privacy 1 \
  --quiet
```

## Using Environment Variables

### Example 19: Secure API Key Management

```bash
# Store in ~/.bashrc or ~/.zshrc
export PASTEBIN_API_KEY="your_api_key_here"
export PASTEBIN_USER="your_username"
export PASTEBIN_PASS="your_password"

# Then use in scripts without exposing the key
python3 pastebininit \
  --api-key $PASTEBIN_API_KEY \
  --content file.txt
```

### Example 20: Function for Easy Usage

```bash
# Add to ~/.bashrc
pastebin() {
    python3 /path/to/pastebininit \
        --api-key "$PASTEBIN_API_KEY" \
        "$@"
}

# Now use simply as:
pastebin --content file.txt --name "My Paste"
```

## Advanced Examples

### Example 21: Compress and Upload Large Files

```bash
#!/bin/bash
# Compress, then upload

FILE="large_file.txt"
COMPRESSED="/tmp/${FILE}.gz"

# Compress
gzip -c "$FILE" | base64 > "$COMPRESSED"

# Upload
python3 pastebininit \
  --api-key YOUR_API_KEY \
  --content "$COMPRESSED" \
  --name "Compressed: $FILE" \
  --format text
```

### Example 22: Create Paste from Command Output

```bash
# Upload system information
echo "=== System Info ===" > /tmp/sysinfo.txt
uname -a >> /tmp/sysinfo.txt
df -h >> /tmp/sysinfo.txt
ps aux >> /tmp/sysinfo.txt

python3 pastebininit \
  --api-key YOUR_API_KEY \
  --content /tmp/sysinfo.txt \
  --name "System Information" \
  --privacy 1
```

### Example 23: Batch Upload Multiple Files

```bash
#!/bin/bash
# Upload all .log files

for logfile in *.log; do
  echo "Uploading $logfile..."
  python3 pastebininit \
    --api-key YOUR_API_KEY \
    --content "$logfile" \
    --name "Log: $logfile" \
    --quiet
done
```

### Example 24: Generate Shareable Link

```bash
#!/bin/bash
# Create paste and put URL in clipboard

URL=$(python3 pastebininit \
  --api-key YOUR_API_KEY \
  --content file.txt \
  --quiet)

# Copy to clipboard (Linux)
echo "$URL" | xclip -selection clipboard

# Or copy to clipboard (macOS)
# echo "$URL" | pbcopy

echo "Copied to clipboard: $URL"
```

## Tips and Tricks

### Tip 1: Create Alias for Easy Access

```bash
# Add to ~/.bashrc
alias pb='python3 /path/to/pastebininit --api-key $PASTEBIN_API_KEY'

# Then use:
pb --content file.txt --name "Quick Paste"
```

### Tip 2: Pipe Command Output

```bash
# Some commands don't work with pipes, but you can use process substitution
python3 pastebininit \
  --api-key YOUR_API_KEY \
  --content <(ls -la /var/log) \
  --name "Directory Listing"
```

### Tip 3: One-Liner for Quick Sharing

```bash
echo "Your text here" | python3 pastebininit --api-key KEY --content /dev/stdin --quiet
```

### Tip 4: Share Your Script Before Running It

```bash
# Review before executing
python3 pastebininit --api-key KEY --content deploy.sh --format bash --quiet
```

---

For more help, run: `python3 pastebininit --help`
