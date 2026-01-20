{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Bootloader configuration
  boot.loader.systemd-boot.enable = false;
  boot.loader.systemd-boot.configurationLimit = 3;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    configurationLimit = 3;
    useOSProber = false;
    extraEntries = ''
      menuentry "Fedora" {
          insmod part_gpt
          insmod ext4
          # Search for the BOOT partition (nvme0n1p5)
          search --no-floppy --fs-uuid --set=root d51c7f8a-3875-4f77-a9da-035f18d9a9ba
          
          # Linux kernel is at the root of p5, but needs to mount p6 as root filesystem
          linux /vmlinuz-6.18.5-200.fc43.x86_64 root=UUID=24fa1893-4c2d-464e-8fa7-4e73fb5c62ec ro quiet
          initrd /initramfs-6.18.5-200.fc43.x86_64.img
      }
    '';
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.hostName = "nixos-btw";
  networking.networkmanager.enable = true;

  # Timezone
  time.timeZone = "Asia/Kolkata";

  # X server and window manager
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    windowManager.qtile.enable = true;
  };

  # Display manager
  services.displayManager.ly.enable = true;

  # Users
  users.users.mathew = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  home-manager.backupFileExtension = "backup";
  # Home Manager as NixOS module (for mathew)
  home-manager.users.mathew = {
    home.stateVersion = "25.05";  # match your Home Manager version    
    };

  # Programs
  programs.firefox.enable = true;
  programs.nm-applet.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    alacritty
    git
    micro
    gedit
    efibootmgr
    btop
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Nix experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}

