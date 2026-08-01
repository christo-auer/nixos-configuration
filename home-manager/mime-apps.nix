{ ... }: {


  xdg.enable = true;
  xdg.mime.enable = true;

  xdg.mimeApps= {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
      "text/html" = ["firefox.desktop"];
      "application/pdf" = ["org.pwmt.zathura.desktop"];
      "image/gif" = ["vimiv.desktop"];
      "image/png" = ["vimiv.desktop"];
      "image/jpeg" = ["vimiv.desktop"];
    };

  };


}
