# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  hardware = {

    # Enable full GPU hardware video acceleration.
    # This offloads video decoding from the CPU to the integrated graphics.
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # Modern driver for media playback (QuickSync / VA-API)
        intel-vaapi-driver # Legacy fallback driver required by some web browsers
      ];
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true; # Automatically turn on Bluetooth when the system boots
    };

    i2c.enable = true;
  };

  environment = {

    # 4. Launch Hyprland when logging into TTY1
    loginShellInit = ''
      if uwsm check may-start; then
        exec uwsm start default
      fi
    '';

    extraInit = ''
      export PATH="$HOME/.config/emacs/bin:$PATH"
    '';

    sessionVariables = {

      # Force applications to use the modern Intel driver for hardware video decoding
      LIBVA_DRIVER_NAME = "iHD";

      # Force GTK4 and Libadwaita applications to prefer a dark color scheme
      GTK_THEME = "Adwaita-dark";

      # Tell Qt applications to hand over theme and font management to the qt6ct UI tool
      QT_QPA_PLATFORMTHEME = "qt6ct";

      # Set the desktop environment identity so XDG Desktop Portals route files and dark mode rules correctly
      XDG_CURRENT_DESKTOP = "Hyprland";

      # Force Qt applications to run natively on Wayland instead of falling back to XWayland
      QT_QPA_PLATFORM = "wayland";

    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      kdePackages.qt6ct # Theme configuration tool for Qt6 apps like Dolphin/KTorrent
      kdePackages.breeze # Provides the clean "Breeze Dark" theme and icons
      # -- apps

      kdePackages.ktorrent
      # kdePackages.dolphin
      yazi

      # ---
      stow
      neovim
      kitty
      google-chrome
      brave
      webex
      citrix-workspace
      # --- LazyVim Runtime & Compiler Dependencies ---
      git # Required for partial clones and updates
      curl # Required for completion engines (e.g., blink.cmp)
      gcc # C compiler required by nvim-treesitter
      gnumake # Build utility for nvim-treesitter and other tools
      unzip # Required for unpacking plugins
      tree-sitter
      tree-sitter-grammars.tree-sitter-java
      tree-sitter-grammars.tree-sitter-nix
      tree-sitter-grammars.tree-sitter-lua
      tree-sitter-grammars.tree-sitter-javascript
      tree-sitter-grammars.tree-sitter-typescript
      tree-sitter-grammars.tree-sitter-tsx
      tree-sitter-grammars.tree-sitter-regex

      # --- Recommended CLI Tools & LSPs ---
      fzf # General fuzzy finding
      ripgrep # Live grep in telescope
      fd # Fast file searching
      lazygit # Git TUI integration
      nodejs # Many LSPs (tsserver, etc.) rely on Node.js
      python3 # Python environment for Python-based LSPs/plugins
      python312Packages.pynvim # Python provider for neovim

      # LSP
      lua-language-server
      nil
      typescript-language-server
      bash-language-server
      vscode-langservers-extracted

      # Formatters
      alejandra # nix
      statix
      beautysh

      lazygit
      fzf
      zoxide
      bat
      eza
      tmux

      zed-editor

      mixxx

      # Install qt6ct so QT apps can scale and style correctly
      qt6Packages.qt6ct

      ddcutil

      pavucontrol

      emacs-pgtk # Adds Emacs with native Wayland support
      pandoc # Markdown compiler engine
      shellcheck # Shell script linter engine
    ];
  };

  boot = {

    # Bootloader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Kernel parameters for Intel UHD 770 display stability.
    #
    # We occasionally experience a "No Signal" condition during boot where
    # the system appears to start normally but the monitor never receives
    # video output. These options target Intel display initialization and
    # monitor handshake issues.
    kernelParams = [
      # Disable Intel Fastboot display initialization.
      # Forces the graphics driver to perform a full monitor detection and
      # modesetting sequence during boot. Can help with intermittent HDMI
      # signal loss and monitor handshake problems.
      "i915.fastboot=0"

      # Disable Panel Self Refresh (PSR).
      # PSR is a power-saving feature that can cause display issues on some
      # Intel graphics systems. Primarily affects laptops, but is harmless
      # to disable while troubleshooting display signal problems.
      "i915.enable_psr=0"

      # Previous sleep-related troubleshooting options:
      #
      # Force the system to use s2idle instead of deeper sleep states.
      # Can help on some 13th Gen Intel systems with suspend/resume issues.
      # "mem_sleep_default=s2idle"
      #
      # Limit CPU power-saving states to improve stability at the cost of
      # higher idle power consumption.
      # "intel_idle.max_cstate=4"
    ];

    # Previously tested as a workaround for display initialization issues.
    # Forces the Intel graphics driver (i915) to load in the initrd stage
    # before the main system boots. This did not resolve the issue and is
    # currently disabled to allow the default driver loading sequence.
    #
    # initrd.kernelModules = [ "i915" ];

    kernelModules = [ "i2c-dev" ];

    # Use the latest Linux kernel.
    # Essential for 13th Gen hardware stability and power management updates.
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {

    hostName = "nixos"; # Define your hostname.

    # Enable networking
    # Keep NetworkManager enabled for your KDE panel widget
    networkmanager.enable = true;

    # Tell NetworkManager to use iwd instead of wpa_supplicant
    networkmanager.wifi.backend = "iwd";

    # Enable the iwd daemon itself so NetworkManager can talk to it
    wireless.iwd = {
      enable = true;
      settings = {
        Settings = {
          AutoConnect = true;
        };
      };
    };
  };

  # Set your time zone.
  time.timeZone = "America/Costa_Rica";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    # LC_ADDRESS = "es_CR.UTF-8";
    # LC_IDENTIFICATION = "es_CR.UTF-8";
    LC_MEASUREMENT = "es_CR.UTF-8";
    LC_MONETARY = "es_CR.UTF-8";
    # LC_NAME = "es_CR.UTF-8";
    LC_NUMERIC = "es_CR.UTF-8";
    LC_PAPER = "es_CR.UTF-8";
    LC_TELEPHONE = "es_CR.UTF-8";
    # LC_TIME = "es_CR.UTF-8";
  };

  services = {

    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    # xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    # displayManager.plasma-login-manager.enable = true;
    # desktopManager.plasma6.enable = true;

    # 3. Enable automatic login on TTY1
    getty.autologinUser = "manrique"; # Replace with your username

    # Configure keymap in X11
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # noctalia
    power-profiles-daemon.enable = true;
    upower.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    emacs.enable = true;
  };

  security = {

    # Enables Polkit to manage unprivileged user permissions for actions like mounting drives or shutting down via GUI.
    polkit.enable = true;

    # Enables RealtimeKit (Rtkit) to hand out high scheduling priority to audio services like PipeWire to prevent stuttering.
    rtkit.enable = true;
  };

  users.users.manrique = {
    isNormalUser = true;
    description = "manrique";
    extraGroups = [
      "networkmanager"
      "wheel"
      "i2c"
    ];
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };

  # Enable XDG Desktop Portals so apps can read the dark mode preference
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    config = {
      common = {
        default = [ "gtk" ];
      };
      # Force Hyprland to use its own portal
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
      # Force KDE to use its own portal
      # kde = {
      #   default = [ "kde" ];
      # };
    };
  };

  programs = {

    # Enable the Hyprland window manager
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };

    # Install firefox.
    firefox.enable = true;

    git = {
      enable = true;
      config = {
        user = {
          name = "manrique";
          email = "manrique.varela@gmail.com";
        };

      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
    };
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  nixpkgs.overlays = [
    (import ./overlays/citrix.nix)
  ];

  fonts.packages = with pkgs; [

    noto-fonts
    liberation_ttf
    dejavu_fonts
    corefonts

    nerd-fonts.jetbrains-mono

    symbola
    nerd-fonts.symbols-only

  ];

  system.stateVersion = "25.11";
}
