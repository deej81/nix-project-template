import argparse
import ipaddress

from shared.secrets import rekey_secrets
from shared.age import get_host_public_age_key
from shared.sops_config import add_new_public_key

def validate_ip(arg):
    try:
        # Validate if the input is a valid IP address (IPv4 or IPv6)
        ip = ipaddress.ip_address(arg)
        return str(ip)
    except ValueError:
        raise ValueError(f"Invalid IP address: {arg}")

def main():
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Process an IP address and port.")

    # Add IP address argument (positional argument)
    parser.add_argument('ip', type=str, help='IP address to process')

    # Add port argument (optional, default is 22)
    parser.add_argument(
        '--port',
        type=int,
        default=22,
        help='Port number to use (default: 22)'
    )

    # Parse arguments from the command line
    args = parser.parse_args()

    # Validate and assign IP address
    try:
        ip = validate_ip(args.ip)
        port = args.port
        print("Processing the following IP address and port:")
        print(f"IP: {ip}")
        print(f"Port: {port}")

        public_key = get_host_public_age_key(ip, port)
        print(f"Public key for {ip}:{port} is: {public_key}")

        add_new_public_key(public_key)

        # rekey secrets
        rekey_secrets()

    except ValueError as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
