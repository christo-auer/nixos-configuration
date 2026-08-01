{ private-values, private-data, ... } : {

  home.file.".config/pass-git-helper" = {
    source = "${private-data}/pass-git-helper";
    recursive = true;
  };

  programs.git = {
    enable = true;

    lfs.enable = true;
    
    signing.format = null;

    settings = {
      user.name = private-values.git.name;
      fetch.prune = true;
      defaultBranch.name = "main";
      rebase.autoSquash = true;
      pull.rebase = true;
      alias = {
        adog = "log --all --decorate --oneline --graph";
        s = "status -s";
        aa = "add -A";
      };
      extraConfig = {
        init.defaultbranch = "main";
        pull.rebase = "true";
        credential.helper = "!pass-git-helper $@";
      };
    };





  };

}
