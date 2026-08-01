{ pkgs, config, claude-desktop, ... }: 
let texlive = pkgs.texliveFull;
in {

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.packages = let claude-desktop-workaround = 
    (claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop.override {
     nodePackages = { inherit (pkgs) asar; };
     });
    in
    with pkgs; [ 
    gh github-copilot-cli
    abook
    atool
    brightnessctl
    chromium
    claude-desktop-workaround
    darktable
    davmail
    evince
    eza 
    feh
    ffmpeg
    file
    flameshot
    fuse2
    gimp3
    httm
    hunspell hunspellDicts.de-de hunspellDicts.en-us
    hyphen hyphenDicts.de-de hyphenDicts.en-us
    jq
    imagemagick
    inkscape
    isync
    jdt-language-server
    libreoffice-fresh
    coinmp
    lp_solve
    scip
    librsvg
    libsixel
    networkmanager-fortisslvpn
    nextcloud-client
    openldap
    parsec-bin
    pass-git-helper
    pavucontrol
    pipectl
    playerctl
    poppler-utils
    prusa-slicer
    pure-prompt 
    python3
    ripgrep
    simple-scan
    slurp
    sox
    sshfs
    texlive 
    unrar
    unzip
    vifm
    vimiv-qt
    vlc
    w3m
    way-displays
    wf-recorder
    wl-clipboard
    wl-mirror
    zathura
  ];

  programs.btop = {
      enable = true;
      settings = {
          vim_keys = true;
      };
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "${config.home.homeDirectory}/Documents/workspace/nixos-configuration";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  services.flatpak = {
    uninstallUnmanaged = true;
    update.onActivation = true;
    packages = [
      "us.zoom.Zoom"
    ];
  };

}

