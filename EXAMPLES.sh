#!/bin/bash

# PastebinInit Examples
# Real-world usage examples for uploading to Pastebin from the command line


# BASIC USAGE
# ===========

# Just upload a file
pastebininit -f script.sh

# Give it a better name
pastebininit -f backup.log -n "System Backup Log - $(date +%Y-%m-%d)"

# Add syntax highlighting
pastebininit -f config.yaml -l yaml

# Show help
pastebininit --help


# WITH API KEY
# ============

# Store your API key in a variable
PASTEBIN_KEY="YOUR_API_KEY_HERE"

# Upload with authentication
pastebininit -f credentials.env -a "$PASTEBIN_KEY"

# Make it private (only you can see it)
pastebininit -f private_config.sql -a "$PASTEBIN_KEY" -p 2 -l sql

# Unlisted (visible via link, not searchable)
pastebininit -f output.json -p 1 -l json


# EXPIRATION & PRIVACY
# ====================

# Debug log that expires in 1 hour
pastebininit -f debug.log -e 1H -n "Debug Session $(date)"

# Sensitive data that expires tomorrow
pastebininit -f temp_secrets.env -a "$PASTEBIN_KEY" -p 2 -e 1D

# Code review paste (public, expires in 1 week)
pastebininit -f pull_request.diff -p 1 -e 1W -n "PR #123 Review"

# Important docs that never expire
pastebininit -f important_docs.txt -e N -n "Reference Documentation"


# DEVELOPMENT
# ===========

# Share recent error logs
ERROR_LOG="/var/log/app.log"
tail -n 1000 "$ERROR_LOG" > recent_errors.log
pastebininit -f recent_errors.log -n "App Errors - $(date)" -l log

# Share query results
sqlite3 database.db "SELECT * FROM users LIMIT 100;" > query_results.txt
pastebininit -f query_results.txt -n "User Query Results" -l sql -p 1 -e 1W

# Upload build output
make clean build 2>&1 | tee build_output.log
pastebininit -f build_output.log -n "Build Output - v$(cat VERSION)" -e 1W

# Share config for troubleshooting
cat /etc/application/config.conf > config_to_share.conf
pastebininit -f config_to_share.conf -n "Config Debug" -p 1


# OPERATIONS
# ==========

# System diagnostics
(
  echo "=== System Info ==="
  uname -a
  echo "=== Disk Usage ==="
  df -h
  echo "=== Memory ==="
  free -h
  echo "=== Services ==="
  systemctl list-units --type service --state running
) > diagnostics.txt
pastebininit -f diagnostics.txt -n "System Diagnostics - $(hostname)" -l log

# Network diagnostics
(
  echo "=== Network Interfaces ==="
  ip addr
  echo "=== Routing ==="
  ip route
  echo "=== DNS ==="
  cat /etc/resolv.conf
) > network_diag.txt
pastebininit -f network_diag.txt -n "Network Diagnostics" -p 1 -l log

# App logs
tail -n 5000 /var/log/application/app.log > app_debug.log
pastebininit -f app_debug.log -n "App Debug Logs" -p 1 -e 1D -l log


# AUTOMATION
# ==========

# Backup script for cron jobs
backup_and_upload() {
  BACKUP_FILE="/home/user/backup_$(date +%Y%m%d_%H%M%S).tar.gz"
  tar -czf "$BACKUP_FILE" /important/data/
  pastebininit -f "$BACKUP_FILE" -n "Backup $(date)" -p 1 -e 1M
  rm "$BACKUP_FILE"
}

# Upload test results
upload_test_results() {
  TEST_REPORT="test_report_$(date +%s).txt"
  npm test > "$TEST_REPORT" 2>&1
  RESULT=$?

  if [ $RESULT -eq 0 ]; then
    pastebininit -f "$TEST_REPORT" -n "✓ Tests Passed - Build #$CI_BUILD_NUMBER" -l log -e 1W
  else
    # Keep failures longer and make private
    pastebininit -f "$TEST_REPORT" -n "✗ Tests Failed - Build #$CI_BUILD_NUMBER" -l log -e 2W -p 1
  fi
}

# Monitor system and upload metrics
upload_metrics() {
  METRICS_FILE="metrics_$(date +%Y%m%d_%H%M%S).txt"
  (
    echo "CPU: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2}')"
    echo "Memory: $(free | grep Mem | awk '{printf("%.2f%%", ($3/$2) * 100)}')"
    echo "Disk: $(df / | tail -1 | awk '{printf("%.2f%%", ($3/$2) * 100)}')"
  ) > "$METRICS_FILE"
  pastebininit -f "$METRICS_FILE" -n "System Metrics $(date)" -e 1W
}


# DATA SHARING
# ============

# Share API response
curl -s "https://api.example.com/data?limit=100" > api_response.json
pastebininit -f api_response.json -n "API Response Sample" -l json -p 1

# Share database schema
mysqldump --no-data mydb > schema.sql
pastebininit -f schema.sql -n "Database Schema - mydb" -l sql -p 1 -e 1W

# Share code snippet
cat > snippet.py << 'EOF'
def calculate_sum(numbers):
    """Calculate sum of numbers"""
    return sum(numbers)

result = calculate_sum([1, 2, 3, 4, 5])
print(f"Sum: {result}")
EOF
pastebininit -f snippet.py -n "Python Code Review" -l python


# ERROR HANDLING
# ==============

# Upload with retry logic
upload_with_retry() {
    local file=$1
    local retries=3
    local attempt=1
    
    while [ $attempt -le $retries ]; do
        if pastebininit -f "$file" -n "Attempt $attempt"; then
            echo "Upload successful"
            return 0
        fi
        echo "Attempt $attempt failed, retrying..."
        sleep 5
        ((attempt++))
    done
    
    echo "Failed after $retries attempts"
    return 1
}

# Capture command output and upload if it fails
run_and_upload_on_error() {
    local cmd=$1
    local output_file="command_output.log"
    
    if ! $cmd > "$output_file" 2>&1; then
        pastebininit -f "$output_file" -n "Command Failed: $cmd" -p 1 -e 1D
        return 1
    fi
    
    pastebininit -f "$output_file" -n "Command Output: $cmd" -p 1
    return 0
}


# BATCH OPERATIONS
# ================

# Upload multiple logs in parallel
upload_all_logs() {
  for file in *.log; do
    pastebininit -f "$file" -n "Log: $file" -l log -e 1W &
  done
  wait
}

# Upload all config files
upload_configs() {
  find . -name "*.conf" | while read file; do
    pastebininit -f "$file" -n "Config: $(basename $file)" -l conf -p 1
  done
}

# Only upload small files
upload_small_files() {
  for file in *.txt; do
    if [ $(wc -c < "$file") -lt 1000000 ]; then
      pastebininit -f "$file" -n "Document: $(basename $file)"
    fi
  done
}


# DEBUG & VERBOSE
# ===============

# Enable verbose output
pastebininit -f debug.log -v

# Debug API key issues
pastebininit -f test.txt -a "$PASTEBIN_KEY" -v


# INTEGRATIONS
# ============

# Post to Slack
send_to_slack() {
  PASTE_KEY=$(pastebininit -f report.txt 2>&1 | grep "https://pastebin.com" | head -1 | awk '{print $NF}')
  PASTE_URL="https://pastebin.com/$PASTE_KEY"

  curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"Check this report: $PASTE_URL\"}" \
    "$SLACK_WEBHOOK_URL"
}

# Email the link
email_report() {
  PASTE_URL=$(pastebininit -f report.txt 2>&1 | grep "https://pastebin.com" | head -1)
  echo "Report available at: $PASTE_URL" | \
    mail -s "Weekly Report" team@example.com
}

# Post to GitHub issue
github_comment() {
  ISSUE_NUM=42
  PASTE_URL=$(pastebininit -f error_log.txt 2>&1 | grep "https://pastebin.com" | head -1)
  gh issue comment $ISSUE_NUM --body "Error logs: $PASTE_URL"
}


# ADVANCED
# ========

# Use environment variables
export PASTEBIN_API_KEY="your_key_here"
pastebininit -f file.txt -a "$PASTEBIN_API_KEY" -p 2

# Create temp file and upload
TEMP_FILE=$(mktemp)
cat > "$TEMP_FILE" << 'EOF'
Important data that needs sharing temporarily
EOF
pastebininit -f "$TEMP_FILE" -n "Temporary Data" -e 1H
rm "$TEMP_FILE"

# Pipe to Pastebin
ls -la /var/log | head -100 > system_info.txt
pastebininit -f system_info.txt -n "System Information"