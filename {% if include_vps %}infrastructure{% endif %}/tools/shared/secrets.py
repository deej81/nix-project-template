import os
import subprocess

import yaml
from shared.config import secrets_file, private_key_path, sops_config_file

def load_secrets():
    if not os.path.exists(secrets_file):
        print(f"Secrets file {secrets_file} not found.")
        return {}
    
    print(f"Loading secrets from {secrets_file}")
    # Prepare the environment with the desired variable
    custom_env = os.environ.copy()  # Start with a copy of the current environment
    custom_env['SOPS_AGE_KEY_FILE'] = private_key_path  # Set the SOPS_AGE_KEY_FILE variable

    # Run the sops decrypt command with the custom environment
    try:
        result = subprocess.run(
            ['sops','-d', '--config', sops_config_file , secrets_file],  # Path to the encrypted file
            stdout=subprocess.PIPE,  # Capture standard output
            stderr=subprocess.PIPE,  # Capture errors if any
            check=True,  # Raise exception on non-zero exit code
            text=True,  # Get string output instead of bytes
            env=custom_env  # Pass the custom environment
        )
        
        decrypted_content = yaml.safe_load(result.stdout)
        print("Decrypted content successfully retrieved.")
        print(f"Secrets: {', '.join(decrypted_content.keys())}")
        return decrypted_content
    except subprocess.CalledProcessError as e:
        print(f"Error decrypting file: {e.stderr}")

def save_secrets(secrets: dict):
    # Prepare the environment with the desired variable
    custom_env = os.environ.copy()  # Start with a copy of the current environment
    custom_env['SOPS_AGE_KEY_FILE'] = private_key_path  # Set the SOPS_AGE_KEY_FILE variable

    # Serialize the secrets to YAML
    yaml_secrets = yaml.dump(secrets)
    print("Encrypting the secrets...")
   
    try:
        result = subprocess.run(
            ['sops', '-e', '--config', sops_config_file, '--input-type', 'yaml', '--output-type', 'yaml',  '/dev/stdin'],  # Run sops encrypt
            input=yaml_secrets,  # Pass the YAML as input
            stdout=subprocess.PIPE,  # Capture standard output
            stderr=subprocess.PIPE,  # Capture errors if any
            check=True,  # Raise exception on non-zero exit code
            text=True,  # Get string output instead of bytes
            env=custom_env  # Pass the custom environment
        )
        encrypted_content = result.stdout
        with open(secrets_file, 'w') as file:
            file.write(encrypted_content)
    except subprocess.CalledProcessError as e:
        print(f"Error encrypting file: {e.stderr}")

def rekey_secrets():
    # should call rekey really, but I'm lazy
    secrets = load_secrets()
    save_secrets(secrets)

def set_secret(key:str, value:str):
    secrets = load_secrets()
    secrets[key] = value
    save_secrets(secrets)

if __name__ == "__main__":
    set_secret("test", "12345")
    set_secret("test", "12346")
