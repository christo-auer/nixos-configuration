{ pkgs, lib, private-values, ... } : 
{
  accounts.email.accounts.private = {
    passwordCommand = "${lib.meta.getExe pkgs.pass} show private/www.strato.de/christopher";

    smtp.tls.useStartTls = true;
    maildir = {
      path = "private";
    };

    notmuch.enable = true;
    notmuch.neomutt = {
      enable = true;

      virtualMailboxes = [
        {
            name = "All";
            query = "tag:private";
        }
      ];

    };

    folders.inbox = "INBOX";
    folders.drafts = "Drafts";
    folders.sent = "Sent";
    folders.trash = "Trash";

    getmail.mailboxes = [ "Archive" "Cron" "Drafts" "Sent" "Deleted Messages" "Junk" ];

    neomutt = {
      enable = true;
      mailboxType = "maildir";


      extraConfig = ''
        set delete=yes
        macro index,pager \Cu "<shell-escape>~/.config/neomutt/scripts/mail-sync.sh private inbox<enter>" "sync inbox"
        macro index,pager \Cy "<shell-escape>~/.config/neomutt/scripts/mail-sync.sh private<enter>" "sync everything"

        mailboxes +INBOX +Archive +Cron +Drafts +"Sent" +"Deleted Messages" +"Junk" 
        # Encryption/Signing
        set crypt_autosign = "yes"
        unset crypt_autopgp

        set pgp_self_encrypt = "yes"
        set pgp_default_key = "${private-values.mail.private.pgp_default_key}"

        set nm_query_type = "messages"

        macro index,pager L   "<vfolder-from-query>tag:private AND "
        '';
    };

    mbsync = {

      enable = true;

      create = "maildir";
      expunge = "maildir";

      extraConfig.account = {
        AuthMechs = "LOGIN";
        User = "chris";
        PassCmd = "${lib.meta.getExe pkgs.pass} private/mail";
      };

      groups.private = {

        channels = 
          let patterns = {
            "archive" = "Archive";
            "cron"    = "Cron";
            "sent"    = "Sent";
            "drafts"  = "Drafts";
            "trash"   = "Deleted Messages";
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
          }) patterns ;

      };

    };

  } // private-values.mail.private.config;
}

