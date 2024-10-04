{ config, ... }:

{
  users.users = {
    hstdev = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCbIdgtXp6mSt93fbPVXCWKxt+GGUwY+dlntvdPjw8L"
      ];
      password = "";
    };
  };
}
