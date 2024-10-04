
# list the commands in the justfile
default:
  just --list --unsorted

create-vm-disk:
    rm -fr .vm-disk
    mkdir .vm-disk
    qemu-img create -f qcow2 .vm-disk/vm.qcow2 20G

# boots the vm ready to have our configuration installed (destroys old disk!)
run-vm-install-mode: build-iso create-vm-disk
    qemu-system-x86_64 \
    -m 4096 \
    -smp 4 \
    -hda .vm-disk/vm.qcow2 \
    -cdrom result/iso/bot-nixos-installer.iso \
    -boot order=cd \
    -net nic \
    -net user,hostfwd=tcp::2222-:22 \
    -enable-kvm

# installs the configuration to the vm (vm must be in install mode)
configure-vm IP="localhost" FLAKE="qemuvm" PORT="2222":
    nix run github:nix-community/nixos-anywhere -- --copy-host-keys --flake .#{{FLAKE}} --debug --ssh-port {{PORT}} nixos@{{IP}}

run-vm:
    qemu-system-x86_64 \
    -m 4096 \
    -smp 4 \
    -hda .vm-disk/vm.qcow2 \
    -boot d \
    -net nic \
    -net user,hostfwd=tcp::2222-:22 \
    -enable-kvm

build-iso:
    #nix build .#nixosConfigurations.installerISO.config.system.build.isoImage
    nix run nixpkgs#nixos-generators -- --format iso --flake .#vmISO -o result

