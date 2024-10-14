
from shared.config import private_key_path
from shared.sops_config import add_new_public_key
from shared.age import get_local_public_key


def main():
    public_key = get_local_public_key(private_key_path)
    print(f"Public key: {public_key}")
    add_new_public_key(public_key)

if __name__ == "__main__":
    main()