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
	json_name="${safe_name}.json"
	dest="$DOWNLOAD_DIR/$json_name"

	echo "Downloading $url -> $dest"
	curl -fsSL "$url" -o "$dest"

	if [ $? -eq 0 ]; then
		echo "Downloaded: $dest"
		# Generate HTML documentation using Redocly
		html_name="${safe_name}.html"
		html_path="$OUTPUT_DIR/$html_name"
		echo "Generating HTML documentation: $html_path"
		npx redocly build-docs "$dest" -o "$html_path"
		if [ $? -eq 0 ]; then
			echo "HTML generated: $html_path"
		else
			echo "Failed to generate HTML for: $dest" >&2
		fi
	else
		echo "Failed to download: $url" >&2
	fi
done
