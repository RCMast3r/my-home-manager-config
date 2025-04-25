{ pkgs, ... }:
let
in {
  home-manager = { enable = true; };
  vscode = {
    enable = true;

    # will at some point include these: https://github.com/RCMast3r/vscode_extensions/blob/master/combined_ext_list.sh
    extensions = [
      pkgs.vscode-extensions.eamodio.gitlens
      pkgs.vscode-extensions.ms-python.vscode-pylance
      pkgs.vscode-extensions.marp-team.marp-vscode
      pkgs.vscode-extensions.ms-python.black-formatter
      pkgs.vscode-extensions.ms-python.python
      pkgs.vscode-extensions.ms-vscode-remote.remote-ssh
      pkgs.vscode-extensions.twxs.cmake
      pkgs.vscode-extensions.ms-vscode.cmake-tools
      pkgs.vscode-extensions.shd101wyy.markdown-preview-enhanced
      pkgs.vscode-extensions.llvm-vs-code-extensions.vscode-clangd
      pkgs.vscode-extensions.xaver.clang-format
      pkgs.vscode-extensions.jnoortheen.nix-ide
      pkgs.vscode-extensions.vscodevim.vim
      pkgs.vscode-extensions.rust-lang.rust-analyzer
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "cpp-helper";
        publisher = "amiralizadeh9480";
        version = "0.3.4";
        sha256 = "sha256-TXvKciewjm/Mw6t60Z56C5yjujfONO/gLuijctkvCzg=";
      }
      {
        name = "platformio-ide";
        publisher = "platformio";
        version = "3.3.1";
        sha256 = "sha256-zBZFpOWJ4JEv6qu9XT1u0uspZ+N2wKrpL3joC+/t/zs=";
      }
      {
        name = "cmake-language-support-vscode";
        publisher = "josetr";
        version = "0.0.9";
        sha256 = "sha256-LNtXYZ65Lka1lpxeKozK6LB0yaxAjHsfVsCJ8ILX8io=";
      }
      {
        name = "doc-doxygen";
        publisher = "dusartvict";
        version = "0.3.16";
        sha256 = "sha256-33zA0ya0MFfNnusR8Ro75weOwTLv1ksXOtiGp9hArzI=";
      }
    ];

    userSettings = {
      "files.userSettings" = "on";
      "files.autoSave" = "afterDelay";
      "cmake.configureOnOpen" = false;
      "platformio-ide.autoRebuildAutocompleteIndex" = false;
      "editor.minimap.enabled" = false;
      "window.zoomLevel" = 1;
      "[python]" = { "editor.defaultFormatter" = "ms-python.black-formatter"; };
      "terminal.external.linuxExec" = "/bin/bash";
    };
    keybindings = [
      {
        key = "ctrl+shift+x";
        command = "-workbench.view.extensions";
        when = "viewContainer.workbench.view.extensions.enabled";
      }
      {
        key = "ctrl+shift+x";
        command = "workbench.action.closeActiveEditor";
      }
      {
        key = "ctrl+w";
        command = "-workbench.action.closeActiveEditor";
      }
      {
        key = "ctrl+shift+tab";
        command = "-workbench.action.quickOpenNavigatePreviousInEditorPicker";
        when = "inEditorsPicker && inQuickOpen";
      }
      {
        key = "ctrl+shift+tab";
        command = "-workbench.action.quickOpenLeastRecentlyUsedEditorInGroup";
        when = "!activeEditorGroupEmpty";
      }
      {
        key = "ctrl+shift+tab";
        command = "workbench.action.previousEditor";
      }
      {
        key = "ctrl+pageup";
        command = "-workbench.action.previousEditor";
      }
      {
        key = "ctrl+tab";
        command = "workbench.action.nextEditor";
      }
      {
        key = "ctrl+pagedown";
        command = "-workbench.action.nextEditor";
      }
    ];
  };

  nixvim = {
    enable = false;
    extraConfigLuaPre = ''
      -- Global undo files
      vim.cmd("set undodir=~/.nvim/undodir")
      vim.cmd("set undofile")
      vim.cmd("set expandtab")
      vim.cmd("set tabstop=2")
      vim.cmd("set softtabstop=2")
      vim.cmd("set shiftwidth=2")
      vim.wo.number = true
      vim.wo.relativenumber = true
      vim.o.cmdheight = 0
      vim.opt.termguicolors = true
    '';

    globals = { mapleader = " "; };

    clipboard = {
      register = "unnamedplus";
      providers = {
        wl-copy.enable = true;
        xclip.enable = false;
        xsel.enable = false;
      };
    };

    colorscheme = "nightfox";
    extraPlugins = [ pkgs.vimPlugins.nightfox-nvim ];

    keymaps = [
      {
        key = "<leader>o";
        action =
          "<cmd>lua if vim.bo.filetype == 'neo-tree' then vim.cmd.wincmd 'p' else vim.cmd.Neotree 'focus' end <cr>";
        options = { desc = "Toggle focus to/from neo-tree"; };
      }
      {
        key = "<leader>e";
        action = "<cmd>Neotree toggle<cr>";
        options = { desc = "Toggle neo-tree ui"; };
      }
    ];

    plugins = {
      # which-key.enable = true;
      luasnip.enable = true;

      # windsurf-nvim = {
      #   enable = true;
      #   settings = {
      #     enable_chat = true;
      #   };
      # };

      cmp = {
        enable = true;
        settings = {
          snippet = {
            expand = ''
              function(args)
                require('luasnip').lsp_expand(args.body)
              end
            '';
          };
          mapping = {
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" =
              "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<CR>" =
              "cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace, })";
            "<S-CR>" =
              "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
            "<C-j>" = "cmp.mapping.select_next_item()";
            "<C-k>" = "cmp.mapping.select_prev_item()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.close()";
          };
          window = {
            completion = { border = "solid"; };
            documentation = { border = "solid"; };
          };

          sources = [
            { name = "luasnip"; }
            { name = "nvim_lsp"; }
            { name = "nvim_lsp_document_symbol"; }
            { name = "nvim_lsp_signature_help"; }
            {
              name = "buffer";
            }
            # { name = "codeium"; }
          ];
        };

      };

      clangd-extensions = {
        enable = true;
        enableOffsetEncodingWorkaround = true;
      };

      lspkind = {
        enable = true;
        cmp.enable = true;
      };

      ltex-extra.enable = true;
      lsp-format.enable = true;

      none-ls = {
        enable = true;
        enableLspFormat = false;
        sources = {
          code_actions = {
            gitrebase.enable = true;
            gitsigns.enable = true;
            proselint.enable = true;
            statix.enable = true;
          };

          diagnostics = {
            selene.enable = true;
            gitlint.enable = true;
            cmake_lint.enable = true;
            deadnix.enable = true;
            fish.enable = true;
            # Installed with matlab
            mlint = {
              enable = true;
              package = null;
            };
            markdownlint_cli2.enable = true;
            protolint.enable = true;
            hadolint.enable = true;
            proselint.enable = true;
            mypy.enable = true;
          };

          formatting = {
            # alejandra.enable = true;
            nixfmt = {
              enable = true;
              package = pkgs.nixfmt-rfc-style;
            };
            black.enable = true;
            clang_format = {
              enable = true;
              settings = ''{disabled_filetypes = {"proto"}}'';
            };
            cmake_format.enable = true;
            isort.enable = true;
            stylua.enable = true;
            mdformat.enable = true;
            tidy.enable = true;
            yamlfmt.enable = true;
          };
          hover.printenv.enable = true;
        };
        # which-key.enable = true;
        # which-key.settings.spec = [
        #   {
        #     __unkeyed-1 = "<leader>l";
        #     desc = "LSP";
        #     icon = "🌡";
        #   }
        #   {
        #     __unkeyed-1 = "K";
        #     desc = "LSP hover action";
        #   }
        #   {
        #     __unkeyed-1 = "<leader>le";
        #     desc = "Go to references";
        #   }
        #   {
        #     __unkeyed-1 = "<leader>ld";
        #     desc = "Go to declaration";
        #   }
        #   {
        #     __unkeyed-1 = "<leader>lD";
        #     desc = "Go to definition";
        #   }
        #   {
        #     __unkeyed-1 = "<leader>li";
        #     desc = "Go to implementation";
        #   }
        #   {
        #     __unkeyed-1 = "<leader>lt";
        #     desc = "Go to type definition";
        #   }
        #   {
        #     __unkeyed-1 = "<leader>la";
        #     desc = "List code actions";
        #   }
        #   {
        #     __unkeyed-1 = "<leader>lf";
        #     desc = "Show function signature";
        #   }
        #   {
        #     __unkeyed-1 = "<leader>lr";
        #     desc = "Rename symbol";
        #   }
        #   {
        #     __unkeyed-1 = "<leader>lq";
        #     desc = "Show diagnostics";
        #   }
        #   {
        #     __unkeyed-1 = "<space>ll";
        #     desc = "Show floating diagnostics";
        #   }
        # ];

        settings.on_attach = ''
          function(client, bufnr)
              require('lsp-format').on_attach(client, bufnr)
          end
        '';

      };

      lsp = {
        enable = true;

        keymaps = {
          diagnostic = {
            "[d" = "goto_prev";
            "d]" = "goto_next";
            "<leader>lq" = "setloclist";
            "<space>ll" = "open_float";
          };

          lspBuf = {
            K = "hover";
            "<leader>le" = "references";
            "<leader>ld" = "declaration";
            "<leader>lD" = "definition";
            "<leader>li" = "implementation";
            "<leader>lt" = "type_definition";
            "<leader>la" = "code_action";
            "<leader>lf" = "signature_help";
            "<leader>lr" = "rename";
          };
        };

        servers = {
          clangd = {
            enable = true;
            # Add tpp files to the lsp list and remove proto
            filetypes = [ "c" "cpp" "objc" "objcpp" "cuda" "tpp" ];
            onAttach.function = ''
              if client == "clangd" then
                  require("clangd_extensions.inlay_hints").setup_autocmd()
                  require("clangd_extensions.inlay_hints").set_inlay_hints()
              end
            '';
          };
          lua_ls.enable = true;
          pyright.enable = true;
          # TODO: verify that I dont need to add neo cmake
          cmake.enable = true;
          marksman.enable = true;
          bashls.enable = true;
          fortls.enable = true;
          biome.enable = true;
          # Add the cpp for comment grammar/spelling
          ltex = {
            enable = true;
            filetypes = [
              "bib"
              "gitcommit"
              "markdown"
              "org"
              "plaintex"
              "rst"
              "rnoweb"
              "tex"
              "pandoc"
              "quatro"
              "rmd"
              "context"
              "html"
              "xhtml"
              "mail"
              "text"
              "rust"
            ];
            settings.enabled = [
              "bibtex"
              "context"
              "context.tex"
              "html"
              "latex"
              "markdown"
              "org"
              "restructuredtext"
              "rsweave"
              "c"
              "cpp"
              "objc"
              "objcpp"
              "cuda"
              "tpp"
              "rust"
            ];
          };
          lemminx.enable = true;
          yamlls.enable = true;
          dockerls.enable = true;
          docker_compose_language_service.enable = true;
          rust_analyzer = {
            enable = true;
            cargoPackage = pkgs.cargo;
            rustcPackage = pkgs.rustc;
            installRustc = false;
            installCargo = false;
          };
          nil_ls.enable = true;
          texlab.enable = true;
        };
      };

      which-key.settings.spec = [
        {
          __unkeyed-1 = "<leader>l";
          desc = "LSP";
          icon = "🌡";
        }
        {
          __unkeyed-1 = "K";
          desc = "LSP hover action";
        }
        {
          __unkeyed-1 = "<leader>le";
          desc = "Go to references";
        }
        {
          __unkeyed-1 = "<leader>ld";
          desc = "Go to declaration";
        }
        {
          __unkeyed-1 = "<leader>lD";
          desc = "Go to definition";
        }
        {
          __unkeyed-1 = "<leader>li";
          desc = "Go to implementation";
        }
        {
          __unkeyed-1 = "<leader>lt";
          desc = "Go to type definition";
        }
        {
          __unkeyed-1 = "<leader>la";
          desc = "List code actions";
        }
        {
          __unkeyed-1 = "<leader>lf";
          desc = "Show function signature";
        }
        {
          __unkeyed-1 = "<leader>lr";
          desc = "Rename symbol";
        }
        {
          __unkeyed-1 = "<leader>lq";
          desc = "Show diagnostics";
        }
        {
          __unkeyed-1 = "<space>ll";
          desc = "Show floating diagnostics";
        }
        {
          __unkeyed-1 = "<leader>f";
          desc = "File search";
        }
        {
          __unkeyed-1 = "<leader>s";
          desc = "Telescope search";
        }
      ];

      telescope = {
        enable = true;
        extensions = {
          media-files.enable = true;
          ui-select.enable = true;
          undo.enable = true;
          fzf-native.enable = true;
          # frecency.enable = true;
        };
        keymaps = {
          "<leader>fC" = {
            action = "colorscheme";
            options = {
              desc = "Search colorschemes";
              silent = true;
            };
          };
          "<leader>ff" = {
            action = "find_files";
            options = {
              desc = "Search file names";
              silent = true;
            };
          };
          "<leader>ft" = {
            action = "live_grep";
            options = {
              desc = "Search recent files";
              silent = true;
            };
          };
          "<leader>fr" = {
            action = "oldfiles";
            options = {
              desc = "Git status";
              silent = true;
            };
          };
          "<leader>fc" = {
            action = "grep_string";
            options = {
              desc = "Find string under cursor";
              silent = true;
            };
          };
          "<leader>sh" = {
            action = "help_tags";
            options = {
              desc = "Find in help";
              silent = true;
            };
          };
          "<leader>sm" = {
            action = "man_pages";
            options = {
              desc = "Search man pages";
              silent = true;
            };
          };
          "<leader>sr" = {
            action = "registers";
            options = {
              desc = "Search registers";
              silent = true;
            };
          };
          "<leader>sk" = {
            action = "keymaps";
            options = {
              desc = "Search keymaps";
              silent = true;
            };
          };
          "<leader>sc" = {
            action = "commands";
            options = {
              desc = "Search commands";
              silent = true;
            };
          };
        };
      };

      # File icons for telescope and neo-tree
      web-devicons.enable = true;

      # Key command help
      which-key.enable = true;

      # Buffer line
      lualine.enable = true;

      # Make brackets readable
      rainbow-delimiters.enable = true;

      # Make TODO: highlighting work
      todo-comments.enable = true;

      # File viewer
      neo-tree.enable = true;
      # Syntax highlighting
      treesitter = {
        enable = true;
        folding = false;
        settings = {
          incremental_selection.enable = true;
          indent.enable = true;
          highlight.enable = true;
        };
      };
      treesitter-context.enable = true;

      # Show color codes in the editor and a color picker
      ccc = {
        enable = true;
        settings.highlighter.auto_enable = true;
      };
    };

  };

  zsh = {
    enable = true;
    oh-my-zsh.enable = true;
    oh-my-zsh.plugins = [
      "1password"
      "aliases"
      "alias-finder"
      "ansible"
      "ant"
      "apache2-macports"
      "arcanist"
      "archlinux"
      "arduino-cli"
      "argocd"
      "asdf"
      "autopep8"
      "aws"
      "azure"
      "battery"
      "bazel"
      "bbedit"
      "bedtools"
      "bgnotify"
      "bower"
      "branch"
      "brew"
      "bridgetown"
      "bun"
      "bundler"
      "cabal"
      "cake"
      "cakephp3"
      "capistrano"
      "cask"
      "catimg"
      "celery"
      "charm"
      "chezmoi"
      "chruby"
      "cloudfoundry"
      "codeclimate"
      "coffee"
      "colemak"
      "colored-man-pages"
      "colorize"
      "command-not-found"
      "common-aliases"
      "compleat"
      "composer"
      "conda"
      "conda-env"
      "copybuffer"
      "copyfile"
      "copypath"
      "cp"
      "cpanm"
      "dash"
      "dbt"
      "debian"
      "deno"
      "dircycle"
      "direnv"
      "dirhistory"
      "dirpersist"
      "dnf"
      "dnote"
      "docker"
      "docker-compose"
      "doctl"
      "dotenv"
      "dotnet"
      "droplr"
      "drush"
      "eecms"
      "emacs"
      "ember-cli"
      "emoji"
      "emoji-clock"
      "emotty"
      "encode64"
      "extract"
      "eza"
      "fabric"
      "fancy-ctrl-z"
      "fasd"
      "fastfile"
      "fbterm"
      "fig"
      "firewalld"
      "flutter"
      "fluxcd"
      "fnm"
      "forklift"
      "fossil"
      "frontend-search"
      "fzf"
      "gas"
      "gatsby"
      "gcloud"
      "geeknote"
      "gem"
      "genpass"
      "gh"
      "git"
      "git-auto-fetch"
      "git-commit"
      "git-escape-magic"
      "git-extras"
      "gitfast"
      "git-flow"
      "git-flow-avh"
      "github"
      "git-hubflow"
      "gitignore"
      "git-lfs"
      "git-prompt"
      "glassfish"
      "globalias"
      "gnu-utils"
      "golang"
      "gpg-agent"
      "gradle"
      "grails"
      "grc"
      "grunt"
      "gulp"
      "hanami"
      "hasura"
      "helm"
      "heroku"
      "heroku-alias"
      "history"
      "history-substring-search"
      "hitchhiker"
      "hitokoto"
      "homestead"
      "httpie"
      "invoke"
      "ionic"
      "ipfs"
      "isodate"
      "istioctl"
      "iterm2"
      "jake-node"
      "jenv"
      "jfrog"
      "jhbuild"
      "jira"
      "jruby"
      "jsontools"
      "juju"
      "jump"
      "kate"
      "keychain"
      "kind"
      "kitchen"
      "kitty"
      "kn"
      "knife"
      "knife_ssh"
      "kops"
      "kubectl"
      "kubectx"
      "kube-ps1"
      "lando"
      "laravel"
      "laravel4"
      "laravel5"
      "last-working-dir"
      "lein"
      "lighthouse"
      "localstack"
      "lol"
      "lpass"
      "lxd"
      "macos"
      "macports"
      "magic-enter"
      "man"
      "marked2"
      "marktext"
      "mercurial"
      "meteor"
      "microk8s"
      "minikube"
      "mise"
      "mix"
      "mix-fast"
      "mongo-atlas"
      "mongocli"
      "mosh"
      "multipass"
      "mvn"
      "mysql-macports"
      "n98-magerun"
      "nanoc"
      "nats"
      "ng"
      "nmap"
      "node"
      "nodenv"
      "nomad"
      "npm"
      "nvm"
      "oc"
      "octozen"
      "opentofu"
      "operator-sdk"
      "otp"
      "pass"
      "paver"
      "pep8"
      "percol"
      "per-directory-history"
      "perl"
      "perms"
      "phing"
      "pip"
      "pipenv"
      "pj"
      "please"
      "pm2"
      "pod"
      "podman"
      "poetry"
      "poetry-env"
      "postgres"
      "pow"
      "powder"
      "powify"
      "pre-commit"
      "procs"
      "profiles"
      "pyenv"
      "pylint"
      "python"
      "qodana"
      "qrcode"
      "rails"
      "rake"
      "rake-fast"
      "rand-quote"
      "rbenv"
      "rbfu"
      "rbw"
      "react-native"
      "rebar"
      "redis-cli"
      "repo"
      "ros"
      "rsync"
      "ruby"
      "rust"
      "rvm"
      "safe-paste"
      "salt"
      "samtools"
      "sbt"
      "scala"
      "scd"
      "screen"
      "scw"
      "sdk"
      "sfdx"
      "sfffe"
      "shell-proxy"
      "shrink-path"
      "sigstore"
      "singlechar"
      "skaffold"
      "snap"
      "spring"
      "sprunge"
      "ssh"
      "ssh-agent"
      "stack"
      "starship"
      "stripe"
      "sublime"
      "sublime-merge"
      "sudo"
      "supervisor"
      "suse"
      "svcat"
      "svn"
      "svn-fast-info"
      "swiftpm"
      "symfony"
      "symfony2"
      "symfony6"
      "systemadmin"
      "systemd"
      "tailscale"
      "taskwarrior"
      "terminitor"
      "term_tab"
      "terraform"
      "textastic"
      "textmate"
      "thefuck"
      "themes"
      "thor"
      "tig"
      "timer"
      "tldr"
      "tmux"
      "tmux-cssh"
      "tmuxinator"
      "toolbox"
      "torrent"
      "transfer"
      "tugboat"
      "ubuntu"
      "ufw"
      "universalarchive"
      "urltools"
      "vagrant"
      "vagrant-prompt"
      "vim-interaction"
      "vi-mode"
      "virtualenv"
      "virtualenvwrapper"
      "volta"
      "vscode"
      "vundle"
      "wakeonlan"
      "watson"
      "wd"
      "web-search"
      "wp-cli"
      "xcode"
      "yarn"
      "yii"
      "yii2"
      "yum"
      "z"
      "zbell"
      "zeus"
      "zoxide"
      "zsh-interactive-cd"
      "zsh-navigation-tools"
    ];
    profileExtra = ''
      export PATH=$HOME/.local/bin:$HOME.platformio/penv/bin:$PATH
    '';
  };
  git = {
    enable = true;
    userEmail = "rcmast3r1@gmail.com";
    userName = "Ben Hall";
  };

}
