#!/usr/bin/env python3
"""
PastebinInit - Pastebin CLI Uploader
====================================
Upload pastes to Pastebin.com using the official API.

Requirements:
    - Pastebin API key (free - get from https://pastebin.com/doc_api)
    - Python 3.6+
    - requests library

Author: Open Source Community
License: MIT
"""

import argparse
import sys
import os
import requests
from datetime import datetime
from typing import Optional, Dict, Any
import json


class PastebinUploader:
    """Handle Pastebin API uploads."""

    API_POST_URL = "https://pastebin.com/api/api_post.php"
    API_LOGIN_URL = "https://pastebin.com/api/api_login.php"

    VALID_EXPIRATIONS = {
        'N': 'Never',
        '10M': '10 Minutes',
        '1H': '1 Hour',
        '1D': '1 Day',
        '1W': '1 Week',
        '2W': '2 Weeks',
        '1M': '1 Month',
        '6M': '6 Months',
        '1Y': '1 Year'
    }

    VALID_PRIVACY = {
        '0': 'Public',
        '1': 'Unlisted',
        '2': 'Private'
    }

    FORMAT_MAP = {
        'text': '0', 'python': '1', 'bash': '2', 'c': '3', 'cpp': '4',
        'javascript': '5', 'java': '6', 'php': '7', 'html': '8', 'sql': '9',
        'css': '10', 'json': '11', 'yaml': '12', 'xml': '13', 'markdown': '14',
        'ruby': '15', 'go': '16', 'rust': '17', 'typescript': '18', 'lua': '19',
        'kotlin': '20', 'swift': '21', 'csharp': '22', 'r': '23', 'perl': '24',
    }

    def __init__(self, api_dev_key: str):
        """
        Initialize uploader with API key.

        Args:
            api_dev_key: Your Pastebin API developer key (required)
        """
        if not api_dev_key or not api_dev_key.strip():
            raise ValueError("API developer key is required. Get one from https://pastebin.com/doc_api")

        self.api_key = api_dev_key.strip()
        self.user_key = None
        self.session = requests.Session()

    def login(self, username: str, password: str) -> Dict[str, Any]:
        """
        Authenticate with Pastebin to enable private pastes.

        Args:
            username: Pastebin username
            password: Pastebin password

        Returns:
            Dictionary with success status
        """
        start_time = datetime.now()

        params = {
            'api_dev_key': self.api_key,
            'api_user_name': username,
            'api_user_password': password
        }

        try:
            response = self.session.post(self.API_LOGIN_URL, data=params, timeout=30)
            end_time = datetime.now()
            duration = (end_time - start_time).total_seconds()

            if response.text.startswith("Bad API request"):
                return {
                    'success': False,
                    'error': response.text,
                    'duration_seconds': duration,
                    'timestamp': end_time.isoformat()
                }

            self.user_key = response.text.strip()
            return {
                'success': True,
                'user_key': self.user_key,
                'duration_seconds': duration,
                'timestamp': end_time.isoformat()
            }

        except requests.exceptions.RequestException as e:
            end_time = datetime.now()
            return {
                'success': False,
                'error': f"Request failed: {str(e)}",
                'duration_seconds': (end_time - start_time).total_seconds(),
                'timestamp': end_time.isoformat()
            }

    def create_paste(self, code: str, name: Optional[str] = None,
                    format_lang: str = 'text', privacy: str = '0',
                    expiration: str = 'N') -> Dict[str, Any]:
        """
        Create a paste on Pastebin.

        Args:
            code: The paste content
            name: Paste title (optional)
            format_lang: Syntax highlighting format (default: text)
            privacy: 0=Public, 1=Unlisted, 2=Private (requires authentication)
            expiration: Expiration time (default: Never)

        Returns:
            Dictionary with upload result
        """
        start_time = datetime.now()

        # Get format code
        format_code = self.FORMAT_MAP.get(format_lang.lower(), format_lang)

        # Build request parameters
        params = {
            'api_option': 'paste',
            'api_dev_key': self.api_key,
            'api_paste_code': code,
            'api_paste_private': privacy,
            'api_paste_expire_date': expiration,
            'api_paste_format': format_code
        }

        if name:
            params['api_paste_name'] = name

        if self.user_key:
            params['api_user_key'] = self.user_key

        try:
            response = self.session.post(self.API_POST_URL, data=params, timeout=30)
            end_time = datetime.now()
            duration = (end_time - start_time).total_seconds()

            # Check for errors
            if response.status_code != 200 or response.text.startswith("Bad API request"):
                return {
                    'success': False,
                    'error': response.text if response.text else f"HTTP {response.status_code}",
                    'status_code': response.status_code,
                    'duration_seconds': duration,
                    'timestamp': end_time.isoformat()
                }

            # Success
            paste_url = response.text.strip()
            paste_key = paste_url.split('/')[-1] if '/' in paste_url else ''

            return {
                'success': True,
                'paste_url': paste_url,
                'paste_key': paste_key,
                'raw_url': f"https://pastebin.com/raw/{paste_key}",
                'status_code': response.status_code,
                'duration_seconds': duration,
                'timestamp': end_time.isoformat(),
                'paste_name': name or 'Untitled',
                'paste_format': format_lang,
                'paste_privacy': self.VALID_PRIVACY.get(privacy, 'Unknown'),
                'paste_expiration': self.VALID_EXPIRATIONS.get(expiration, 'Unknown'),
                'paste_size_bytes': len(code.encode('utf-8')),
                'authenticated': bool(self.user_key)
            }

        except requests.exceptions.RequestException as e:
            end_time = datetime.now()
            return {
                'success': False,
                'error': f"Request failed: {str(e)}",
                'duration_seconds': (end_time - start_time).total_seconds(),
                'timestamp': end_time.isoformat()
            }


def read_paste_content(source: str) -> Optional[str]:
    """Read paste content from file or direct text."""
    if os.path.isfile(source):
        try:
            with open(source, 'r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            print(f"✗ Error reading file '{source}': {e}")
            return None
    else:
        return source


def print_success_message(result: Dict[str, Any]) -> None:
    """Print detailed success message."""
    print("\n" + "="*70)
    print("✓ PASTE UPLOADED SUCCESSFULLY!")
    print("="*70)
    print(f"\n📋 Paste Details:")
    print(f"   ├─ Name:         {result.get('paste_name', 'N/A')}")
    print(f"   ├─ Key:          {result.get('paste_key', 'N/A')}")
    print(f"   ├─ Size:         {result.get('paste_size_bytes', 0)} bytes")
    print(f"   ├─ Format:       {result.get('paste_format', 'N/A')}")
    print(f"   ├─ Privacy:      {result.get('paste_privacy', 'N/A')}")
    print(f"   ├─ Expiration:   {result.get('paste_expiration', 'N/A')}")
    print(f"   └─ Authenticated: {result.get('authenticated', False)}")

    print(f"\n🔗 URLs:")
    print(f"   ├─ Paste URL:    {result.get('paste_url', 'N/A')}")
    print(f"   └─ Raw URL:      {result.get('raw_url', 'N/A')}")

    print(f"\n⏱️  Performance:")
    print(f"   ├─ Status Code:  {result.get('status_code', 'N/A')}")
    print(f"   ├─ Duration:     {result.get('duration_seconds', 0):.3f} seconds")
    print(f"   └─ Timestamp:    {result.get('timestamp', 'N/A')}")

    print("\n" + "="*70 + "\n")


def print_error_message(result: Dict[str, Any]) -> None:
    """Print detailed error message."""
    print("\n" + "="*70)
    print("✗ UPLOAD FAILED")
    print("="*70)
    print(f"\n⚠️  Error Details:")
    print(f"   ├─ Error:        {result.get('error', 'Unknown error')}")
    print(f"   ├─ Status Code:  {result.get('status_code', 'N/A')}")
    print(f"   ├─ Duration:     {result.get('duration_seconds', 0):.3f} seconds")
    print(f"   └─ Timestamp:    {result.get('timestamp', 'N/A')}")

    print("\n💡 Troubleshooting:")
    error = result.get('error', '')
    if "invalid api_dev_key" in error.lower():
        print("   • Invalid API key")
        print("   • Get your key from: https://pastebin.com/doc_api")
        print("   • Make sure you copy the entire key without extra spaces")
    elif "422" in str(result.get('status_code', '')):
        print("   • HTTP 422: Invalid request")
        print("   • Check that --content is not empty")
        print("   • Verify API key is valid")
    else:
        print("   • Check your internet connection")
        print("   • Verify Pastebin API is accessible")
        print("   • Check your API key validity")

    print("\n" + "="*70 + "\n")


def main():
    """Main CLI function."""
    parser = argparse.ArgumentParser(
        description='Upload pastes to Pastebin.com using the official API',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
REQUIRED - API Key:
  Get your free API key from: https://pastebin.com/doc_api

Examples:
  # Simple upload with default settings
  %(prog)s --api-key YOUR_KEY --content myfile.txt

  # Upload text directly with custom options
  %(prog)s --api-key YOUR_KEY --content "Hello World" --name "Test" --format python

  # Upload with authentication (enables private pastes)
  %(prog)s --api-key YOUR_KEY --username myuser --password mypass \
    --content file.txt --privacy 2

  # Upload with expiration
  %(prog)s --api-key YOUR_KEY --content data.txt --expiration 1H

  # Get just the URL (quiet mode)
  %(prog)s --api-key YOUR_KEY --content file.txt --quiet

Formats: text, python, javascript, java, bash, json, sql, html, css, markdown, yaml, xml, c, cpp, php, ruby, go, rust, and more

Privacy: 0=Public, 1=Unlisted, 2=Private (requires authentication)

Expiration: N=Never, 10M, 1H, 1D, 1W, 2W, 1M, 6M, 1Y
        '''
    )

    # Required
    parser.add_argument(
        '--api-key',
        required=True,
        help='Your Pastebin API developer key (REQUIRED)'
    )

    parser.add_argument(
        '--content',
        required=True,
        help='File path or direct text to paste (REQUIRED)'
    )

    # Optional paste configuration
    parser.add_argument(
        '--name',
        help='Paste title/name'
    )

    parser.add_argument(
        '--format',
        default='text',
        help='Syntax highlighting format (default: text)'
    )

    parser.add_argument(
        '--privacy',
        choices=['0', '1', '2'],
        default='0',
        help='Privacy level: 0=Public, 1=Unlisted, 2=Private (default: 0)'
    )

    parser.add_argument(
        '--expiration',
        choices=['N', '10M', '1H', '1D', '1W', '2W', '1M', '6M', '1Y'],
        default='N',
        help='Expiration time (default: N for Never)'
    )

    # Authentication for private pastes
    parser.add_argument(
        '--username',
        help='Pastebin username (for private pastes)'
    )

    parser.add_argument(
        '--password',
        help='Pastebin password (for private pastes)'
    )

    # Output options
    parser.add_argument(
        '--json',
        action='store_true',
        help='Output result as JSON'
    )

    parser.add_argument(
        '--quiet',
        action='store_true',
        help='Minimal output (URL only on success)'
    )

    args = parser.parse_args()

    # Validate API key
    try:
        uploader = PastebinUploader(args.api_key)
    except ValueError as e:
        print(f"✗ Error: {e}")
        sys.exit(1)

    # Read content
    paste_content = read_paste_content(args.content)
    if paste_content is None:
        sys.exit(1)

    if not paste_content.strip():
        print("✗ Error: Paste content is empty")
        sys.exit(1)

    if not args.quiet:
        print("ℹ Preparing upload...")

    # Authenticate if credentials provided
    if args.username and args.password:
        if not args.quiet:
            print("ℹ Authenticating...")
        auth_result = uploader.login(args.username, args.password)
        if not auth_result['success']:
            if not args.quiet:
                print(f"⚠ Authentication failed: {auth_result.get('error')}")

    # Upload
    if not args.quiet:
        print("ℹ Uploading to Pastebin...")

    result = uploader.create_paste(
        code=paste_content,
        name=args.name,
        format_lang=args.format,
        privacy=args.privacy,
        expiration=args.expiration
    )

    # Output results
    if args.json:
        print(json.dumps(result, indent=2))
    elif args.quiet:
        if result['success']:
            print(result['paste_url'])
        else:
            print(f"✗ Upload failed: {result.get('error', 'Unknown error')}", file=sys.stderr)
            sys.exit(1)
    else:
        if result['success']:
            print_success_message(result)
        else:
            print_error_message(result)
            sys.exit(1)


if __name__ == '__main__':
    main()
