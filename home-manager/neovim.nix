{ pkgs, config, lib, private-data, ... } : {

  home.file.".config/nvim/snippets" = {
    source = ./config/nvim/snippets;
    recursive = true;
  };

  home.file.".config/nvim/snippets/mail.json".source = "${private-data}/nvim/snippets/mail.json";

  home.packages = [
    pkgs.nvimpager
  ];

  programs.nixvim = {
    enable = true;
    nixpkgs.source = pkgs.path;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = false;
    withPython3 = true;

    extraPython3Packages = ps: with ps; [
      pynvim
    ];

    extraConfigLua = ''
      vim.diagnostic.config({
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = "",
                [vim.diagnostic.severity.WARN] = "",
                [vim.diagnostic.severity.INFO] = "",
                [vim.diagnostic.severity.HINT] = "",
            },
            linehl = {
                [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
                [vim.diagnostic.severity.WARN] = 'WarningMsg',
                [vim.diagnostic.severity.INFO] = 'InfoMsg',
                [vim.diagnostic.severity.HINT] = 'HintMsg',
            },
            numhl = {
                [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
                [vim.diagnostic.severity.WARN] = 'WarningMsg',
                [vim.diagnostic.severity.INFO] = 'InfoMsg',
                [vim.diagnostic.severity.HINT] = 'HintMsg',
            },
        },
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        virtual_text = {
          source = true,
        },
      })

      vim.api.nvim_create_autocmd({'UIEnter'}, {
          callback = function(event)
              local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
              if client ~= nil and client.name == "Firenvim" then
                  require('noice').cmd('disable')

                  vim.defer_fn(function()
                      vim.opt.guifont = "SauceCodePro Nerd Font Mono:h24"
                    end,
                    1000)
              end
          end
      })

      require('telescope').load_extension('ui-select')
    '';

    opts = {
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
      autoindent = true;
      linebreak = true;
      showbreak = "↪";
      smartcase = true;
      number = true;
      relativenumber = true;
      # wildmode = "longest,list,full";
      textwidth = 0;
      signcolumn = "yes:1";
      scrolloff = 8;
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    extraFiles = {
      "lua/apply_mail_settings.lua".source = ./config/nvim/lua/apply_mail_settings.lua;
      "lua/mail_picker.lua".source = ./config/nvim/lua/mail_picker.lua;
      "query-address.sh".source = ./config/nvim/query-address.sh;
    };

    autoCmd = [
      {
        command = "lua require('apply_mail_settings').apply_mail_settings()";
        event = [ "Filetype" ];
        pattern = [ "mail" ];
      }
    ];


    keymaps = [
      { key = "<space>"   ; action = "<leader>"                        ; mode = "n"; }
      { key = "<C-\><C-\>"; action = "<C-\><C-n>"                        ; mode = "t"; }
      { key = "<C-H>"     ; action = "<cmd>set invhlsearch<CR>"        ; mode = "n"; }
      { key = "0"         ; action = "^"                               ; mode = "n"; }
      { key = "<leader>w" ; action = "<cmd>w<enter>"                   ; mode = "n"; }
      { key = "<TAB>"     ; action = "<C-w>"                           ; mode = "n"; } 
      { key = "<leader>g" ; action = "<cmd>lua require('neogit').open({ kind = 'replace'})<CR>"   ; }
      { key = "<leader>d" ; action = "<cmd>lua MiniFiles.open()<CR>"   ; }
      { key = "<leader>la"; action = "<cmd>Lspsaga code_action<CR>"    ; }
      { key = "<leader>K";  action = "<cmd>Lspsaga hover_doc<CR>"    ; }
      { key = "<leader>lr"; action = "<cmd>Lspsaga rename<CR>"         ; }
      { key = "<leader>ld"; action = "<cmd>Lspsaga goto_definition<CR>"; }
      { key = "<leader>lD"; action = "<cmd>Lspsaga peek_definition<CR>"; }
      { key = "<leader>lo"; action = "<cmd>Lspsaga outline<CR>"        ; }
      { key = "<leader>lF"; action = "<cmd>Lspsaga finder<CR>"         ; }
      { key = "<leader>lf"; action = "<cmd>Lspsaga show_line_diagnostics<CR>"         ; }
      { key = "<leader>ln"; action = "<cmd>Lspsaga diagnostic_jump_next<CR>"         ; }
      { key = "<leader>lp"; action = "<cmd>Lspsaga diagnostic_jump_prev<CR>"         ; }
      { key = "<leader>li"; action = "<Cmd>lua require'jdtls'.organize_imports()<CR>"; }
      { key = "<leader>f" ; action = "<cmd>lua require('telescope.builtin').find_files({ cwd = require('telescope.utils').buffer_dir()})<CR>"; mode = "n"; }
      { key = "<leader>oo"; action = "<cmd>lua require('opencode').ask(\"@this \", { submit = true })<CR>"; mode = ["n" "v" "x"]; } 
      { key = "<leader>ot"; action = "<cmd>lua require('opencode').toggle()<CR>"; mode = ["n" "t"]; } 
      { key = "<leader>oa"; action = "<cmd>lua require('opencode').select()<CR>"; mode = ["n" "t"]; } 
      ];

      lsp = {

        servers = {
          # NOTE: jdtls is configured via `plugins.jdtls` below, not here, to
          # avoid spawning two LSP clients per Java buffer.
          nixd.enable                 = true;
          lua_ls.enable               = true;
          texlab.enable               = true;
          pylsp.enable                = true;
          rust_analyzer.enable        = true;
        };
      };



    extraPlugins = 
      let 
      cargo-nvim  = (pkgs.vimUtils.buildVimPlugin {
          name = "cargo-nvim";
          src = pkgs.fetchFromGitHub {
          owner = "nwiizo";
          repo = "cargo.nvim";
          rev = "2b470e72a5bcf9e5b4185944cf76b9a24fb093ec";
          sha256 = "1y3awwb8jpw6j7m92hgwk6n421idnlhsl9wxlrcz02nyv77vbrxs";
          };
        });
      blink-calc  = (pkgs.vimUtils.buildVimPlugin {
          name = "blink-calc";
          src = pkgs.fetchFromGitHub {
          owner = "joelazar";
          repo = "blink-calc";
          rev = "199e8a5fe356d553d33a3511ca28e625dac5c470";
          sha256 = "0z600bicnxh43qqyjdgbkngj0y1xkd03wzj10nkfpsydzm0sy3yz";
          };
        });
      in
    [
      cargo-nvim
      blink-calc
      pkgs.vimPlugins.telescope-ui-select-nvim
    ];

    plugins = 
    {

      auto-session.enable = true; 

      lspconfig.enable = true;

      lazydev = {
          enable= true;
      };

      copilot-lua = {
          enable = false;
      };

      # eye candy/vis/status
      neoscroll = {
          enable = true;
          settings.duration_multiplier = 0.4;
      };

      indent-blankline.enable = true;
      indent-o-matic.enable = true;
      web-devicons = {
        enable = true;
        settings = {
          color_icons = true;
          strict      = true;
        };
      };
      lualine.enable = true;

      # snippets
      friendly-snippets.enable = true;
      luasnip = {
          enable = true;
          fromSnipmate = [
          {
              paths = "snippets";
          }];
          fromVscode = [
          {
              paths = ./config/nvim/snippets;
          } ];
      };

      # git
      neogit.enable = true;
      gitsigns.enable = true;

      # misc
      firenvim = {
        enable = true;
        settings = {

          globalSettings = {
            alt = "all";
          };
          localSettings = {
            ".*" = {
              cmdline = "firenvim";
              content = "text";
              priority = 0;
              selector = "textarea";
              takeover = "never";
            };
          };

        };

      };


      neoclip = {
          enable = true;
          autoLoad = true;
      };

      # lsp
      lspkind.enable = true;


      jdtls = {
        enable = true;
        settings = {
          root_dir = {
            __raw = "require('jdtls.setup').find_root({'.git', '.projectroot', 'gradlew'})";
          };
          cmd = [
            (lib.getExe pkgs.jdt-language-server)
            "-data" { __raw =''"${config.home.homeDirectory}/.cache/jdtls/workspace" .. vim.fn.getcwd()''; } 
            "-configuration" "${config.home.homeDirectory}/.cache/jdtls/config"
          ];

          extraOptions = 
          {
            handlers = { __raw =
              ''
              {
                ['language/status'] = function(_, result)
                  -- Print or whatever.
                end,
                ['$/progress'] = function(_, result, ctx)
                  -- disable progress updates.
                end,
              }
              '';
            };
          };

        };



      };

      dap = {
        enable = true;
        # dap-ui.enable = true; 
        adapters.servers.codelldb = rec {
          port = "\${port}";
          executable = {
            command = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
            args = ["--port" "${port}"];
          }; 
        }; 
        configurations.rust = [{
          type = "codelldb"; 
          name = "Rust Debug"; 
          request = "launch";
          program.__raw = "
            function()
              vim.fn.jobstart('cargo build') 
              return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end
            "; 
        }

        ];
      };

      # rustaceannvim = {
      #   enable = true;
      # };


      lspsaga = {
        enable = true;
        settings = {
          outline.keys = {
            toggleOrJump = "<CR>";
          };
          lightbulb.enable = false;
        };
      };

      opencode.enable = true;
      blink-cmp-git.enable  =true;
      blink-cmp-latex.enable  =true;

      blink-cmp = {
        enable = true;
        settings = {
          appearance = {
            nerd_font_variant = "normal";
            use_nvim_cmp_as_default = true;
          };
          completion = {
            accept = {
              auto_brackets = {
                enabled = true;
                semantic_token_resolution = {
                  enabled = false;
                };
              };
            };
            documentation = {
              auto_show = true;
            };
          };
          keymap = {
            preset = "enter";
            "<C-j>" = [ "select_next" "fallback"];
            "<C-k>" = [ "select_prev" "fallback"];
            "<C-u>" = [ "scroll_documentation_down" "fallback"];
            "<C-i>" = [ "scroll_documentation_up" "fallback"];
          };
          signature = {
            enabled = true;
          };
          sources = {
            default = [ "lsp" "path" "snippets" "buffer" "latex-symbols" "calc" ];

            providers = {
              git = {
                  module = "blink-cmp-git";
              };
              latex-symbols = { 
                module = "blink-cmp-latex";
              };
              calc = {
                  module = "blink-calc";
              };
            };
          };

        };

      };



      notify.enable = true;
      # mini
      mini = {
        enable = true;
        modules = {
          ai        = { };
          align     = { };
          pairs     = { };
          comment   = { };
          operators = { };
          pairs     = { };
          splitjoin = { };
          # notify    = { };
          surround  = { 
            respect_selection_type = true;
          };
          files = {
            mappings = {
              go_in_plus     = "<CR>";
              close          = "<ESC>";
              show_help      = "?";
              };

            };
          bracketed = { };
        };

      };

      which-key.enable = true;

      # vim tex
      vimtex = {
        enable = true;

        texlivePackage = pkgs.texliveFull;

        settings = {
          view_method = "zathura_simple";
          compiler_method = "latexmk";
          fold_enabled = 1;
          indent_enabled = 1;
          quickfix_mode = 0;
          quickfix_ignore_filters = [ "overfull" "underfull" "references" "packages" "default" ];
        };

      };

      # telescope
      telescope = {
        enable = true;

        settings = {
          defaults = {

            mappings = 
            let togglePreview ="require('telescope.actions.layout').toggle_preview";
            in
            {
              n = {
                t = { __raw = "require('telescope.actions').toggle_selection + require('telescope.actions').move_selection_next"; };
                T = { __raw = "require('telescope.actions').toggle_all"; };
                D = { __raw = "require('telescope.actions').delete_buffer + require('telescope.actions').move_selection_next"; };
                q = { __raw = "require('telescope.actions').close"; };
                s = { __raw = "require('telescope.actions').select_horizontal"; };
                v = { __raw = "require('telescope.actions').select_vertical"; };
                p = { __raw = togglePreview; };
              };
              i = {
                "<C-P>" = { __raw = togglePreview; };
              };
            };
# path_display = "shorten";
          };
          pickers = { };
          extensions = { };
        };

        keymaps = {
          "<leader>F" = "find_files"; 
          "<leader>b" = "buffers sort_lastused=true initial_mode=normal"; 
          "<leader>B" = "current_buffer_fuzzy_find"; 
          "<leader>G" = "live_grep"; 
          "<leader>c" = "command_history"; 
          "<leader>r" = "registers" ;
        };

      };

      # treesitter
      treesitter = {
        enable = true;

        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          java
          json
          lua
          make
          markdown
          nix
          python
          regex
          toml
          vim
          vimdoc
          xml
          yaml
        ];
      };


      # floaterm
      floaterm = {
        enable = true;
        settings = {
          name = "float";
          width = 0.9;
          height = 0.9;
          title = "float";
          keymap_toggle = "<leader><tab>";
        };
      };

      lsp-format = {
          enable = true;
      };

      # linter
      lint = {

        enable = true;

        lintersByFt = { 
          nix = [ "nix" ];
          markdown = [ "markdownlint"];
          lua = [ "luacheck" ];
          python = [ "ruff" ];
          rust = [ "clippy" ];
        };

        luaConfig.post = ''
            local clippy = require('lint').linters.clippy;
            clippy.ignore_exitcode = true;
          '';

      };


      # noice
      noice = {
        enable = true;

        settings = {
          messages.enabled = false;
          notify.enabled = false;

          routes = [
            {
              filter = {
                event = "lsp";
                kind = "progress";
                cond = {__raw = 
                  ''function(message)
                      local client = vim.tbl_get(message.opts, "progress", "client")
                      return client == "jdtls"
                    end'';
                  };
                };
              opts = { skip = true; };
            }
          ];
        };

      };

      markdown-preview.enable = true;

      render-markdown = {
        enable = true;
        settings = {
          bullet = {
            icons = [
              "◆ "
                "• "
                "• "
            ];
            right_pad = 1;
          };
          file_types = [ "markdown" "quarto" "opencode_output" ];

          anti_conceal = {
            enabled = true;
            disabled_modes = false;
            above = 0;
            below = 0;
          };

          code = {
            above = " ";
            below = " ";
            border = "thick";
            language_pad = 2;
            left_pad = 2;
            position = "right";
            right_pad = 2;
            sign = false;
            width = "block";
          };
          heading = {
            border = true;
            icons = [
              "1 "
                "2 "
                "3 "
                "4 "
                "5 "
                "6 "
            ];
            position = "inline";
            sign = false;
            width = "full";
          };
          render_modes = [ "n" "c" "t" ];
          signs = {
            enabled = false;
          };
        };

      };



    };

  };


}

