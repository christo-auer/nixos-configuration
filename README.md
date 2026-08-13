> The following summary of my configuration was created using an LLM.

# NixOS Configuration

A flake-based NixOS configuration for two hosts and a single user:

- **Hosts** — `waka` (Intel laptop) and `kokiri` (Tuxedo / AMD laptop).
- **User** — `chris`, managed declaratively through Home Manager.
- **Compositor** — `mango`, a Hyprland-like Wayland compositor.
- **Editor** — Neovim, configured entirely through `nixvim` (declarative plugins, LSP, keymaps).

The home-manager configuration is host-agnostic and is applied to either host independently with `home-manager switch`; the NixOS side does not import `home-manager.nixosModules.home-manager`.

## Repository layout

```
.
├── flake.nix                       # inputs + outputs (homeConfigurations + nixosConfigurations)
├── flake.lock
├── LICENSE
├── nixos/                           # system-level modules
│   ├── configuration.nix           # shared base config (boot, network, pipewire, flatpak, …)
│   ├── users.nix                    # the chris user
│   ├── keyd.nix                     # kernel-level keyboard remapping (vi navigation layers)
│   ├── snapper.nix                  # btrfs timeline snapshots for / and /home
│   ├── nfs-mount.nix                # lazy NFS automounts to the "nagi" home server
│   ├── docker.nix
│   ├── btrbk.nix                    # kokiri-only local btrfs backups
│   ├── waka.nix                     # host: Intel blacklist + VA-API
│   ├── kokiri.nix                   # host: Tuxedo drivers, kernel params, iwlwifi
│   ├── waka-hardware-configuration.nix
│   └── kokiri-hardware-configuration.nix
└── home-manager/                    # user-level modules (imported by home.nix)
    ├── home.nix                     # entry point, lays down ./config/* files
    ├── mango.nix                    # active compositor (sway.nix is legacy)
    ├── waybar.nix  foot.nix  fuzzel.nix
    ├── stylix.nix                   # themeing (base16 ayu-mirage)
    ├── neovim.nix                   # nixvim-based editor + mail compose workflow
    ├── zsh.nix  zellij.nix  git.nix
    ├── gpg-pass.nix  ssh.nix
    ├── mail.nix  mail-haw.nix  mail-private.nix  mbsync.nix  neomutt.nix  davmail.nix
    ├── firefox.nix  yazi.nix  vscode.nix  fonts.nix  mime-apps.nix  misc.nix
    ├── user-packages.nix
    ├── ai.nix  mcp.nix              # opencode + Claude Desktop MCP config
    ├── eilmeldung.nix  mango.nix
    └── config/                      # non-Nix assets staked to ~/.config
        ├── davmail/  fuzzel/  neomutt/  nvim/  stylix/  vifm/  way-displays/  yazi/
```

## Flake architecture

`flake.nix` declares twelve inputs:

**Core**
- `nixpkgs` (unstable), `home-manager` (follows nixpkgs).

**Community modules**
- `nixvim` — declarative Neovim.
- `stylix` — declarative theming.
- `nur` — community package set.
- `nix-flatpak` — declarative flatpak management.

**Specialised tools**
- `tuxedo-nixos` — Tuxedo laptop drivers, only imported by `kokiri`.
- `claude-desktop` — NixOS package for Anthropic's Claude Electron app.
- `mcp-servers-nix` — Nix-packaged MCP servers, used to generate the Claude Desktop config.
- `eilmeldung` — a FreshRSS-backed newsfeed TUI developed by the user.
- `mango` — the active Wayland compositor.

**Private**
- `private-config-data` — fetched from `git+ssh://chris@nagi-remote/…` with `flake = false`. It is *not* a flake; it is consumed as a plain path. See [Secret / config separation](#secret--config-separation).

### Outputs

```
homeConfigurations."chris"     # host-agnostic; applied with `home-manager switch`
nixosConfigurations.waka      # nixosSystem {  hardware + waka.nix  ++ common-modules }
nixosConfigurations.kokiri    # nixosSystem { tuxedo + hardware + kokiri.nix + btrbk } ++ common-modules
```

The home configuration composes an `eilmeldung` overlay, the community modules (`nix-flatpak`, `stylix`, `nixvim`, `nur`, `eilmeldung`, `mango`) and `home-manager/home.nix`. `extraSpecialArgs` injects `private-values`, `private-data`, `claude-desktop`, `mcp-servers-nix`, `eilmeldung` into every home module.

`common-modules`, shared by both hosts: `configuration.nix`, `snapper.nix`, `nfs-mount.nix`, `users.nix`, `docker.nix`, `keyd.nix`.

## Hosts: waka vs kokiri

| Aspect | waka | kokiri |
|---|---|---|
| Vendor / silicon | Intel laptop | Tuxedo laptop, AMD CPU |
| Hardware module | none host-specific | `tuxedo-drivers` + `tuxedo-control-center` |
| Kernel tweaks | blacklist `intel_ipu6*` (notoriously broken IPU6) | `pcie_aspm=off`; `iwlwifi 11n_disable=0 power_save=1` |
| Graphics | Intel VA-API (`LIBVA_DRIVER_NAME = "iHD"`) | — |
| Microcode | `kvm-intel` | `kvm-amd` |
| Btrfs subvols | `@root @home @tmp @nix @var` | `@root @nix @var @home @tmp` |
| NFS autofs stubs in HW config | — | `/mnt/nagi/home` and `/mnt/nagi/storage` (`systemd-1`) |
| Backups | — | `btrbk.nix`: hourly snapshot-only of `@home` and `@backup_Storage` to a backup disk |

`waka` is the everyday Intel laptop. `kokiri` is the Tuxedo/AMD machine that additionally serves as the local backup host.

## Secret / config separation

A deliberate three-tier scheme keeps the public repository shareable:

1. **Public repo** — everything declarative and shareable, including module structure, keymaps, and theming.
2. **`private-config-data`** — a private (but non-secret) flake input, consumed through two channels:
   - `private-values = import (private-config-data + "/values.nix")` — a Nix attrset interpolated by modules. Known keys: `git.name`, `ssh.settings` (the *entire* ssh config), `ssh.key` (the gpg-agent ssh key id), `mail.haw.config` / `mail.haw.{smime_default_key, pgp_default_key}`, `mail.private.config` / `mail.private.pgp_default_key`, `firefox.bookmarks`.
   - `private-data` — the raw store path, used when whole files are needed: `${private-data}/nvim/snippets/mail.json`, `${private-data}/pass-git-helper/`, `${private-data}/media/{eagle,airhorn,klausurrelevant}.ogg`.
3. **`pass` store** — actual secrets (mail passwords, FreshRSS password, HAW VPN creds), fetched at runtime via `passwordCommand` / `cmd:pass …`, never written to the nix store.

The Nagi home server (`10.0.64.2`) is the source of all of these: the private git repo is fetched over SSH from `nagi-remote`, NFS storage and home are automounted from it, and FreshRSS runs on it.

## System-level modules (`nixos/`)

- **`configuration.nix`** — the shared base: systemd-boot EFI, NetworkManager, firewall opens `53317/tcp` for LocalSend, `time.timeZone = "Europe/Berlin"`, `en_US.UTF-8`, flatpak, fwupd, xdg portal, Bluetooth, `hardware.graphics.enable`, CUPS, pipewire (pulse + alsa + wireplumber), tlp, udisks2, GNOME keyring. System packages include VPN tooling (`networkmanager-fortisslvpn`, `networkmanager-openconnect`, `openfortivpn`, `wireguard-tools`) and `nh`. A custom overlay replaces `jdk8` with `openjdk8-bootstrap` to work around a problematic JDK8 build. Deliberate convenience tradeoff: `security.sudo.wheelNeedsPassword = false` (passwordless sudo for wheel).
- **`users.nix`** — `chris`, normal user with groups `wheel audio video dialout networkmanager input docker lp`, shell `zsh`.
- **`keyd.nix`** — a standout design idea. `keyd` runs at the kernel level so the remapping works in TTYs and every compositor. Two keyboards are defined: an `internal_keyboard` (specific device ids) and a catch-all `default`. Capslock becomes Escape (vim ergonomics). `tab = "overload(nav, tab)"` — tap is Tab, hold activates a `nav` layer whose `hjkl` are arrows, `space` is backspace, `n/m` home/end, `u/i` pageup/down. On the internal keyboard, `slash = "overload(shift, slash)"`. This is a QMK-style layered keymap implemented at the daemon level, and it is the foundation of the **vi-everywhere** design that propagates to `mango`, `foot`, `zellij`, and `neovim`.
- **`snapper.nix`** — btrfs timeline snapshots, two configs: `home` (`SUBVOLUME="/home"`, `ALLOW_USERS=["chris"]` — user self-service restore) and `root` (`SUBVOLUME="/"`). Both `TIMELINE_CREATE`/`TIMELINE_CLEANUP`.
- **`nfs-mount.nix`** — `rpcbind`, plus two `systemd.mounts`/`automounts` to `10.0.64.2:/storage` and `10.0.64.2:/home` mounted under `/mnt/nagi/...` with `TimeoutIdleSec = "600"` (lazy unmount after 10 min idle).
- **`docker.nix`** — a single-line `virtualisation.docker.enable`.
- **`btrbk.nix`** (kokiri only) — mounts btrfs root at `/mnt/btrfs-root`, the backup `/mnt/backup` and FAT storage `/mnt/Storage` as `noauto`; two hourly `snapshotOnly` btrbk instances (`@home` → `/mnt/backup/home`, `@backup_Storage` → `/mnt/backup/storage`), preserving 24h min / 48h total.
- **`waka.nix` / `kokiri.nix`** — host names + the per-host kernel/graphics/wifi knobs from the table above.

## Home Manager modules (`home-manager/`)

### Compositor and Wayland

- **`mango.nix`** — the most elaborate module and the active compositor. `sway.nix` still exists but is **not imported** and would not build if it were (it references `./config/sway/*.ogg` files that have since moved into the private repo; `home.nix` imports `mango.nix` and not `sway.nix`, and `waybar.nix` targets the `mango-session.target`). `default-apps` is a small declarative table (start-key, toggle-key, auto-start, scratch, title, command: neomutt, spotify-player, eilmeldung, yazi, zellij, gotop); `scratch-apps` and `autostart-apps` are *derived* via `builtins.filter`, and `focus-binds`/`move-binds`/`ws-view`/`ws-move`/`start-binds`/`toggle-binds` are generated programmatically from these tables. This **data-driven keymap generation** is the same pattern `sway.nix` and the mbsync modules use — small declarative tables plus helpers, avoiding raw string soup. Modes: `resize` (hjkl), `menu` (fuzzel choosers for nm-connection, bluetooth, pipewire-sink, pass, otp), `session` (lock/suspend/reboot/poweroff/logout), `presentation` (wl-present mirror/kill/output/region/scaling/freeze/custom). Borders 1px, 2px gaps, touchpad full configuration. **Deep stylix integration**: every compositor color slot (`rootcolor`, `bordercolor`, `focuscolor`, `dropcolor`, …) is bound to `config.lib.stylix.colors.baseXX`, so the compositor palette is generated from the base16 scheme. Blur, shadows on floating only, corner radius 6, animations. Sound bites (`eagle`, `airhorn`, `klausurrelevant`) are pulled from `${private-data}/media/`.
- **`waybar.nix`** — the bar is pinned to a specific Alexays/waybar commit and compiled with `mesonFlags = [ "-Dmango=true" "-Dwwan=disabled" ]` so it links against mango's IPC. `modules-left` mirror mango (`mango/workspaces`, `mango/window`, `mango/keymode` — the latter shows the active mango mode with hint strings); `modules-right` carries a bespoke `custom/mail` script that, via `curl imaps://`, queries `STATUS INBOX (UNSEEN)` for both the private and HAW accounts, fetching the per-account credentials from `pass private/mail` and `pass haw/mail`. The CSS is "glassy flat" — `background: alpha(@base01, 0.8)` so the mango layer shows through, with `@base0X` variables injected by stylix. `systemd.targets = ["mango-session.target"]` ties the bar to the compositor session.
- **`foot.nix`** — vim-style scrollback bindings (`Ctrl+b/f` page, `Ctrl+i/u` line, `Ctrl+/` search, `Ctrl+p/n` prompt prev/next).
- **`fuzzel.nix`** — launcher; staked `./config/fuzzel` chooser scripts (nm-connection, bluetooth, pipewire-sink, pass, otp).
- **`sway.nix`** — legacy/unused. Kept as a reference for the design pattern; do not re-import.

### Theming

- **`stylix.nix`** — `autoEnable = true`, `base16Scheme = ayu-mirage` (catppuccin-mocha, catppuccin-frappe, dracula, ayu-light, and nord are kept as commented alternates). Cursor `Simp1e-Catppuccin-Mocha` size 32, icons `flat-remix`. Opacity desktop 0.95 / terminal 0.85. Fonts: `sansSerif` Figtree (from `cantarell-fonts`), `monospace` SauceCodePro Nerd Font Mono, `emoji` NotoColorEmoji. Loaded only at the home-manager level. Consumers of the stylix palette: `mango.nix` (compositor color slots via `config.lib.stylix.colors.baseXX`), `waybar.nix` (CSS `@base0X`), `zellij` (stylix target generates the theme), and `vifm` (`config/vifm/colors/base16.vifm`). **Wallpaper handling is intentionally bespoke**: rather than `stylix.image`, a `awww` service and a `awww-cycle-wallpaper` systemd unit rotate `~/Pictures/wallpapers/*.{jpg,jpeg,png}` every 5 minutes and restart after suspend.

### Editor

- **`neovim.nix`** — the configuration uses `nixvim`, so plugins, LSP, keymaps, and options are declared in Nix rather than via an `init.lua`. `viAlias`, `vimAlias`, `vimdiffAlias`, `defaultEditor`; Python 3 with `pynvim`; `nvimpager` (also exported as `PAGER` in `home.nix`). Notable keymaps: `<leader>g` neogit, `<leader>d` MiniFiles, `<leader>f` telescope find_files, `<leader>oo/ot/oa` opencode (ask/toggle/select), `<leader>l*` lspsaga family, `<leader>li` jdtls organize_imports. LSP servers: `nixd`, `lua_ls`, `texlab`, `pyls`, `rust_analyzer`; **jdtls is configured separately via `plugins.jdtls`** with a comment explaining why: configuring it through `lsp.servers` spawns two LSP clients per Java buffer. `noice` is configured to skip `['$/progress']` notifications so jdtls progress can be silenced. Plugin stack: `treesitter` (bash/java/json/lua/make/markdown/nix/python/regex/toml/vim/vimdoc/xml/yaml), `telescope`, `neogit`, `gitsigns`, `firenvim` (browser takeover `never`), `dap` (codelldb from `vscode-extensions.vadimn.vscode-lldb`), `lspsaga`, `which-key`, `vimtex` (`latexmk`, `zathura` view), `mini.*`, `luasnip` (snipmate + VS-Code snippets from `./config/nvim/snippets`), `blink-cmp` (lsp/path/snippets/buffer/latex-symbols/calc sources), `render-markdown` (with `opencode_output` in `file_types`). Plugins built from source via `fetchFromGitHub`: `cargo-nvim`, `blink-calc`.

  The **mail-compose workflow** is deployed through `extraFiles`: `lua/apply_mail_settings.lua`, `lua/mail_picker.lua`, and `query-address.sh` are materialised into the runtimepath. On `Filetype mail`, `apply_mail_settings()` sets `textwidth=0`, `spell`, `spelllang=de`, `wrap`, `columns=100`, and maps `<leader>m` to a telescope-based recipient picker. `query-address.sh` queries `abook` and the local LDAP bridge exposed by davmail (see the mail stack). A private `mail.json` snippet is pulled from `${private-data}/nvim/snippets/mail.json`.

  The files in `config/nvim/lua/plugins/` (`blink-cmp`, `java`, `treesitter`, `which-key`, `disabled`) are **not loaded by nixvim**; they look like scaffolding from a lazy.nvim template and are kept for reference — note `disabled.lua` is a kill-list including `mason.nvim` with `WARNING: don't enable on NixOS`.

### Shell, multiplexer, git

- **`zsh.nix`** — autosuggestions + syntax highlighting, `zsh-vi-mode`, `pure` prompt (with a `print` shim fixing a pure-vs-zsh interaction). `initContent` wires `^j` to accept autosuggestion, `Ctrl-h` to `up-directory`, and a `recordgif` function (slurp → wf-recorder → ffmpeg → mogrify). Aliases include `ngit` (`nvim -c Git`), `ls` → `exa`, `nix-edit` (opens `flake.nix home.nix configuration.nix`), `viture` (eDP-1 disable + DP-3 scale 1.5 — VR headset workaround), `g` → `git`. The `haw-vpn` script reuses a single `pass` entry that holds both the VPN password (line 1) and the username (trailing line): `sudo openfortivpn vpn1.haw-landshut.de -u $(pass haw/mail | tail -n1 | cut -d: -f2) -p $(pass haw/mail | head -n1)`. `programs.fzf.enable = false` (being migrated through zsh-vi-mode).
- **`zellij.nix` — multiplexer** with `enableZshIntegration = false` (used as a standalone scratch terminal), `default_layout = "compact"`, `default_mode = "locked"`. Keybinds are built through a small Nix DSL (`to_bind key action`) rather than raw strings; `normal` mode is vi-like (`j/k`, `Ctrl-f/b`, `gg/G`, `/`, `n/N`), `locked` mode has `Alt-h/l/t/x` for tab management. The `theme_dir` points to `${xdg.configHome}/zellij/themes` so stylix's zellij target takes effect.
- **`git.nix`** — `lfs.enable`, `signing.format = ""` (no signing), `fetch.prune`, `defaultBranch.name = "main"`, `rebase.autoSquash`, plus aliases and `extraConfig.credential.helper = "!pass-git-helper $@"` (git credentials via `pass`). `pass-git-helper` config is staked from `${private-data}/pass-git-helper`. `programs.jujutsu` is configured with the user name from `private-values`, `editor = nvim`, and an `init = ["git" "init"]` alias.

### Credentials

- **`gpg-pass.nix` — the auth backbone.** `gpg` enabled; `gpg-agent` with `pinentry-gnome3`, `enableSshSupport = true` and `sshKeys = [ private-values.ssh.key ]` — so the **gpg-agent doubles as the SSH agent**, keyed by the user's key id from the private repo. Cache TTLs of 86400s (24h) for both the gpg and ssh caches — a single source of truth for authentication. `gopass` and `password-store` (with `pass-otp`) are installed, `PASSWORD_STORE_DIR = ~/.password-store`.
- **`ssh.nix`** — `enableDefaultConfig = false`. The *entire* ssh config is sourced from `private-values.ssh.settings`; nothing ssh-related lives in the public repo.

### Mail stack

A pipeline rather than a single module: **HAW Exchange → davmail → mbsync → notmuch → neomutt**, with recipient lookup wired back into Neovim.

- **`davmail.nix`** — `davmail.properties` (staked verbatim) bridges the HAW Exchange (MWN) server to local IMAP/CalDAV *and* exposes a **local LDAP server on `:1389`** (`davmail.ldapPort`). Run as a `systemd.user.services.davmail` with `Restart = always`. This is the integration point: Exchange → davmail → local LDAP on 1389, which the nvim mail compose workflow queries.
- **`mail.nix`** — imports `mail-haw.nix` + `mail-private.nix`; sets `accounts.email.maildirBasePath = ".mail"`.
- **`mail-haw.nix`** (HAW university account) — `passwordCommand = "pass haw/mail | head -n 1"`, `primary`, maildir `haw`. Exchange folder naming (`Sent Items`, `Deleted Items`). neomutt extraConfig carries **S/MIME + PGP autosign/self-encrypt** with `smime_default_key` and `pgp_default_key` from `private-values.mail.haw`, plus `\Cu`/`\Cy` sync macros that call `~/.config/neomutt/scripts/mail-sync.sh`. mbsync channels are generated programmatically with `lib.attrsets.mapAttrs'` from a `channel-patterns` attrset (inbox + archive/junk/sent/trash/drafts, `SyncState = "*"`, `create = "both"`, `expunge = "maildir"`). Account host/user/imap/smtp is merged via `} // private-values.mail.haw.config;`.
- **`mail-private.nix`** — `passwordCommand = "pass private/mail"`, `smtp.tls.useStartTls = true`. PGP autosign/self-encrypt (no S/MIME). mbsync with `create = "maildir"`, `expunge = "maildir"`, `extraConfig.account = { AuthMechs = "LOGIN"; User = "chris"; PassCmd = "pass private/mail"; }`. Channels (archive/cron/sent/drafts/trash) generated programmatically; merged with `private-values.mail.private.config`.
- **`mbsync.nix`** — `services.mbsync` with `frequency = "*:0/15"` (every 15 min) and `postExec = "notmuch new"`.
- **`neomutt.nix`** — power-user mail client. Stakes `./config/neomutt` (scripts, pandoc, `colortheme.neomuttrc`, `powerline.neomuttrc`, mailcap). `programs.notmuch.hooks.postNew` tags `+haw` on `folder:/^haw.*/` and `+private` on `folder:/^private.*/` — account routing by folder. `sort = "threads"`, `editor = "nvim"`, `vimKeys`, sidebar (width 25). Binds (`Ctrl-k/j` sidebar prev/next, `Ctrl-o` open, `R` group-reply, `gr` recall-message, `W` sync-mailbox), macros (`Ctrl-h/l` sidebar toggle, `{`/`}` source the per-account configs, `a` add-to-abook, `A` archive with a confirmappend/delete toggle). The standout **`m` (compose) macro**: pipes the message through `pandoc -f gfm -t plain` and `pandoc -f gfm -t html` with a custom `email.html` template + `pandoc.css`, attaches both, sets `group-alternatives` content-type — i.e. **markdown → multipart/alternative email composition**.

### Browser and files

- **`firefox.nix`** — locked-down Firefox. `nativeMessagingHosts`: `tridactyl-native`, `gopass-jsonapi` (vim-style browsing + pass in browser). Policies: `DisableTelemetry`, `DisableFirefoxStudies`, `DisablePocket`. **Locked preferences**: disable normandy, pocket, sponsored-top-sites; `signon.rememberSignons = false` (no in-browser password save — pass owns this); bookmarks bar `never`. Default profile: `search.default = "ddg"`, bookmarks from `private-values.firefox.bookmarks`, extensions from nur: `firenvim`, `tridactyl`, `ublock-origin`, `gopass-bridge`.
- **`yazi.nix`** — `trash-cli` (deletes go to trash); plugins include `restore` and `time-travel` (walks btrfs snapshots — pairs with `snapper`/`btrbk`). `open-and-hide` dispatches a mango scratchpad toggle then opens the file — yazi is wired into the compositor. `mgr.ratio = [0 1 1]`; openers xdg-open, libreoffice-draw, evince, a custom `pdf2remarkable` script, gimp, neovim, extract. `shellWrapperName = "y"`.
- **`vscode.nix`** — `mutableExtensionsDir = false` (extensions are fully declarative). Extensions include `vscodevim.vim`, `redhat.java`, `vscjava.vscode-gradle`, `vscjava.vscode-java-debug`, `vadimcn.vscode-lldb` (the same debugger the nvim `dap` config reuses).
- **`fonts.nix`** — fontconfig defaults (sansSerif Figtree, monospace SauceCodePro Nerd Font Mono) and a package spread covering DejaVu, Ubuntu Classic, nerd-fonts, Noto Color Emoji, Font Awesome, corefonts, vista-fonts, Jost, Figtree, Fira Sans, etc.
- **`mime-apps.nix`** — xdg defaults (http/https/html → firefox; pdf → zathura; GIF/PNG/JPEG → vimiv).
- **`misc.nix`** — `programs.spotify-player` and `services.network-manager-applet`.

### Packages, AI tooling, newsfeed

- **`user-packages.nix`** — package spread spanning development (`gh`, `github-copilot-cli`, `jdt-language-server`, `ripgrep`), media (`darktable`, `ffmpeg`, `imagemagick`, `inkscape-with-extensions`, `gimp3`, `feh`, `vlc`), office (`libreoffice-fresh`, hunspell/hyphen de-de + en-us), **science/optimisation (`coinmp`, `lp_solve`, `scip`)**, hardware (`simple-scan`, `brightnessctl`, `pavucontrol`, `wl-mirror`, `way-displays`, `wl-clipboard`, `slurp`, `sox`, `pipectl`), viewers (`zathura`, `vimiv-qt`, `evince`), tui (`btop`, `eza`, `pure-prompt`), `texliveFull`. `programs.btop` with `vim_keys = true`. `programs.nh` (`clean.enable`, `clean.extraArgs = "--keep-since 4d --keep 3"`, `flake = ~/Documents/workspace/nixos-configuration`). `programs.direnv` + `nix-direnv`. `services.flatpak`: `uninstallUnmanaged = true` and `update.onActivation = true`; manages `us.zoom.Zoom` (the only declared flatpak). A `claude-desktop-workaround` overrides `claude-desktop`'s `nodePackages` to inject pkgs.asar.
- **`ai.nix`** — imports `mcp.nix`. `programs.opencode`: MCP `mcp-nixos` and two providers — `edenai` (Eden AI gateway, routing several hosted and open models) and `ollama` (`http://localhost:11434/v1`, local models) — with cloud and local routing.
- **`mcp.nix`** — `mcpConfig = mcp-servers-nix.lib.mkConfig pkgs { format = "json"; fileName = "claude_desktop_config.json"; programs = { time.enable; context7.enable; }; settings.servers.mcp-nixos = { command = "nix"; args = ["run" "github:utensils/mcp-nixos" "--"]; }; }`, materialised to `~/.config/Claude/claude_desktop_config.json`.
- **`eilmeldung.nix`** — the user's own FreshRSS-backed newsfeed TUI. Startup runs `sync`; `after_sync_commands` query the last sync, auto-mark heise+ and "Anzeige" ads as read via regex, tag reviews, and refresh. `login_setup` posts to `http://10.0.64.2:8081/api/greader.php/` (FreshRSS on nagi), user `chris`, `password = "cmd:pass private/freshrss"`. Enclosures → mpv / vlc. A `pipe-through-opencode` script shapes the input as `"summarize this in at most 5 bullet points: "` and feeds `opencode --agent newsreader run`; bindings pipe articles to the summariser (`A`/`a` with/without url) or to neomutt (`Z` composes `neomutt -s "{title}"` with the article html). A tight RSS → AI summary → mail workflow.

## Cross-cutting design themes

- **Vi-everywhere** — `keyd` (kernel layers), `mango`, `foot`, `zellij`, `neovim`, `vifm`, `btop`, `firefox` (tridactyl) all use hjkl and the same navigation vocabulary.
- **Data-driven keymap generation** — `mango` and the legacy `sway` derive scratch/toggle/startup/autostart/window-rule bindings from a small `default-apps` table via `mapAttrs'`/`mapAttrsToList`; the mail mbsync channels are generated the same way; `zellij` uses a `to_bind` Nix DSL. Small declarative tables plus helpers, not raw strings.
- **Reproducible everything** — `nixvim` (declarative nvim), `stylix` (declarative theming), flatpak-declarative (Zoom), vscode `mutableExtensionsDir = false`, waybar pinned to a commit, extensions from `nur`.
- **Self-hosted `nagi` ecosystem** — FreshRSS (`eilmeldung` reads it), NFS storage + home automounts, the private-config-data git repo, all on `10.0.64.2` / `nagi-remote`.
- **AI integration** — `opencode` (cloud via Eden AI + local via Ollama), `claude-desktop` (mango named scratchpad, packaged from the `claude-desktop` flake with an asar workaround), `mcp-servers-nix` (generates `claude_desktop_config.json`), nvim `<leader>oo/ot/oa` opencode bindings, `eilmeldung` piping articles to opencode's `newsreader` agent.
- **Tight mail stack** — davmail (Exchange → local IMAP + LDAP :1389) → mbsync (every 15 min) → notmuch (folder-based `+haw`/`+private` tagging) → neomutt (markdown → multipart/alternative via pandoc); recipient lookup from within nvim via abook + the davmail LDAP bridge.
- **Host separation** — `common-modules` shared; host files are tiny and only carry what differs (CPU/graphics/kernel, Tuxedo drivers, `btrbk`).

## Applying the configuration

Prerequisites:
- The private-config-data repo must be reachable over SSH at `chris@nagi-remote`. If it is not, the evaluation fails on `import (private-config-data + "/values.nix")`.
- The `pass` store must contain the entries referenced via `passwordCommand` (`private/mail`, `haw/mail`, `private/freshrss`).

Switch the system (apply the nixosConfiguration of the current host):

```
nh os switch
```

Apply the host-agnostic home configuration for the current machine:

```
home-manager switch
```

The flake lives at `~/Documents/workspace/nixos-configuration`, which is also set as `programs.nh.flake`.
