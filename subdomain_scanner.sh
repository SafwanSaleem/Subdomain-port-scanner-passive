#!/bin/bash

# Subdomain Discovery and Port Scanner for Mac M1
# Uses cert.sh for subdomain enumeration and Shodan API for port information

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OUTPUT_DIR="recon_$(date +%Y%m%d_%H%M%S)"
THREADS=10

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    local deps=("curl" "jq" "dig" "nslookup")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_status "Install missing dependencies:"
        print_status "brew install curl jq bind"
        exit 1
    fi
    
    print_success "All dependencies found"
}

# Function to query InternetDB API
query_internetdb() {
    local ip="$1"
    
    local response=$(curl -s "https://internetdb.shodan.io/$ip" 2>/dev/null)
    
    # Check if response is valid JSON and not an error
    if echo "$response" | jq -e . >/dev/null 2>&1; then
        echo "$response"
    else
        return 1
    fi
}

# Function to discover subdomains using cert.sh
discover_subdomains_certsh() {
    local domain="$1"
    local output_file="$2"
    
    print_status "Discovering subdomains using cert.sh..."
    
    # Query cert.sh API
    curl -s "https://crt.sh/?q=%25.$domain&output=json" | \
        jq -r '.[].name_value' | \
        sed 's/\*\.//g' | \
        sort -u | \
        grep -E "^[a-zA-Z0-9.-]+\.$domain$" > "$output_file" 2>/dev/null || true
    
    local count=$(wc -l < "$output_file" 2>/dev/null || echo "0")
    print_success "Found $count subdomains from cert.sh"
}

# Function to discover subdomains using AnubisDB
discover_subdomains_anubis() {
    local domain="$1"
    local output_file="$2"
    
    print_status "Discovering subdomains using AnubisDB..."
    
    # Query AnubisDB API
    curl -s "https://anubisdb.com/anubis/subdomains/$domain" | \
        jq -r '.[]?' 2>/dev/null | \
        grep -E "^[a-zA-Z0-9.-]+\.$domain$" > "$output_file" 2>/dev/null || true
    
    local count=$(wc -l < "$output_file" 2>/dev/null || echo "0")
    print_success "Found $count subdomains from AnubisDB"
}

# Function to discover subdomains using multiple sources
discover_subdomains() {
    local domain="$1"
    local output_file="$2"
    
    print_status "Starting comprehensive subdomain discovery for $domain..."
    
    # Temporary files for different sources
    local certsh_file="${output_file}.certsh"
    local anubis_file="${output_file}.anubis"
    
    # Discover from cert.sh
    discover_subdomains_certsh "$domain" "$certsh_file"
    
    # Discover from AnubisDB  
    discover_subdomains_anubis "$domain" "$anubis_file"
    
    # Add the main domain
    echo "$domain" > "$output_file"
    
    # Combine results from both sources
    if [ -f "$certsh_file" ]; then
        cat "$certsh_file" >> "$output_file"
    fi
    
    if [ -f "$anubis_file" ]; then
        cat "$anubis_file" >> "$output_file"
    fi
    
    # Remove duplicates and sort
    sort -u "$output_file" -o "$output_file"
    
    # Clean up temporary files
    rm -f "$certsh_file" "$anubis_file"
    
    local total_count=$(wc -l < "$output_file")
    print_success "Total unique subdomains discovered: $total_count"
    
    # Show source breakdown
    print_status "Subdomain discovery completed using multiple sources:"
    print_status "  - Certificate Transparency (cert.sh)"
    print_status "  - Historical data (AnubisDB)"
}

# Function to resolve IP addresses
resolve_ips() {
    local subdomains_file="$1"
    local output_file="$2"
    
    print_status "Resolving IP addresses..."
    
    > "$output_file"  # Clear output file
    
    while IFS= read -r subdomain; do
        if [ -n "$subdomain" ]; then
            # Use dig to resolve IP
            ip=$(dig +short "$subdomain" A | head -1)
            if [ -n "$ip" ] && [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo "$subdomain,$ip" >> "$output_file"
                echo "  $subdomain -> $ip"
            fi
        fi
    done < "$subdomains_file"
    
    local count=$(wc -l < "$output_file")
    print_success "Resolved $count subdomains to IP addresses"
}

# Function to query Shodan API
query_shodan() {
    local ip="$1"
    local api_key="$2"
    
    if [ -z "$api_key" ]; then
        return 1
    fi
    
    local response=$(curl -s "https://api.shodan.io/shodan/host/$ip?key=$api_key" 2>/dev/null)
    
    if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
        return 1
    fi
    
    echo "$response"
}

# Function to get port information from InternetDB
get_port_info() {
    local ips_file="$1"
    local output_file="$2"
    
    print_status "Querying Shodan InternetDB for port information..."
    
    echo "Subdomain,IP,Ports,Hostnames,Tags,Vulns,CPEs" > "$output_file"
    
    while IFS=',' read -r subdomain ip; do
        if [ -n "$ip" ]; then
            print_status "Checking $ip ($subdomain)..."
            
            local internetdb_data=$(query_internetdb "$ip")
            
            if [ $? -eq 0 ] && [ -n "$internetdb_data" ]; then
                # Extract information from InternetDB response
                local ports=$(echo "$internetdb_data" | jq -r '.ports[]?' 2>/dev/null | tr '\n' ',' | sed 's/,$//')
                local hostnames=$(echo "$internetdb_data" | jq -r '.hostnames[]?' 2>/dev/null | tr '\n' ',' | sed 's/,$//')
                local tags=$(echo "$internetdb_data" | jq -r '.tags[]?' 2>/dev/null | tr '\n' ',' | sed 's/,$//')
                local vulns=$(echo "$internetdb_data" | jq -r '.vulns[]?' 2>/dev/null | tr '\n' ',' | sed 's/,$//')
                local cpes=$(echo "$internetdb_data" | jq -r '.cpes[]?' 2>/dev/null | tr '\n' ',' | sed 's/,$//')
                
                # Handle empty fields
                [ -z "$ports" ] && ports="None"
                [ -z "$hostnames" ] && hostnames="None"
                [ -z "$tags" ] && tags="None"
                [ -z "$vulns" ] && vulns="None"
                [ -z "$cpes" ] && cpes="None"
                
                echo "$subdomain,$ip,\"$ports\",\"$hostnames\",\"$tags\",\"$vulns\",\"$cpes\"" >> "$output_file"
                
                if [ "$ports" != "None" ]; then
                    echo "  Open ports: $ports"
                else
                    echo "  No open ports found"
                fi
                
                if [ "$vulns" != "None" ]; then
                    print_warning "  Vulnerabilities found: $vulns"
                fi
            else
                echo "$subdomain,$ip,No data,No data,No data,No data,No data" >> "$output_file"
                echo "  No InternetDB data available"
            fi
            
            # Small delay to be respectful to the API
            sleep 0.5
        fi
    done < "$ips_file"
    
    print_success "Port information saved to $output_file"
}

# Function to perform basic port scan (fallback)
basic_port_scan() {
    local ip="$1"
    local common_ports="21 22 23 25 53 80 110 111 135 139 143 443 993 995 1723 3306 3389 5432 5900 8080"
    local open_ports=()
    
    for port in $common_ports; do
        if timeout 3 bash -c "</dev/tcp/$ip/$port" 2>/dev/null; then
            open_ports+=("$port")
        fi
    done
    
    echo "${open_ports[*]}" | tr ' ' ';'
}

# Function to create summary report
create_summary() {
    local subdomains_file="$1"
    local ips_file="$2"
    local ports_file="$3"
    local summary_file="$4"
    
    print_status "Creating summary report..."
    
    {
        echo "# Subdomain Discovery and Port Scan Report"
        echo "Generated on: $(date)"
        echo ""
        echo "## Summary"
        echo "- Total subdomains found: $(wc -l < "$subdomains_file")"
        echo "- Subdomains with resolved IPs: $(wc -l < "$ips_file")"
        if [ -f "$ports_file" ]; then
            echo "- IPs with port data: $(($(wc -l < "$ports_file") - 1))"
        fi
        echo ""
        echo "## Data Sources"
        echo "- Certificate Transparency (cert.sh)"
        echo "- Historical subdomain data (AnubisDB)"
        echo "- Passive port enumeration (Shodan InternetDB)"
        echo ""
        echo "## Subdomains"
        while IFS= read -r subdomain; do
            echo "- $subdomain"
        done < "$subdomains_file"
        echo ""
        if [ -f "$ips_file" ]; then
            echo "## IP Addresses"
            while IFS=',' read -r subdomain ip; do
                echo "- $subdomain: $ip"
            done < "$ips_file"
        fi
    } > "$summary_file"
    
    print_success "Summary report created: $summary_file"
}

# Function to display usage
usage() {
    echo "Usage: $0 <domain>"
    echo ""
    echo "Examples:"
    echo "  $0 example.com"
    echo "  SHODAN_API_KEY=your_key $0 example.com"
    echo ""
    echo "The script will create a timestamped directory with results."
    exit 1
}

# Main function
main() {
    if [ $# -ne 1 ]; then
        usage
    fi
    
    local domain="$1"
    
    # Validate domain format
    if ! [[ "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        print_error "Invalid domain format: $domain"
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    cd "$OUTPUT_DIR"
    
    print_status "Starting reconnaissance for domain: $domain"
    print_status "Output directory: $OUTPUT_DIR"
    
    # File paths
    local subdomains_file="subdomains.txt"
    local ips_file="subdomains_with_ips.csv"
    local ports_file="ports_and_services.csv"
    local summary_file="summary.md"
    
    # Step 1: Discover subdomains
    discover_subdomains "$domain" "$subdomains_file"
    
    # Step 2: Resolve IP addresses
    resolve_ips "$subdomains_file" "$ips_file"
    
    # Step 3: Get port information from Shodan
    if [ -f "$ips_file" ] && [ -s "$ips_file" ]; then
        get_port_info "$ips_file" "$ports_file"
    fi
    
    # Step 4: Create summary report
    create_summary "$subdomains_file" "$ips_file" "$ports_file" "$summary_file"
    
    # Display results
    echo ""
    print_success "Reconnaissance complete!"
    echo ""
    echo "Results saved in: $(pwd)"
    echo "Files created:"
    echo "  - $subdomains_file (list of subdomains)"
    echo "  - $ips_file (subdomains with IP addresses)"
    if [ -f "$ports_file" ]; then
        echo "  - $ports_file (port and service information)"
    fi
    echo "  - $summary_file (summary report)"
    
    # Show quick stats
    echo ""
    echo "Quick Stats:"
    echo "  Subdomains: $(wc -l < "$subdomains_file")"
    echo "  Resolved IPs: $(wc -l < "$ips_file")"
    if [ -f "$ports_file" ]; then
        local ports_with_data=$(tail -n +2 "$ports_file" | grep -v "No Shodan data" | wc -l)
        echo "  IPs with port data: $ports_with_data"
    fi
}

# Trap to handle interruption
trap 'print_error "Script interrupted"; exit 1' INT TERM

# Run main function
main "$@"