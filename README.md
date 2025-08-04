

# 🔍 Subdomain Discovery & Port Scanner

A  bash script for passive reconnaissance that combines certificate transparency logs with Shodan's InternetDB to discover subdomains and enumerate open ports - completely free and no API keys required!


## 🚀 Features

- **🔒 Certificate Transparency Discovery**: Uses crt.sh to find subdomains from SSL certificate logs
- **🌐 DNS Resolution**: Resolves all discovered subdomains to IP addresses
- **🔓 Port Enumeration**: Leverages Shodan's free InternetDB for open port discovery
- **🛡️ Vulnerability Detection**: Identifies known CVEs associated with discovered services
- **📊 Multiple Output Formats**: CSV, TXT, and Markdown reports
- **🎯 Zero API Keys**: Completely free - no registration or API keys required
- **⚡ Apple Silicon Optimized**: Native performance on Apple Silicon M1, M2, M3 and M4
- **🔧 Dependency Checking**: Automatic validation of required tools

## 📋 Prerequisites

The script automatically checks for dependencies and provides installation instructions:

### macOS (via Homebrew)
```bash
brew install curl jq bind
```

### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install curl jq dnsutils
```

### CentOS/RHEL
```bash
sudo yum install curl jq bind-utils
```

## 🛠️ Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/subdomain-port-scanner.git
cd subdomain-port-scanner

# Make the script executable
chmod +x subdomain_scanner.sh

# Run against a target domain
./subdomain_scanner.sh example.com
```

## 💻 Usage

### Basic Usage
```bash
./subdomain_scanner.sh target.com
```

### Example Output Structure
```
recon_20241204_143022/
├── subdomains.txt              # List of discovered subdomains
├── subdomains_with_ips.csv     # Subdomains with resolved IPs
├── ports_and_services.csv      # Port and vulnerability data
└── summary.md                  # Executive summary report
```

### Sample Results
```bash
$ ./subdomain_scanner.sh example.com

[INFO] Starting reconnaissance for domain: example.com
[SUCCESS] Found 23 subdomains
[SUCCESS] Resolved 18 subdomains to IP addresses
[INFO] Checking 1.2.3.4 (api.example.com)...
  Open ports: 22,80,443
[WARNING] Vulnerabilities found: CVE-2021-44228
[SUCCESS] Reconnaissance complete!

Quick Stats:
  Subdomains: 23
  Resolved IPs: 18
  IPs with port data: 15
```

## 📊 Output Files

| File | Description |
|------|-------------|
| `subdomains.txt` | Raw list of discovered subdomains |
| `subdomains_with_ips.csv` | Subdomain to IP mapping |
| `ports_and_services.csv` | Comprehensive port and vulnerability data |
| `summary.md` | Human-readable summary report |

## 🔧 How It Works

1. **Certificate Transparency**: Queries crt.sh for SSL certificate logs
2. **DNS Resolution**: Uses `dig` to resolve subdomains to IP addresses
3. **Port Discovery**: Leverages Shodan InternetDB for passive port enumeration
4. **Data Enrichment**: Extracts hostnames, service tags, and vulnerability data
5. **Report Generation**: Creates multiple output formats for different use cases

## 🌟 Key Advantages

- **💰 100% Free**: No API keys, subscriptions, or rate limits
- **🔒 Passive Reconnaissance**: Only uses publicly available data
- **⚡ Fast & Efficient**: Concurrent processing with intelligent delays
- **📈 Comprehensive**: Combines multiple data sources for complete coverage
- **🛡️ Security Focused**: Highlights vulnerabilities and security issues
- **📱 Cross-Platform**: Works on macOS, Linux, and WSL

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. 🍴 Fork the repository
2. 🌟 Create a feature branch (`git checkout -b feature/amazing-feature`)
3. 💻 Commit your changes (`git commit -m 'Add amazing feature'`)
4. 📤 Push to the branch (`git push origin feature/amazing-feature`)
5. 🔄 Open a Pull Request

### Ideas for Contributions
- [ ] Additional subdomain enumeration sources
- [ ] DNS brute-force functionality
- [ ] JSON output format
- [ ] Integration with other passive reconnaissance tools
- [ ] Docker containerization
- [ ] GitHub Actions for automated scanning

## ⚠️ Legal Disclaimer

This tool is intended for authorized security testing and educational purposes only. Users are responsible for ensuring they have proper authorization before scanning any targets. The authors are not responsible for any misuse or damage caused by this tool.

**Always ensure you have explicit permission before scanning domains you don't own.**

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [crt.sh](https://crt.sh/) - Certificate Transparency log search
- [Shodan InternetDB](https://internetdb.shodan.io/) - Free passive reconnaissance data
- The cybersecurity community for continuous knowledge sharing

## 📞 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/subdomain-port-scanner/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/subdomain-port-scanner/discussions)
- 📧 **Email**: your.email@example.com

## ⭐ Star History

If you find this tool useful, please consider giving it a star! ⭐
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)](https://github.com/yourusername/subdomain-port-scanner)
[![Shell](https://img.shields.io/badge/shell-bash-green)](https://www.gnu.org/software/bash/)


---

**Made with ❤️ for the cybersecurity community**
