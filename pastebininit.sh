#!/bin/bash

set -euo pipefail 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color


PASTEBIN_API_URL="https://pastebin.com/api/api_post.php"

# variables
PASTE_FILE=""
API_KEY=""
PASTE_NAME=""
PASTE_FORMAT="text"
PASTE_PRIVACY="0"  # 0=Public, 1=Unlisted, 2=Private (needs API key)
PASTE_EXPIRATION="N"  # N=Never, 10M, 1H, 1D, 1W, 2W, 1M
VERBOSE=false


usage() {
    cat << EOF
${BLUE}PastebinInit - Upload to Pastebin from CLI${NC}

${CYAN}USAGE:${NC}
    pastebininit [OPTIONS]

${CYAN}OPTIONS:${NC}
    -f, --file FILE              File to upload (required)
    -n, --name NAME              Paste name/title (default: filename)
    -a, --api-key KEY            Pastebin API key (optional)
    -l, --language LANG          Syntax highlighting language
                                 Examples: python, bash, javascript, c, java, etc.
    -p, --privacy LEVEL          Privacy: 0=Public, 1=Unlisted, 2=Private
                                 (default: 0, Private needs API key)
    -e, --expiration TIME        Expiration: N=Never, 10M, 1H, 1D, 1W, 2W, 1M
                                 (default: N)
    -v, --verbose                Show debug output
    -h, --help                   Show this help

${CYAN}EXAMPLES:${NC}
    # Guest upload with syntax highlighting
    pastebininit -f script.py -n "Script121" -l python

    # Private paste with API key
    pastebininit -f config.txt -a API_KEY -p 2 -e 1W

    # Expiring paste
    pastebininit -f data.json -n "Temporary Data" -l json -e 1H

${CYAN}NOTES:${NC}
    - API key is optional - guest uploads work fine
    - Private pastes need a valid API key

EOF
    exit 0
}

# Print colored messages
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

debug() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

# Check if file exists and is readable
validate_file() {
    if [[ ! -f "$1" ]]; then
        error "File not found: $1"
        exit 1
    fi
    
    if [[ ! -r "$1" ]]; then
        error "File not readable: $1"
        exit 1
    fi
    
    debug "File validated: $1"
}

# Get file size in bytes (cross-platform)
get_file_size() {
    local file="$1"
    if command -v stat &> /dev/null; then
        # Try macOS format first, then Linux
        stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null
    else
        # Fallback
        wc -c < "$file"
    fi
}

# Convert bytes to human-readable
format_size() {
    local bytes=$1
    if (( bytes < 1024 )); then
        echo "${bytes} B"
    elif (( bytes < 1048576 )); then
        echo "$((bytes / 1024)) KB"
    else
        echo "$((bytes / 1048576)) MB"
    fi
}

# Get current timestamp
get_timestamp() {
    if command -v date &> /dev/null; then
        date -u +"%Y-%m-%dT%H:%M:%S.%N" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S"
    fi
}

# API key validation
validate_api_key() {
    if [[ ${#1} -lt 32 ]]; then
        warning "API key looks short (${#1} chars). Is it correct?"
    fi
}


# Main upload function
upload_to_pastebin() {
    local start_time=$(date +%s%N)
    
    info "Preparing upload..."
    debug "Paste File: $PASTE_FILE"
    debug "Paste Name: $PASTE_NAME"
    debug "Format: $PASTE_FORMAT"
    debug "Privacy Level: $PASTE_PRIVACY"
    debug "Expiration: $PASTE_EXPIRATION"
    debug "Authenticated: $([[ -n "$API_KEY" ]] && echo "Yes" || echo "No")"
    
    # Read file content
    local paste_content
    paste_content=$(cat "$PASTE_FILE")
    
    # Build POST data - URL encode everything
    local post_data="api_dev_key=&api_option=paste&api_paste_code=$(echo -n "$paste_content" | jq -sRr @uri)&api_paste_name=$(echo -n "$PASTE_NAME" | jq -sRr @uri)&api_paste_format=$PASTE_FORMAT&api_paste_private=$PASTE_PRIVACY&api_paste_expire_date=$PASTE_EXPIRATION"
    
    # Add API key if provided
    if [[ -n "$API_KEY" ]]; then
        post_data="api_dev_key=$(echo -n "$API_KEY" | jq -sRr @uri)&api_option=paste&api_paste_code=$(echo -n "$paste_content" | jq -sRr @uri)&api_paste_name=$(echo -n "$PASTE_NAME" | jq -sRr @uri)&api_paste_format=$PASTE_FORMAT&api_paste_private=$PASTE_PRIVACY&api_paste_expire_date=$PASTE_EXPIRATION"
    fi
    
    debug "POST data prepared"
    
    # Upload via curl
    info "Uploading to Pastebin..."
    
    local response
    local http_code
    local temp_file
    temp_file=$(mktemp)
    
    trap "rm -f $temp_file" EXIT
    
    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        error "curl is required but not installed"
        error "Install curl and try again"
        exit 1
    fi
    
    # Make the request
    http_code=$(curl -s -w "%{http_code}" -X POST \
        -d "$post_data" \
        -o "$temp_file" \
        "$PASTEBIN_API_URL" 2>/dev/null || echo "000")
    
    response=$(cat "$temp_file")
    
    local end_time=$(date +%s%N)
    local duration=$(echo "scale=3; ($end_time - $start_time) / 1000000000" | bc 2>/dev/null || echo "N/A")
    
    debug "HTTP Status Code: $http_code"
    debug "Response: $response"
    
    # Check for errors
    if [[ "$http_code" != "200" ]]; then
        error "Upload failed with HTTP status: $http_code"
        if [[ "$response" == *"Bad API request"* ]]; then
            error "Invalid API request. Check your credentials."
        fi
        exit 1
    fi
    
    # Pastebin sometimes returns 200 even on errors
    if [[ "$response" == *"Bad API request"* ]] || [[ "$response" == *"invalid"* ]]; then
        error "API Error: $response"
        exit 1
    fi
    
    # Response should be a paste key (alphanumeric)
    if ! [[ "$response" =~ ^[a-zA-Z0-9]+$ ]]; then
        error "Unexpected response from Pastebin: $response"
        exit 1
    fi
    
    # Show success
    display_success_message "$response" "$duration" "$http_code"
}

# Pretty success output
display_success_message() {
    local paste_key="$1"
    local duration="$2"
    local http_code="$3"
    
    local file_size
    file_size=$(get_file_size "$PASTE_FILE")
    local formatted_size
    formatted_size=$(format_size "$file_size")
    
    local timestamp
    timestamp=$(get_timestamp)
    
    local is_authenticated
    if [[ -n "$API_KEY" ]]; then
        is_authenticated="Yes"
    else
        is_authenticated="No (Guest)"
    fi
    
    # Human-readable labels
    local privacy_label
    case "$PASTE_PRIVACY" in
        0) privacy_label="Public" ;;
        1) privacy_label="Unlisted" ;;
        2) privacy_label="Private" ;;
        *) privacy_label="Unknown" ;;
    esac
    
    local expiration_label
    case "$PASTE_EXPIRATION" in
        N) expiration_label="Never" ;;
        10M) expiration_label="10 Minutes" ;;
        1H) expiration_label="1 Hour" ;;
        1D) expiration_label="1 Day" ;;
        1W) expiration_label="1 Week" ;;
        2W) expiration_label="2 Weeks" ;;
        1M) expiration_label="1 Month" ;;
        *) expiration_label="$PASTE_EXPIRATION" ;;
    esac
    
    cat << EOF


${GREEN}$(printf '=%.0s' {1..70})${NC}
${GREEN}🎉 PASTE UPLOADED SUCCESSFULLY!${NC}
${GREEN}$(printf '=%.0s' {1..70})${NC}

${CYAN}📋 Paste Details:${NC}
   ${BLUE}└─${NC} Name:            ${YELLOW}$PASTE_NAME${NC}
   ${BLUE}└─${NC} Key:             ${YELLOW}$paste_key${NC}
   ${BLUE}└─${NC} Size:            ${YELLOW}$formatted_size${NC}
   ${BLUE}└─${NC} Format:          ${YELLOW}$PASTE_FORMAT${NC}
   ${BLUE}└─${NC} Privacy:         ${YELLOW}$privacy_label${NC}
   ${BLUE}└─${NC} Expiration:      ${YELLOW}$expiration_label${NC}
   ${BLUE}└─${NC} Authenticated:   ${YELLOW}$is_authenticated${NC}

${CYAN}🔗 URLs:${NC}
   ${BLUE}└─${NC} Paste URL:       ${YELLOW}https://pastebin.com/$paste_key${NC}
   ${BLUE}└─${NC} Raw URL:         ${YELLOW}https://pastebin.com/raw/$paste_key${NC}

${CYAN}⏱️  Performance:${NC}
   ${BLUE}└─${NC} Status Code:     ${YELLOW}$http_code${NC}
   ${BLUE}└─${NC} Duration:        ${YELLOW}${duration}s${NC}
   ${BLUE}└─${NC} Timestamp:       ${YELLOW}$timestamp${NC}

${GREEN}$(printf '=%.0s' {1..70})${NC}

EOF
}


# Parse command line args
parse_arguments() {
    if [[ $# -eq 0 ]]; then
        usage
    fi
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--file)
                PASTE_FILE="$2"
                shift 2
                ;;
            -n|--name)
                PASTE_NAME="$2"
                shift 2
                ;;
            -a|--api-key)
                API_KEY="$2"
                validate_api_key "$API_KEY"
                shift 2
                ;;
            -l|--language)
                PASTE_FORMAT="$2"
                shift 2
                ;;
            -p|--privacy)
                PASTE_PRIVACY="$2"
                if ! [[ "$PASTE_PRIVACY" =~ ^[0-2]$ ]]; then
                    error "Privacy must be 0 (Public), 1 (Unlisted), or 2 (Private)"
                    exit 1
                fi
                # Private needs API key
                if [[ "$PASTE_PRIVACY" == "2" && -z "$API_KEY" ]]; then
                    error "Private pastes require an API key (-a/--api-key)"
                    exit 1
                fi
                shift 2
                ;;
            -e|--expiration)
                PASTE_EXPIRATION="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                error "Unknown option: $1"
                echo "Use -h or --help for usage"
                exit 1
                ;;
        esac
    done
}


# Validate everything before uploading
validate_requirements() {
    # File is required
    if [[ -z "$PASTE_FILE" ]]; then
        error "Paste file is required (-f/--file)"
        exit 1
    fi
    
    # Check if file is valid
    validate_file "$PASTE_FILE"
    
    # Use filename if no name provided
    if [[ -z "$PASTE_NAME" ]]; then
        PASTE_NAME=$(basename "$PASTE_FILE")
    fi
    
    # Check for required tools
    for cmd in curl jq bc; do
        if ! command -v "$cmd" &> /dev/null; then
            case "$cmd" in
                curl)
                    error "curl is required but not installed"
                    ;;
                jq)
                    error "jq is required but not installed"
                    ;;
                bc)
                    warning "bc is recommended for timing calculation"
                    ;;
            esac
        fi
    done
}


# Main entry point
main() {
    parse_arguments "$@"
    validate_requirements
    upload_to_pastebin
}

# Run it
main "$@"