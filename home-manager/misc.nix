{ pkgs, ... } : 
{
  # === spotify-player ===
  programs.spotify-player = {
    enable = true;
    package = pkgs.spotify-player.override {
      withAudioBackend = "pulseaudio";
    };

    settings = {
      border_type = "Rounded";
      layout = {
        library = {
            album_percent = 60;
            playlist_percent = 20;
          };
          playback_window_position = "Top";

        };



    };

  };

services.network-manager-applet.enable = true;



}
