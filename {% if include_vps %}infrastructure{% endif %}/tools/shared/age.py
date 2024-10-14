import os
import stat
import subprocess

def generate_private_key():
    command = "age-keygen"
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return result.stdout.strip()

def ensure_privatekey_present(path:str):
    # Path to the private key
    private_key_path = os.path.expanduser(path)

    # Step 1: Ensure the directory exists
    private_key_dir = os.path.dirname(private_key_path)
    if not os.path.exists(private_key_dir):
        os.makedirs(private_key_dir, exist_ok=True)

    # Step 2: Ensure the key file exists
    if not os.path.exists(private_key_path):
        # You can generate or create the key file here if needed
        with open(private_key_path, 'w') as key_file:
            key_file.write(generate_private_key())  # Create an empty file or write the key

    # Step 3: Set the correct file permissions (600 -> owner read/write only)
    os.chmod(private_key_path, stat.S_IRUSR | stat.S_IWUSR)

def get_local_public_key(path:str) -> str:
    private_key_path = os.path.expanduser(path)
    ensure_privatekey_present(private_key_path)

    try:
        result = subprocess.run(
            ['age-keygen', '-y', private_key_path],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        # The public key will be in stdout
        public_key = result.stdout.strip()
        return public_key

    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Error extracting public key: {e.stderr.strip()}")


def get_ssh_key(ip:str, port:int) -> str:
    command = f"ssh-keyscan -p {port} -t ed25519 {ip} 2>/dev/null | grep ssh-ed25519 | awk '{{print $2 \" \" $3}}'"
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"Error fetching SSH key: {result.stderr.strip()}")
    if(result.stdout.strip() == ""):
        raise RuntimeError(f"Error fetching SSH key: {result.stderr.strip()}")
                                                      
    return result.stdout.strip()

def ssh_key_to_age(ssh_key:str) -> str:
    command = f"echo {ssh_key} | ssh-to-age"
    result = subprocess.run(command, shell=True, input=ssh_key, capture_output=True, text=True)
    return result.stdout.strip()

def get_host_public_age_key(ip:str, port:int) -> str:
    ssh_key = get_ssh_key(ip, port)
    return ssh_key_to_age(ssh_key)


