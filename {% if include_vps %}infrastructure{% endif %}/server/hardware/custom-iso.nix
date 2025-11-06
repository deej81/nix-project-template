{ pkgs, modulesPath, lib, ... }:
let
  publicKeys = builtins.filter (x: builtins.isString x && x != "") (builtins.split "\n" (builtins.readFile ../../../public_keys.txt));
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  environment.systemPackages = with pkgs; [
    fastfetch
  ];

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = publicKeys;

  users.users.nixos.openssh.authorizedKeys.keys = publicKeys;

  isoImage.isoName = lib.mkForce "custom-nixos-installer.iso";

}
