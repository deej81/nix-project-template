{ modulesPath, config, lib, pkgs, inputs, ... }: {
  imports = [
    ./hardware/simple-disk-config.nix
    ./users.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages = [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.zsh
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Provides a `docker` alias to Podman for compatibility
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";

  system.stateVersion = "24.05";
}
