
import os
from shared.config import sops_config_file
import yaml

def load_current_keys() -> list[str]:
    if os.path.exists(sops_config_file):
        with open(sops_config_file, 'r') as file:
                data = yaml.safe_load(file)
        keys = data.get('creation_rules', [{}])[0].get('age', "")
        return keys.split(",") if keys else []
    return []

def save_current_keys(keys: list[str]):
    print("Saving the keys...")
    sops_config = {
        "creation_rules" : [
            {"age": ','.join(keys)}
        ]
    }

    with open(sops_config_file, 'w') as file:
        file.write(yaml.dump(sops_config))
        print("Keys saved successfully.")

def add_new_public_key(host_public_key:str):
    current_keys = load_current_keys()
    if current_keys is None:
        current_keys = []
    if host_public_key not in current_keys:
        print(f"Adding new host key: {host_public_key}")
        current_keys.append(host_public_key)
        print("Saving the updated keys...")
        save_current_keys(current_keys)
        return
    print(f"Host key already exists: {host_public_key}")