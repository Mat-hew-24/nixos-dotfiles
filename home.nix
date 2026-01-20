{ config, pkgs, osConfig, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  configs = {
    nvim = "nvim";
    alacritty = "alacritty";
    qtile = "qtile";
    rofi = "rofi";
  };
in
{
  home.username = "mathew";
  home.homeDirectory = "/home/mathew";
  home.stateVersion = "25.05";

  programs.git = {
    enable = true;
    userName  = "mathew";
    userEmail = "amonline2005@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo I use nix btw";
      oslo = ''
        cd "$HOME/nixos-dotfiles" && \
        sudo nixos-rebuild switch --flake .#${osConfig.networking.hostName}
      '';
    };

    initExtra = ''
      set_brightness() {
        if [ -z "$1" ]; then
          echo "Usage: set_brightness <percentage>"
          return 1
        fi

        local percent=$1

        if [ "$percent" -lt 0 ] || [ "$percent" -gt 100 ]; then
          echo "Error: percentage must be 0-100"
          return 1
        fi

        local backlight="/sys/class/backlight/intel_backlight"
        local max=$(cat "$backlight/max_brightness")

        local value=$(( percent * max / 100 ))

        sudo sh -c "echo $value > $backlight/brightness"

        echo "Brightness set to $percent% ($value/$max)"
      }
    '';
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  services.ssh-agent.enable = true;

  xdg.configFile = {
    "qtile" = {
      source = create_symlink "${dotfiles}/qtile/";
      recursive = true;
    };

    "rofi" = {
      source = create_symlink "${dotfiles}/rofi/";
      recursive = true;
    };

    "alacritty" = {
      source = create_symlink "${dotfiles}/alacritty/";
      recursive = true;
    };

    "nvim" = {
      source = create_symlink "${dotfiles}/nvim/";
      recursive = true;
    };
  };

  home.packages = with pkgs; [
    neovim
    nodejs
    nixpkgs-fmt
    nil
    ripgrep
    gcc
    rofi
    networkmanagerapplet
    vscode
    google-chrome
  ];
}
