{ config, pkgs, lib, ... } : {

  # non-home manager configured files
  home.file.".config/neomutt" = {
    source = ./config/neomutt;
    recursive = true;
  };

  programs.notmuch = {
    enable = true;
    hooks.postNew = ''
      notmuch tag +haw -- folder:"/^haw.*/" 
      notmuch tag +private -- folder:"/^private.*/" 
    '';

  };


  programs.neomutt = {
    enable = true;

    sort = "threads";

    editor = "nvim";

    vimKeys = true;

    unmailboxes = true;


    sidebar = {
      enable = true;
      # format = "%B %* [%?N?%N / ?%S]";
      # shortPath = true;
      width = 25;
    };

    binds = [       
      {
        key = "\\Ck";
        map = [ "index" "pager" ];
        action = "sidebar-prev";
      }
      {
        key = "\\Cj";
        map = [ "index" "pager" ];
        action = "sidebar-next";
      }
      {
        key = "\\Co";
        map = [ "index" "pager" ];
        action = "sidebar-open";
      }
      {
        key = "R";
        map = [ "index" "pager" ];
        action = "group-reply";
      }
      {
        key = "gr";
        map = [ "index" "pager" ];
        action = "recall-message";
      }
      {
        key = "W";
        map = [ "index" "pager" ];
        action = "sync-mailbox";
      }
      {
        key = "N";
        map = [ "index" "pager" ];
        action = "search-opposite";
      }
      {
        key = "E";
        map = [ "index" "pager" ];
        action = "extract-keys";
      }
      {
        key = "E";
        map = [ "index" "pager" ];
        action = "extract-keys";
      }
    ];

    macros = [
      {
        key = "\\Ch";
        map = [ "index" "pager" ];
        action = "<enter-command>set sidebar_visible=no<enter>";
      }
      {
        key = "\\Cl";
        map = [ "index" "pager" ];
        action = "<enter-command>set sidebar_visible=yes<enter>";
      }
      {
        key = "{";
        map = [ "index" "pager" ];
        action = "'<sync-mailbox><enter-command>source ~/.config/neomutt/private<enter><change-folder>!<enter>'";
      }
      {
        key = "}";
        map = [ "index" "pager" ];
        action = "'<sync-mailbox><enter-command>source ~/.config/neomutt/haw<enter><change-folder>!<enter>'";
      }
      {
        key = "a";
        map = [ "index" "pager" ];
        action = "'<pipe-message>abook --add-email-quiet<return>' 'Add this sender to Abook'";
      }
      {
        key = "A";
        map = [ "index" ];
        action = ":set confirmappend=no delete=yes\\n<tag-prefix><save-message>=Archive\\n<sync-mailbox>:set confirmappend=yes delete=ask-yes\\n'";

      }
      {
        key = "m";
        map = [ "compose" ];
        action = 
          ''<enter-command>set pipe_decode<enter>\
          <pipe-message>pandoc -o /tmp/message.txt -f gfm -t plain<enter>\
          <pipe-message>pandoc -s -c ~/.config/neomutt/pandoc/pandoc.css -o /tmp/message.html -f gfm -t html --resource-path ~/.config/neomutt/pandoc --template email<enter>\
          <enter-command>unset pipe_decode<enter>\
          <attach-file>/tmp/message.txt<enter>\
          <attach-file>/tmp/message.html<enter>\
          <tag-entry><previous-entry><tag-entry><group-alternatives>" \
          "Convert markdown to HTML5 and plaintext alternative content types"'';

      }
    ];


    extraConfig = ''
      source ~/.config/neomutt/powerline.neomuttrc
      source ~/.config/neomutt/colortheme.neomuttrc

      set edit_headers=yes
      set header_cache = ~/.cache/mutt
      set forward_format = "Fwd: %s"
      set sort_aux = reverse-last-date-received
      set date_format="%y/%m/%d %I:%M%p"
      set sig_on_top = yes
      set autoedit = yes
      set include = yes
      set sleep_time = 0
      set wait_key = no

      set sidebar_visible
      set sidebar_folder_indent
      set sidebar_divider_char = '│'
      set sidebar_indent_string = '  '\'
      set mail_check_stats

      set mailcap_path = "~/.config/neomutt/mailcap"

      auto_view text/html
      alternative_order text/plain text/enriched text/html

      set crypt_replyencrypt
      set crypt_replysign
      set crypt_replysignencrypted
      set pgp_show_unusable=no

      '';

  };

}
