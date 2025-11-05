# PastebinInit - Pastebin CLI Uploader

``` this readme has been generate via the use of AI ```

A Bash script for uploading pastes to [Pastebin](https://pastebin.com) from the CLI.

## Quick Start

### 1. Get Your API Key

The Pastebin requires a API key for all uploads
---

### LINUX / macOS INSTALLATION

#### Step 1: Clone the Repository

```bash
cd ~

git clone https://github.com/himanshuksr0007/pastebininit.git

cd pastebininit

bash install.sh
```
---

#### Step 2: Verify Installation

```bash
 pastebininit --help
```
---

### WINDOWS - WSL  INSTALLATION

```
Same as linux
```

---

### WINDOWS - Git Bash INSTALLATION

#### Step 1: Clone Repository

```bash
cd ~

cd /c/Users/Username/Desktop

git clone https://github.com/himanshuksr0007/pastebininit.git

cd pastebininit
```

---

#### Step 2: Install Dependencies

```bash
pip install requests
```

---

#### Step 3: Make Script Executable

```bash
chmod +x pastebininit
```

---

## Usage examples

```bash
Please refer to example.md
```

## Command-Line Options

### Required Arguments

| Argument | Description |
|----------|-------------|
| `--api-key` | Your Pastebin API developer key |
| `--content` | File path or direct text content |

### Optional Arguments

| Argument | Options | Default | Description |
|----------|---------|---------|-------------|
| `--name` | Any string | None | Paste title |
| `--format` | See formats | `text` | Syntax highlighting |
| `--privacy` | `0`, `1`, `2` | `0` | Privacy level |
| `--expiration` | See expirations | `N` | Expiration time |
| `--username` | Username | None | For authentication |
| `--password` | Password | None | For authentication |

### Output Options

| Argument | Description |
|----------|-------------|
| `--json` | Output result as JSON |
| `--quiet` | Minimal output (URL only) |

## Privacy Levels

- `0` = **Public** - Visible in public listings
- `1` = **Unlisted** - Accessible via URL only
- `2` = **Private** - Only visible to you

## Expiration Options

- `N` = Never (default)
- `10M` = 10 Minutes
- `1H` = 1 Hour
- `1D` = 1 Day
- `1W` = 1 Week
- `2W` = 2 Weeks
- `1M` = 1 Month
- `6M` = 6 Months
- `1Y` = 1 Year

## Supported Syntax Formats

**Most common:** text, python, javascript, java, bash, c, cpp, csharp, php, ruby, go, rust, json, yaml, sql, html, css, markdown, xml

**Also supported:** 190+ programming and markup languages

Use lowercase format names (e.g., `--format python`, not `--format Python`).


## Environment Variables

For security, use environment variables instead of command-line:

```bash
# Set in shell
export PASTEBIN_API_KEY="your_key_here"

# Or in ~/.bashrc for permanent setup
echo 'export PASTEBIN_API_KEY="your_key_here"' >> ~/.bashrc
source ~/.bashrc
```

Then use in commands:
```bash
pastebininit --api-key $PASTEBIN_API_KEY --content file.txt
```
