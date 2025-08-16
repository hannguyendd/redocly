# OpenAPI Documentation Generator

A powerful shell script tool for downloading OpenAPI JSON files and generating beautiful HTML documentation using Redocly CLI.

## Features

- 📥 **Download OpenAPI files** from URLs
- 📄 **Generate HTML documentation** using Redocly
- 🎨 **Colorized output** with icons for better readability
- 📁 **Organized file structure** with timestamp-based naming
- ⚠️ **Error tracking** - logs failed URLs to a file
- 🔧 **Configurable directories** via environment variables
- 📝 **Multiple input methods** - command line args or file-based

## Prerequisites

- **Node.js** (for Redocly CLI)
- **curl** (for downloading files)
- **bash** shell

Install Redocly CLI:

```bash
npm install -g @redocly/cli
```

## Installation

1. Clone this repository:

```bash
git clone https://github.com/hannguyendd/redocly.git
cd redocly
```

2. Make the script executable:

```bash
chmod +x scripts/gen-doc.sh
```

## Usage

### Basic Usage

Download and generate docs from URLs:

```bash
./scripts/gen-doc.sh https://api.example.com/openapi.json
```

### Using a File with URLs

Create a file with URLs (one per line):

```bash
echo "https://api.example1.com/openapi.json" > links.txt
echo "https://api.example2.com/openapi.json" >> links.txt

./scripts/gen-doc.sh -f links.txt
```

### Mixed Usage

Combine file and command line URLs:

```bash
./scripts/gen-doc.sh -f links.txt https://api.another.com/openapi.json
```

### Custom Directories

Set custom download and output directories:

```bash
DOWNLOAD_DIR=my_apis OUTPUT_DIR=my_docs ./scripts/gen-doc.sh -f links.txt
```

### Memory Issues

For large OpenAPI files, increase Node.js memory:

```bash
export NODE_OPTIONS="--max-old-space-size=4096"
./scripts/gen-doc.sh -f links.txt
```

## Command Options

| Option              | Description                          |
| ------------------- | ------------------------------------ |
| `-f, --file <file>` | Read URLs from a file (one per line) |
| `-h, --help`        | Show help message and exit           |

## Environment Variables

| Variable       | Description                             | Default     |
| -------------- | --------------------------------------- | ----------- |
| `DOWNLOAD_DIR` | Directory to save downloaded JSON files | `downloads` |
| `OUTPUT_DIR`   | Directory to save generated HTML files  | `output`    |
| `NODE_OPTIONS` | Node.js options (for memory issues)     | Not set     |

## Output Structure

```
project/
├── downloads/           # Downloaded OpenAPI JSON files
│   └── sanitized_url_timestamp.json
├── output/             # Generated HTML documentation
│   └── sanitized_url_timestamp.html
└── failed_links_timestamp.txt  # Failed URLs log
```

## File Naming Convention

Files are named using:

- **Sanitized URL**: Protocol removed, special characters replaced with underscores
- **Timestamp**: Format `YYYYMMDD_HHMMSS` for uniqueness

Example:

- URL: `https://api.example.com/v1/openapi.json`
- File: `api_example_com_v1_openapi_json_20250816_143022.json`

## Error Handling

- **Failed downloads** are logged to `failed_links_timestamp.txt`
- **Failed documentation generation** is also logged
- **Colorized output** shows success ✅ and failure ❌ status
- **Visual separators** make logs easy to read

## Examples

### Simple download and documentation:

```bash
./scripts/gen-doc.sh https://petstore.swagger.io/v2/swagger.json
```

### Batch processing with custom directories:

```bash
DOWNLOAD_DIR=petstore_api OUTPUT_DIR=petstore_docs \
./scripts/gen-doc.sh https://petstore.swagger.io/v2/swagger.json
```

### Processing multiple APIs from file:

```bash
# Create links file
cat > my_apis.txt << EOF
https://api.github.com/openapi.json
https://petstore.swagger.io/v2/swagger.json
https://httpbin.org/spec.json
EOF

# Process all APIs
./scripts/gen-doc.sh -f my_apis.txt
```

## Troubleshooting

### Memory Issues

If you encounter "JavaScript heap out of memory" errors:

```bash
export NODE_OPTIONS="--max-old-space-size=4096"
```

### Large Files

For very large OpenAPI files, increase memory further:

```bash
export NODE_OPTIONS="--max-old-space-size=8192"
```

### Permission Issues

Make sure the script is executable:

```bash
chmod +x scripts/gen-doc.sh
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).

## Changelog

### v1.0.0

- Initial release
- Basic download and documentation generation
- Colorized output with icons
- Error tracking and logging
- Configurable directories
- Multiple input methods
