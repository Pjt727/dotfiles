{ config, pkgs, inputs, ... }:

{
  home.username = "pjt727";
  home.homeDirectory = "/home/pjt727";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # Set default editor and terminal
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";
    # Wayland session variables
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

  # Rose Pine GTK theme
  gtk = {
    enable = true;
    theme = {
      name = "rose-pine";
      package = pkgs.rose-pine-gtk-theme;
    };
    iconTheme = {
      name = "rose-pine";
      package = pkgs.rose-pine-icon-theme;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };

  # Dark mode preference for apps that check
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # Qt dark mode (use gtk platform theme for consistency)
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita";
  };

  # Niri compositor configuration
  programs.niri = {
    settings = {
      # Startup applications
      spawn-at-startup = [
        { command = [ "swww-daemon" ]; }
        { command = [ "sh" "-c" "sleep 1 && swww img ~/dotfiles/wallpapers/rose-pine-moon.png" ]; }
        { command = [ "wl-paste" "--watch" "cliphist" "store" ]; }
        { command = [ "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1" ]; }
        { command = [ "blueman-applet" ]; }
        { command = [ "nm-applet" "--indicator" ]; }
        { command = [ "xwayland-satellite" ]; }
        { command = [ "noctalia-shell" ]; }
      ];

      # Input configuration
      input = {
        keyboard = {
          xkb = {
            layout = "us";
          };
        };
        mouse = {
          accel-speed = 0.0;
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
        };
      };

      # Output/monitor configuration
      outputs = {
        # Default output settings - adjust as needed for your monitors
      };

      # Layout configuration
      layout = {
        gaps = 8;
        center-focused-column = "never";
        preset-column-widths = [
          { proportion = 1.0 / 3.0; }
          { proportion = 1.0 / 2.0; }
          { proportion = 2.0 / 3.0; }
        ];
        default-column-width = { proportion = 1.0 / 2.0; };
        focus-ring = {
          enable = true;
          width = 2;
          active.color = "#e0def4";
          inactive.color = "#595959";
        };
        border = {
          enable = false;
        };
      };

      # Window rules
      window-rules = [
        # Floating windows
        {
          matches = [
            { app-id = "^1Password$"; }
            { app-id = "^.blueman-manager-wrapped$"; }
            { app-id = "^blueman-manager$"; }
            { app-id = "^nm-connection-editor$"; }
            { app-id = "^pavucontrol$"; }
          ];
          open-floating = true;
        }
        # Vesktop on workspace 4
        {
          matches = [
            { app-id = "^vesktop$"; }
            { app-id = "^Vesktop$"; }
          ];
          open-on-workspace = "4";
        }
        # Kitty opacity
        {
          matches = [
            { app-id = "^kitty$"; }
          ];
          opacity = 0.8;
        }
        # Corner rounding for all windows
        {
          geometry-corner-radius = {
            top-left = 5.0;
            top-right = 5.0;
            bottom-left = 5.0;
            bottom-right = 5.0;
          };
          clip-to-geometry = true;
        }
      ];

      # Keybindings
      binds = {
        # Application launchers
        "Alt+T".action.spawn = [ "kitty" ];
        "Alt+G".action.spawn = [ "firefox" ];
        "Alt+Space".action.spawn = [ "noctalia-shell" "ipc" "call" "launcher" "toggle" ];

        # Window management
        "Alt+F".action.maximize-column = {};
        "Alt+F4".action.close-window = {};
        "Alt+V".action.toggle-window-floating = {};
        "Alt+P".action.switch-preset-column-width = {};

        # Vim-style focus navigation
        "Alt+H".action.focus-column-left = {};
        "Alt+L".action.focus-column-right = {};
        "Alt+J".action.focus-window-down = {};
        "Alt+K".action.focus-window-up = {};

        # Move windows
        "Alt+Shift+H".action.move-column-left = {};
        "Alt+Shift+L".action.move-column-right = {};
        "Alt+Shift+J".action.move-window-down = {};
        "Alt+Shift+K".action.move-window-up = {};

        # Workspace navigation (1-0 for workspaces 1-10)
        "Alt+1".action.focus-workspace = 1;
        "Alt+2".action.focus-workspace = 2;
        "Alt+3".action.focus-workspace = 3;
        "Alt+4".action.focus-workspace = 4;
        "Alt+5".action.focus-workspace = 5;
        "Alt+6".action.focus-workspace = 6;
        "Alt+7".action.focus-workspace = 7;
        "Alt+8".action.focus-workspace = 8;
        "Alt+9".action.focus-workspace = 9;
        "Alt+0".action.focus-workspace = 10;

        # Quick workspace access
        "Alt+Q".action.focus-workspace = 1;
        "Alt+W".action.focus-workspace = 2;
        "Alt+E".action.focus-workspace = 3;
        "Alt+R".action.focus-workspace = 4;

        # Move window to workspace
        "Alt+Shift+1".action.move-column-to-workspace = 1;
        "Alt+Shift+2".action.move-column-to-workspace = 2;
        "Alt+Shift+3".action.move-column-to-workspace = 3;
        "Alt+Shift+4".action.move-column-to-workspace = 4;
        "Alt+Shift+5".action.move-column-to-workspace = 5;
        "Alt+Shift+6".action.move-column-to-workspace = 6;
        "Alt+Shift+7".action.move-column-to-workspace = 7;
        "Alt+Shift+8".action.move-column-to-workspace = 8;
        "Alt+Shift+9".action.move-column-to-workspace = 9;
        "Alt+Shift+0".action.move-column-to-workspace = 10;

        # Screenshot
        "Print".action.screenshot = {};

        # Media keys
        "XF86AudioPlay".action.spawn = [ "noctalia-shell" "ipc" "call" "media" "playPause" ];
        "XF86AudioPause".action.spawn = [ "noctalia-shell" "ipc" "call" "media" "playPause" ];
        "XF86AudioNext".action.spawn = [ "noctalia-shell" "ipc" "call" "media" "next" ];
        "XF86AudioPrev".action.spawn = [ "noctalia-shell" "ipc" "call" "media" "previous" ];
        "XF86AudioRaiseVolume".action.spawn = [ "noctalia-shell" "ipc" "call" "volume" "increase" ];
        "XF86AudioLowerVolume".action.spawn = [ "noctalia-shell" "ipc" "call" "volume" "decrease" ];
        "XF86AudioMute".action.spawn = [ "noctalia-shell" "ipc" "call" "volume" "muteOutput" ];

        # Brightness keys
        "XF86MonBrightnessUp".action.spawn = [ "noctalia-shell" "ipc" "call" "brightness" "increase" ];
        "XF86MonBrightnessDown".action.spawn = [ "noctalia-shell" "ipc" "call" "brightness" "decrease" ];

        # Resize columns
        "Alt+Minus".action.set-column-width = "-10%";
        "Alt+Equal".action.set-column-width = "+10%";

        # Power menu
        "Alt+Shift+E".action.spawn = [ "noctalia-shell" "ipc" "call" "sessionMenu" "toggle" ];
      };

      # Cursor theme
      cursor = {
        theme = "Adwaita";
        size = 24;
      };

      # Environment for spawned processes
      environment = {
        DISPLAY = ":0";
      };
    };
  };

  # Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Patrick";
        email = "Patrick@nytyler.com";
      };
      core.editor = "nvim";
      credential."https://github.com".helper = [
        ""
        "!gh auth git-credential"
      ];
      credential."https://gist.github.com".helper = [
        ""
        "!gh auth git-credential"
      ];
    };
  };

  # Neovim setup
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
  };

  # Zsh setup
  programs.zsh = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)";
    };
    initContent = ''
      source ~/dotfiles/zshrc/.zshrc
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Zoxide (smarter cd)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Fzf fuzzy finder
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Yazi file manager
  programs.yazi = {
    shellWrapperName = "y";
    enable = true;
    enableZshIntegration = true;
  };

  # Zsh autosuggestions
  programs.zsh.autosuggestion.enable = true;

  # Mutable symlinks to dotfiles
  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/pjt727/dotfiles/nvim/.config/nvim";
  };

  home.file.".config/kitty" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/pjt727/dotfiles/kitty/.config/kitty";
  };

  home.file.".config/starship.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/pjt727/dotfiles/starship/.config/starship.toml";
  };

  # Swww scripts symlink (if you have wallpaper scripts)
  home.file.".config/swww" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/pjt727/dotfiles/swww/.config/swww";
  };

  # Noctalia (Quickshell) configuration with Rose Pine theme
  home.file.".config/quickshell/noctalia/settings.json".text = builtins.toJSON {
    bar = {
      position = "top";
      height = 32;
      modules = {
        left = [ "workspaces" ];
        center = [ "clock" ];
        right = [ "tray" "battery" "network" "audio" ];
      };
    };
    launcher = {
      width = 600;
      maxResults = 8;
    };
    notifications = {
      position = "top-right";
      maxVisible = 5;
      timeout = 5000;
    };
    theme = {
      # Rose Pine color scheme mapped to Material 3 tokens
      colors = {
        # Primary colors
        primary = "#c4a7e7";           # Iris
        onPrimary = "#191724";         # Base
        primaryContainer = "#26233a";  # Overlay
        onPrimaryContainer = "#e0def4"; # Text

        # Secondary colors
        secondary = "#31748f";         # Pine
        onSecondary = "#191724";       # Base
        secondaryContainer = "#1f1d2e"; # Surface
        onSecondaryContainer = "#e0def4"; # Text

        # Tertiary colors
        tertiary = "#f6c177";          # Gold
        onTertiary = "#191724";        # Base
        tertiaryContainer = "#26233a"; # Overlay
        onTertiaryContainer = "#e0def4"; # Text

        # Error colors
        error = "#eb6f92";             # Love
        onError = "#191724";           # Base
        errorContainer = "#26233a";    # Overlay
        onErrorContainer = "#eb6f92";  # Love

        # Background/Surface
        background = "#191724";        # Base
        onBackground = "#e0def4";      # Text
        surface = "#1f1d2e";           # Surface
        onSurface = "#e0def4";         # Text
        surfaceVariant = "#26233a";    # Overlay
        onSurfaceVariant = "#908caa";  # Subtle

        # Outline
        outline = "#6e6a86";           # Muted
        outlineVariant = "#403d52";    # Highlight low

        # Inverse
        inverseSurface = "#e0def4";    # Text
        inverseOnSurface = "#191724";  # Base
        inversePrimary = "#907aa9";    # Iris dimmed
      };
      borderRadius = 8;
      font = {
        family = "JetBrainsMono Nerd Font";
        size = 12;
      };
    };
  };

  # Development tools
  home.packages = with pkgs; [
    # Terminal
    kitty

    # Fonts
    nerd-fonts.jetbrains-mono

    # C Compiler (needed for tree-sitter)
    gcc

    # LSP Servers
    nil  # Nix language server
    lua-language-server
    emmet-language-server
    gopls
    pyright
    tinymist
    templ
    nodePackages.typescript-language-server
    harper
    rust-analyzer

    # Formatters
    stylua
    black
    prettierd
    rustfmt
    golines

    # Linters
    djlint

    # Essential tools
    ripgrep
    fd
    tree-sitter
    nodejs
    fzf
    yazi
    bat
    gh

    # Language toolchains (include formatters)
    go
  ];
}
