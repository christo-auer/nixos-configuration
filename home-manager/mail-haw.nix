{ pkgs, lib, private-values, ... } : {
  accounts.email.accounts.haw =
  {
    passwordCommand = "${lib.meta.getExe pkgs.pass} haw/mail | head -n 1";
    primary = true;
    maildir = {
      path = "haw";
    };

    notmuch.enable = true;
    notmuch.neomutt = {
      enable = true;

      virtualMailboxes = [
        {
            name = "All";
            query = "tag:haw";
        }
      ];

    };


    folders.inbox = "INBOX";
    folders.drafts = "Drafts";
    folders.sent = "Sent Items";
    folders.trash = "Deleted Items";

    getmail.mailboxes = [ "Archive" "Drafts" "Sent Items" "Deleted Items" "Junk Email" ];

    neomutt = {
      enable = true;
      mailboxType = "maildir";


      extraConfig = ''
        set delete=yes
        macro index,pager \Cu "<shell-escape>~/.config/neomutt/scripts/mail-sync.sh haw inbox<enter>" "sync inbox"
        macro index,pager \Cy "<shell-escape>~/.config/neomutt/scripts/mail-sync.sh haw<enter>" "sync everything"

        mailboxes +INBOX +Archive +Drafts +"Sent Items" +"Deleted Items" +"Junk Email"
        # Encryption/Signing
        set crypt_autosign = "yes"
        unset crypt_autopgp
        set smime_self_encrypt= "yes"
        set crypt_autosmime = "yes"
        set smime_default_key = "${private-values.mail.haw.smime_default_key}"

        set pgp_self_encrypt = "yes"
        set pgp_default_key = "${private-values.mail.haw.pgp_default_key}"

        set nm_query_type = "messages"

        macro index,pager L   "<vfolder-from-query>tag:haw AND "
        '';
    };

    mbsync = {

      enable = true;

      create = "both";
      expunge = "maildir";

      groups.haw = {

        channels = 
          let channel-patterns = {
            "archive" = "Archive";
            "junk"    = "Junk Email";
            "sent"    = "Sent Items";
            "trash"   = "Deleted Items";
            "drafts"  = "Drafts";
          }; in {
            inbox = {
              extraConfig = {
                SyncState = "*";
                Sync = "all";
              };
            };
          }
          // 
          lib.attrsets.mapAttrs'
          (name: pattern : {
            name = name;
            value = {
              nearPattern = pattern;
              farPattern = pattern;
              extraConfig.SyncState = "*";
            };
          }) channel-patterns;

      };

    };

  }
  // private-values.mail.haw.config; # private configurgtion data
}
