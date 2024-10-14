
import os
from shared.secrets import set_secret
from shared.config import private_key_path


def get_passwd_hash() -> str:
    command = f"mkpasswd --method=sha-512"
    passwd = os.popen(command).read().strip()
    return passwd

def main():
    password_hash = get_passwd_hash()
    print(f"Password hash: {password_hash}")
    set_secret("initial_password", password_hash)

if __name__ == "__main__":
    main()
