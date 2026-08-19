{ config, pkgs, lib, ... } : {

  programs.zsh  =
  let haw-vpn-script =  pkgs.writeScript "haw-vpn" ''
    #! /usr/bin/env nix-shell
    #! nix-shell -i zsh -p openfortivpn 

    sudo openfortivpn vpn1.haw-landshut.de -u $(pass haw/mail | tail -n1 | cut -d: -f2) -p $(pass haw/mail | head -n1)

    ''; in
  {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ngit   ="nvim -c Git";
      haw-vpn="${haw-vpn-script}";
      ls     ="exa";
      nix-edit = "cd ${config.home.homeDirectory}/Documents/workspace/nixos-configuration; nvim flake.nix home-manager/home.nix nixos/configuration.nix";
      n = "nix-shell -I nixpkgs=channel:nixos-unstable -p \${1} --command zsh";
      viture = "way-displays -s DISABLED '!^eDP-1$'; way-displays -s SCALE '!^DP-3$' 1.5; read line; way-displays -d DISABLED '!^eDP-1$'";
      g = "git";
    };

    history = 
      let history-size = 10000;
      in
    {
      size = history-size;
      save = history-size;
      ignoreAllDups = true;
    };

    plugins = 
    [
      {
        name = "zsh-vi-mode";
        src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
      }
    ];

    initContent = ''
      bindkey '^j' autosuggest-accept

      # pure prompt
      print() {
        [ 0 -eq $# -a "prompt_pure_precmd" = "''${funcstack[-1]}" ] || builtin print "$@";
      }
      autoload -U promptinit
      promptinit
      prompt pure

      # navigate up in directory tree
      up-directory() {
          builtin cd .. && zle reset-prompt
      }
      zle -N up-directory
      bindkey '\C-h' up-directory 

      # # fzf keybindings have to be enabled after vi-mode
      # function after_zvm() {
      #   source <(fzf --zsh)
      #   source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      # }
      # zvm_after_init_commands+=(after_zvm)
      # zstyle ':fzf-tab:*' query-string prefix 

      recordgif () { 
        echo Recording to $1.gif &&\
        slurp="$(slurp)" &&\
        echo "Waiting for 5 seconds" &&\
        sleep 5 && wf-recorder -y -g "$slurp" &&\
        ffmpeg -y -i recording.mkv -vf "fps=10,scale=640:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 $1.gif &&\
        mogrify -layers optimize $1.gif &&\
        rm -f recording.mkv
      } 
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [  "colored-man-pages" "colorize" "git" "vi-mode" "z" "gradle"  ]; # "fzf"
    };


  };

  programs.fzf = {
    enable = false;
    enableZshIntegration = false;
  };


  programs.fd.enable = true;

}

