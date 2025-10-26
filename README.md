# Pastebininit

A Bash script for uploading pastes to [Pastebin](https://pastebin.com) from the CLI.

**Contents**
- [Features](#features)
- [Platforms](#platform-support)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start Commands](#quick-start)
- [Usage](#usage)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)



---

## Features

- Upload pastes directly from terminal
- Syntax highlighting for 100+ languages
- Optional API key for auth features
- Guest uploads work fine (no registration needed)
- Set expiration times

---

## Platform Support

| Platform | Method |
|----------|--------|
| **Linux** | Native bash |
| **macOS** | Native bash (both Intel & Apple silicone ) |
| **Windows** | Via Git Bash or WSL |

## Requirements

### You need:
- **Bash** 4.0+
- **curl** - for HTTP requests
- **jq** - for URL encoding and JSON

### System Requirements:
- Linux (any)
- macOS
- Windows (Via Git Bash or WSL)
- About 1MB free space
- Internet connection

### Installing Dependencies

**Ubuntu/Debian:**
```bash
sudo apt-get install bash curl jq bc
```

**macOS:**
```bash
brew install curl jq bc
```

**Alpine:**
```bash
apk add bash curl jq bc
```

**CentOS/RHEL:**
```bash
sudo yum install bash curl jq bc
```

**Arch:**
```bash
sudo pacman -S bash curl jq bc
```

---


## Installation

### Linux & macOS

**Quick install (easiest)**
```bash
git clone https://github.com/himanshuksr0007/pastebininit.git
cd pastebininit
sudo ./install.sh
```

Verify it worked:
```bash
pastebininit --help
```

**Manual install to system PATH**
```bash
git clone https://github.com/himanshuksr0007/pastebininit.git
cd pastebininit

# Make it executable
chmod +x pastebininit.sh

# Install system-wide
sudo cp pastebininit.sh /usr/local/bin/pastebininit
```

Check it:
```bash
pastebininit --help
```

**Just run it directly (no install)**
```bash
git clone https://github.com/himanshuksr0007/pastebininit.git
cd pastebininit

chmod +x pastebininit.sh
./pastebininit.sh -f path/to/file -n "Paste121" -l python

# Or without chmod
bash pastebininit.sh -f path/to/file -n "Paste121" -l python
```

---

### Windows

**WSL (recommended if on windows)**
```bash
# In WSL terminal
git clone https://github.com/himanshuksr0007/pastebininit.git
cd pastebininit
sudo ./install.sh
```

Verify:
```bash
pastebininit --help
```

**Git Bash**
```bash
git clone https://github.com/himanshuksr0007/pastebininit.git
cd pastebininit

# Run via Git bash
bash pastebininit.sh -f path/to/file.txt -n "My Paste" -l python
```

**Adding to PATH in Git Bash (optional)**

1. Copy the script somewhere
2. Add to `~/.bashrc`:
```bash
export PATH="$PATH:/c/Users/Username/path/to/pastebininit"
```

3. Reload:
```bash
source ~/.bashrc
```

4. Run:
```bash
bash pastebininit.sh -f file.txt
```

---


## Quick Start

### Basic (Guest Upload)

```bash
# Upload a file
pastebininit -f script.py

# With a custom name
pastebininit -f script.py -n "My Python Script"

# With syntax highlighting
pastebininit -f script.py -l python
```

### With API Key

```bash
# Get your key from https://pastebin.com/api

# Upload with auth
pastebininit -f config.txt -a API_KEY_HERE

# Private paste
pastebininit -f secrets.env -a API_KEY -p 2
```
---

## Usage

### Command

```bash
pastebininit [OPTIONS]
```

### Options

| Option | Long Form | What it does | Default | Notes |
|--------|-----------|-------------|---------|-------|
| `-f` | `--file` | File to upload | Required | Must be readable |
| `-n` | `--name` | Paste title | Filename | Custom name |
| `-a` | `--api-key` | Pastebin API key | None | Optional |
| `-l` | `--language` | Syntax highlighting | `text` | See list below |
| `-p` | `--privacy` | Privacy level | `0` (Public) | 0=Public, 1=Unlisted, 2=Private* |
| `-e` | `--expiration` | When paste expires | `N` (Never) | N, 10M, 1H, 1D, 1W, 2W, 1M |
| `-v` | `--verbose` | Debug output | Off | Shows details |
| `-h` | `--help` | Show help | - | Usage info |


### Syntax Highlighting

Syntax highlighting for the programming languages.

---

## Configuration

### API Key Setup

1. **Get your key:**
   - Visit [Pastebin](https://pastebin.com/api)
   - Sign in
   - Generate an API key

2. **Use it:**
   ```bash
   pastebininit -f file.txt -a API_KEY_HERE
   ```

3. **Store in env variable (optional):**
   ```bash
   export PASTEBIN_API_KEY="API_KEY_HERE"
   pastebininit -f file.txt -a "$PASTEBIN_API_KEY"
   ```

### Privacy Levels

- **Public (0):** Everyone can see it, searchable
- **Unlisted (1):** Only via direct link, not searchable
- **Private (2):** Only for authenticated users (needs API key)

### Expiration Times

| Value | Duration |
|-------|----------|
| `N` | No expiry |
| `10M` | 10 minutes |
| `1H` | 1 hour |
| `1D` | 1 day |
| `1W` | 1 week |
| `2W` | 2 weeks |
| `1M` | 1 month |

---

## Troubleshooting

### "curl is required but not installed"

Install it:
```bash
# Ubuntu/Debian
sudo apt-get install curl

# macOS
brew install curl

# Alpine
apk add curl
```

### "jq is required but not installed"

Install it:
```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq

# Alpine
apk add jq
```

### "Upload failed with HTTP status: 403"

Possible issues:
- Bad API key
- Rate limited
- Account suspended

Fix:
- Check your key at [https://pastebin.com/api](https://pastebin.com/api)
- Wait a bit and retry
- Check account status

### "Private pastes require an API key"

Either use public/unlisted:
```bash
pastebininit -f file.txt -p 1  # Unlisted
```

Or add your API key:
```bash
pastebininit -f file.txt -p 2 -a YOUR_KEY
```

### "Permission denied" when running

Make it executable:
```bash
chmod +x pastebininit.sh

# Or just use bash
bash pastebininit.sh -f file.txt
```

### Command not found after install

Check PATH:
```bash
echo $PATH

# System install
which pastebininit

# User install - make sure ~/.local/bin is in PATH
export PATH="$HOME/.local/bin:$PATH"
source ~/.bashrc

# Or use full path
/usr/local/bin/pastebininit -f file.txt
```

### Git Bash won't execute with ./script.sh

Just use bash explicitly:
```bash
bash pastebininit.sh -f file.txt

# Or fix line endings
git config core.autocrlf false
git update-index --chmod=+x pastebininit.sh
```

### Encoding errors or weird characters

Make sure it's UTF-8:
```bash
file your_file.txt

# Convert if needed
iconv -f ISO-8859-1 -t UTF-8 your_file.txt > your_file_utf8.txt
pastebininit -f your_file_utf8.txt
```

---
*Please Star this repo if you liked it*