https://github.com/SafwanSaleem/Subdomain-port-scanner-passive

![Releases badge](https://img.shields.io/badge/Releases-Download-blue?style=for-the-badge)

# Subdomain-Port-Scanner-Passive: Free Passive Subdomain Discovery & Top Port Scanner

A practical, free tool for discovering subdomains passively and scanning top ports across discovered hosts. It pulls from multiple subdomain sources and public datasets, including Shodan InternetDB, with no API keys required. The project is designed for bug bounty hunters, penetration testers, and security researchers who need quick reconnaissance data on macOS and Linux. This README details how the tool works, how to use it responsibly, and how to contribute to its ongoing improvement.

---

## 🧭 Overview

Subdomain-Port-Scanner-Passive is a lightweight, script-based solution that blends passive subdomain discovery with a focused port-scan pass. The goal is to yield fast, actionable insight without the friction of API keys or paid services. In practice, you get a compact dataset that helps you map a target's attack surface, prioritizes assets by exposure, and surfaces potential misconfigurations that warrant deeper follow-up.

Key strengths:
- Passive discovery from diverse, openly accessible sources
- Top port scanning to identify commonly exposed services
- No API keys required; works with public data
- Cross-platform compatibility: macOS and Linux
- Outputs in friendly, machine-readable formats (JSON, CSV)
- Extensible architecture to add more data sources and ports
- Safe for initial reconnaissance in legitimate security research

The repository topics reflect the breadth of this project: bash-script, bug-bounty, certificate-transparency, cybersecurity, free-tools, penetration-testing, port-scanner, reconnaissance, shodan, subdomain-enumeration.

---

## ⚙️ Features at a glance

- Passive subdomain discovery: Aggregates data from multiple sources to surface subdomains without active probing.
- Subdomain sources mix: Includes well-known public sources and a Shodan InternetDB integration for broader visibility.
- Top port scanning: Checks widely used ports to identify services that may require attention.
- No API keys: You don’t need credentials for core functionality.
- Cross-platform: Designed for macOS and Linux environments.
- Easy output formats: JSON and CSV for quick integration with analysis pipelines.
- Lightweight footprint: Small footprint with reasonable runtime on typical development laptops.
- Extensible design: Simple hooks to add more sources, ports, or output formats.

---

## 🧩 How it works

This solution follows a two-stage approach: discovery and evaluation. It remains intentionally simple to keep the tool approachable, fast, and easy to audit.

- Discovery phase
  - Collects subdomain candidates from passive sources, such as certificate transparency logs, public DNS dumps, and public reconnaissance datasets.
  - Incorporates Shodan InternetDB data to broaden coverage of known hosts without requiring API keys.
  - Deduplicates and validates basic syntax of discovered names to reduce noisy data.
  - Creates a compact subdomain inventory that serves as the basis for the next phase.
- Port-evaluation phase
  - For each discovered subdomain, a top-port scan is performed to identify open services commonly found on the internet.
  - Scanning focuses on a curated list of ports that are frequently exposed and relevant to security assessments.
  - Results are tied back to the source subdomain, including provenance hints about data origin.
- Reporting and export
  - Outputs data in JSON and CSV formats suitable for scripting, reporting, or feeding into dashboards.
  - Includes fields like subdomain, resolved IP (if applicable), port, protocol, service hint, source, and timestamp.
  - Supports sorting and filtering by source, subdomain, or port for targeted analysis.

The design emphasizes reproducibility and transparency. You can inspect the code paths that gather data, merge results, and emit final records. If you need to replicate a prior run, the same data sources and port lists produce consistent outputs given the same environment.

---

## 🧭 Getting started

This section helps you get the tool up and running on a macOS or Linux system. The steps assume a fresh environment accessible via a terminal.

Prerequisites
- Bash-compatible shell
- Core Unix utilities (grep, awk, sed, sort, uniq)
- curl or wget for data fetches
- jq for JSON processing
- Python 3 (optional, for post-processing; not strictly required)
- Sufficient network access to reach public data sources and target hosts

What you’ll clone or download
- The repository content includes the Bash scripts and supporting resources that drive discovery and scanning workflows.
- You don’t need an API key to run the core discovery and scanning.

Installation quickstart
- Clone the repository (if you haven’t already):
  - git clone https://github.com/SafwanSaleem/Subdomain-port-scanner-passive.git
- Make scripts executable (example):
  - chmod +x Subdomain-Port-Scanner-Passive.sh
- Prepare any required input files:
  - A list of target domains (one per line) or a file path
- Run a basic scan:
  - ./Subdomain-Port-Scanner-Passive.sh -d example.com -o results.json
  - You can adjust verbosity with -v or --verbose

CLI notes
- The script expects either a single domain or a file containing many domains.
- Outputs are written to the path you provide with the -o option; if omitted, a default location is used.
- For more advanced usage, pass flags to control sources, ports, and output formats.

Quick start example
- Simple single-domain run:
  - ./Subdomain-Port-Scanner-Passive.sh -d example.org -o output.json
- Multi-domain run:
  - ./Subdomain-Port-Scanner-Passive.sh -f domains.txt -o multi_output.csv
- Verbose run (for troubleshooting):
  - ./Subdomain-Port-Scanner-Passive.sh -d example.net -v

Release guidance
- For the latest release, visit https://github.com/SafwanSaleem/Subdomain-port-scanner-passive/releases to download the asset and run it.

---

## 🧰 Dependencies and compatibility

- Bash shell: The heart of the orchestration logic.
- POSIX tools: grep, awk, sed for text processing and parsing.
- curl or wget: Fetches data from public sources.
- jq: Parses and formats JSON output.
- Python 3 (optional): Used for additional data processing or custom post-processing pipelines.
- macOS and Linux: The script is tailored to common environments on these platforms.
- No external API keys required: A core advantage for teams and individuals who want friction-free reconnaissance.

Notes on data sources
- Subdomain sources: Passive data sources like TLS certificate data, DNS records, and public archives help surface candidates without contacting targets directly.
- Certificate Transparency: CT logs provide a stream of subdomain discoveries via TLS certificate issuance.
- Shodan InternetDB: A public dataset used to augment discovered hosts with known exposure data, without needing an API key for the core workflow.
- Data provenance is preserved in the output, allowing you to gauge trust and coverage.

---

## 🧭 Quick usage guide

- Input options
  - -d, --domain: Specify a single domain
  - -f, --file: Provide a file with one domain per line
- Output options
  - -o, --output: Path to the output file (JSON or CSV)
  - -t, --format: Output format (json, csv)
- Verbosity and debugging
  - -v, --verbose: Increase output detail
  - --debug: Print extra internal state (for troubleshooting)
- Source control
  - --sources: Limit discovery to specific data sources (e.g., ct, dns, shodan)
- Port control
  - --ports: Provide a custom port list; if not provided, a default top-ports list is used
- Execution modes
  - --no-prompt: Run without interactive prompts
  - --continue-on-error: Keep going even if a subdomain fails to resolve

Example workflows
- Lightweight recon on a single domain:
  - ./Subdomain-Port-Scanner-Passive.sh -d example.com -o recon.json
- Comprehensive sweep across multiple domains with verbose output:
  - ./Subdomain-Port-Scanner-Passive.sh -f domains.txt -o full.csv -v --ports 80,443,22,21

---

## 🧭 Data model and output formats

JSON example (simplified)
{
  "timestamp": "2025-08-13T12:34:56Z",
  "subdomain": "app.example.com",
  "ip": "93.184.216.34",
  "port": 443,
  "protocol": "tcp",
  "service_hint": "https",
  "source": "CT logs; Shodan InternetDB",
  "notes": "subdomain surfaced via CT; port 443 open"
}

CSV columns (ordered)
timestamp,subdomain,ip,port,protocol,service_hint,source,notes

Output considerations
- Deduplication: The tool filters duplicates to reduce noise.
- Sorting: Results can be sorted by subdomain, IP, or port to suit your report layout.
- Provenance: Each row includes the data source provenance to help you assess confidence.

Practical considerations
- Snapshot vs. live: Subdomain data from public sources can vary over time. Plan to re-run scans to monitor changes.
- Port exposure: Top-ports scanning highlights services likely exposed to the internet; deeper testing should follow with explicit authorization.
- Data retention: Use secure storage and handle any sensitive outputs with care.

---

## 🔒 Security, ethics, and responsible usage

- This tool is designed for authorized security research and lawful testing. Ensure you have permission to test targets and that your activities comply with applicable laws and organizational policies.
- Do not use the tool to disrupt services, exfiltrate data, or probe targets without explicit authorization.
- Maintain a responsible data handling approach. Treat discovered subdomains as potentially sensitive, especially if they reveal internal networks or misconfigurations.
- If you observe sensitive information while testing, follow standard reporting channels and do not publish details without consent.

Ethical considerations include clear scope definitions, data minimization, and prompt reporting of significant vulnerabilities to the proper owners.

---

## 🧭 Source code layout

- bin/
  - Subdomain-Port-Scanner-Passive.sh: The main orchestrator script.
- src/
  - discovery.sh: Handles passive subdomain collection from sources.
  - portscan.sh: Performs top-port scans against discovered subdomains.
  - merge.sh: Combines discovery and scan results into a unified dataset.
- data/
  - sample_sources/
  - ports.txt: Default top-port list (modifiable)
- docs/
  - usage.md: Detailed command-line options
  - contribution.md: How to contribute
- README.md: The documentation you’re reading
- LICENSE: The project license

Note: The exact file names can vary slightly between releases. The important concept is that the structure supports a clean separation of discovery, scanning, and data consolidation, with a simple path for adding new sources or port lists.

---

## 🧰 Data sources and integration details

- Subdomain discovery
  - Certificate Transparency logs: Public CT data helps surface subdomains associated with TLS certificates.
  - DNS data dumps: Public zone files and other DNS artifacts provide candidate subdomains.
  - Public reconnaissance datasets: Aggregated lists from open sources that people publish for security research.
- Public exposure data
  - Shodan InternetDB: Used to augment found hosts with publicly known exposure cues and service hints.
- Data fusion
  - Deduplication and normalization: The pipeline merges duplicates and normalizes subdomain formats to ensure consistent reporting.
  - Provenance tagging: Each result carries a short provenance record that describes the source data lineage.

This combination gives you a practical view of an organization’s attack surface, focusing on passive discovery and observable services.

---

## 🧭 Performance and reliability

- Parallelism: The workflow uses parallel data collection and port checks to accelerate results without overloading any single source.
- Rate discipline: The tool incorporates sensible pacing to respect external sources and minimize noise embedded in public datasets.
- Retry logic: Transient network issues are retried to maintain data completeness without stalling the entire run.
- Fault tolerance: Individual subdomain entries failing to resolve or time out do not crash the whole process.

Real-world usage often yields a robust initial reconnaissance map within a short time window, enabling security teams to act quickly on the findings.

---

## 🧭 Troubleshooting and common scenarios

- Dependency issues: If the script complains about missing commands (grep, jq, curl), install core utilities for your platform. On macOS, you may need to install via Homebrew (brew install coreutils jq).
- Permission errors: Ensure the script has execute permission and that you’re allowed to write to the specified output directory.
- Data source unavailability: If a source is temporarily unreachable, the pipeline continues with the remaining sources. You’ll see a log line indicating the skipped source and the reason.
- Invalid input: If you provide an invalid domain, the script should log the issue and skip to the next item rather than failing hard.
- Output format issues: If you need a different format, adjust the -t option and the corresponding fields in the output writer. The project supports JSON and CSV; you can extend it with a small adapter.

If you encounter a problem not covered here, consult the release notes for changes or open an issue in the repository to discuss improvements.

---

## 🧑‍💻 Contributing

Contributions help improve data sources, port coverage, and overall reliability. The project welcomes:

- Bug fixes: Report issues with reproducible steps and logs.
- New data sources: Propose additional passive data sources and explain how they integrate with the discovery pipeline.
- Port lists: Suggest additional ports to scan and provide credible reasoning for their inclusion.
- Output formats: Propose alternative formats or data schemas that suit your workflows.
- Documentation: Improve usage examples, edge cases, and troubleshooting guidance.

Guidelines
- Follow the existing code style for Bash scripts and simple shell utilities.
- Provide tests or at least a reproducible test case for changes.
- Include clear and concise commit messages describing the what and why.
- Update documentation when you add new sources or output formats.

Contribution workflow
- Fork the repository, implement changes in a feature branch, and open a pull request.
- Ensure tests pass and that your changes do not regress existing behavior.
- Respect licensing terms and attribution to sources where required.

---

## 🚦 Roadmap

- Expand data-source coverage with more passive sources
- Integrate optional external data feeds for richer context
- Add a lightweight UI or CLI dashboards for quick visualization
- Improve performance with smarter parallelism and rate control
- Provide more export formats (Parquet, YAML) and API-friendly outputs
- Harden security through code audits and dependency checks

---

## 🏷️ License and attribution

This project is distributed under the MIT License. It is released to support researchers and practitioners in performing lawful and ethical security testing. Users should ensure they have explicit authorization to test any target and understand the legal implications of their activities.

---

## 🧭 Release notes and going forward

- The latest release assets are available at the official releases page. For the latest release, visit https://github.com/SafwanSaleem/Subdomain-port-scanner-passive/releases to download the asset and run it.
- Release notes summarize major changes, new sources, and any breaking changes in the CLI or output schema.

---

## 🖼️ Visuals and ambiance

- Emojis accompany section headers to provide quick visual cues and maintain a friendly tone.
- The structure emphasizes clarity and accessibility: approachable language, concrete steps, and explicit examples.

---

## 🧭 How to assess results responsibly

- Validate findings with authoritative sources and confirm subdomains before treating them as assets requiring action.
- In bug bounty contexts, focus on subdomains and endpoints that expose misconfigurations or insecure services.
- Use the output data to guide triage, not to blind-scanner indiscriminately across targets.

---

## 📦 Release assets and quick links recapped

- The primary page to fetch release artifacts is the releases page for this project.
- For direct access to the release assets, refer to the official releases section at the project page.
- The tool’s design supports rapid provisioning of reconnaissance data that you can hand off to teammates or integrate into your workflow.

---

## 📌 Final notes

- This documentation mirrors the project’s intent: a practical, free tool for passive discovery and top-port awareness on macOS and Linux.
- The two-key URL references at the top and in the release guidance provide a clear path to obtaining the latest stable assets for hands-on exploration.
- The emphasis remains on responsible usage, transparent data handling, and reproducible results to support meaningful security assessments.

---

## 📬 Contact and community

- If you want to reach out with questions, feature requests, or collaboration ideas, open an issue on the repository or engage through the project maintainers' channels as listed in the repository metadata.
- Community contributions are welcome, and maintainers aim to respond promptly to feedback that improves the tool’s reliability and usefulness.

---

## 🧭 Closing

Subdomain-Port-Scanner-Passive is built to be practical, transparent, and easy to use. It blends passive subdomain discovery with a targeted port-scanning approach to produce actionable reconnaissance data. The combination of data sources, absence of required API keys, and a focus on macOS/Linux compatibility makes it a handy asset for security researchers, bug bounty hunters, and experienced defenders alike.

Get the latest release and start exploring the surface of your targets responsibly. The official release assets live at the releases page, ready for download and execution per the directions above.