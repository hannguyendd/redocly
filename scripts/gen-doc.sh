SEPARATOR="\n${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
# Get current timestamp for unique file suffix
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# File to store failed links
FAILED_LINKS_FILE="failed_links_${TIMESTAMP}.txt"
# Clear the file at the start
> "$FAILED_LINKS_FILE"
# Color and icon definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

ICON_DOWNLOAD="📥"
ICON_SUCCESS="✅"
ICON_FAIL="❌"
ICON_DOC="📄"
ICON_INFO="ℹ️"
#!/bin/bash

# Usage: ./gen-doc [options] <url1> <url2> ...
#
# Downloads OpenAPI JSON files from URLs and generates HTML documentation using Redocly.
#
# Options:
#   -f, --file <file>   Read URLs (one per line) from a file
#   -h, --help          Show this help message and exit
#
# Environment variables:
#   DOWNLOAD_DIR        Directory to save downloaded JSON files (default: downloads)
#   OUTPUT_DIR          Directory to save generated HTML files (default: output)
#
# Examples:
#   ./gen-doc https://example.com/openapi.json
#   ./gen-doc -f links.txt
#   ./gen-doc -f links.txt https://example.com/openapi.json
#   DOWNLOAD_DIR=mydl OUTPUT_DIR=myout ./gen-doc -f links.txt


# Downloads each JSON file from the provided URLs into the 'downloads' directory.



# Parse options
LINKS=()
while [[ $# -gt 0 ]]; do
	case $1 in
		-f|--file)
			if [ -z "$2" ]; then
				echo "Error: -f|--file requires a filename argument" >&2
				exit 1
			fi
			if [ ! -f "$2" ]; then
				echo "Error: File not found: $2" >&2
				exit 1
			fi
			while IFS= read -r line; do
				[ -z "$line" ] && continue
				LINKS+=("$line")
			done < "$2"
			shift 2
			;;
		-h|--help)
			grep '^#' "$0" | sed 's/^# \{0,1\}//'
			exit 0
			;;
		*)
			LINKS+=("$1")
			shift
			;;
	esac
done

if [ ${#LINKS[@]} -eq 0 ]; then
	echo "Usage: $0 [-f links.txt] <url1> <url2> ..."
	exit 1
fi



# Use DOWNLOAD_DIR and OUTPUT_DIR from environment if set, otherwise use defaults
DOWNLOAD_DIR="${DOWNLOAD_DIR:-downloads}"
OUTPUT_DIR="${OUTPUT_DIR:-output}"
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$OUTPUT_DIR"

for url in "${LINKS[@]}"; do
	# Remove protocol and sanitize URL to create a safe filename
	url_no_proto=${url#*://}
	safe_name=$(echo "$url_no_proto" | sed 's/[^A-Za-z0-9]/_/g')
	json_name="${safe_name}_${TIMESTAMP}.json"
	dest="$DOWNLOAD_DIR/$json_name"

	printf "$SEPARATOR${BLUE}${ICON_DOWNLOAD} Downloading${RESET} $url -> ${BOLD}$dest${RESET}\n"
	curl -fsSL "$url" -o "$dest"

	if [ $? -eq 0 ]; then
	printf "${GREEN}${ICON_SUCCESS} Downloaded:${RESET} $dest\n"
	printf "$SEPARATOR"
		# Generate HTML documentation using Redocly
		html_name="${safe_name}_${TIMESTAMP}.html"
		html_path="$OUTPUT_DIR/$html_name"
	printf "${YELLOW}${ICON_DOC} Generating HTML documentation:${RESET} $html_path\n"
		npx redocly build-docs "$dest" -o "$html_path"
		if [ $? -eq 0 ]; then
			printf "${GREEN}${ICON_SUCCESS} HTML generated:${RESET} $html_path\n"
			printf "$SEPARATOR"
		else
			printf "${RED}${ICON_FAIL} Failed to generate HTML for:${RESET} $dest\n" >&2
			printf "$SEPARATOR"
			echo "$url" >> "$FAILED_LINKS_FILE"
		fi
	else
	printf "${RED}${ICON_FAIL} Failed to download:${RESET} $url\n" >&2
	printf "$SEPARATOR"
		echo "$url" >> "$FAILED_LINKS_FILE"
	fi
done
