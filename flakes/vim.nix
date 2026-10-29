{ pkgs, ... }:

let
  vueLs = "${pkgs.vue-language-server}/lib/language-tools/packages/language-server";
  codelldb = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadim.vscode-lldb/adapter/codelldb";
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    configure = {
      customRC = ''
        lua vim.g.nix = { vue_ls = "${vueLs}", codelldb = "${codelldb}" }
        lua vim.opt.rtp:prepend("${../config/nvim}")
        luafile ${../config/nvim}/init.lua
      '';
      packages.main.start = with pkgs.vimPlugins; [
        lackluster-nvim
        mini-nvim
        which-key-nvim
        (nvim-treesitter.withPlugins (
          p: with p; [
            c
            cpp
            cmake
            lua
            vim
            vimdoc
            bash
            json
            yaml
            nix
            markdown
            markdown_inline
            javascript
            typescript
            tsx
            vue
            html
            css
            scss
          ]
        ))
        nvim-lspconfig
        blink-cmp
        friendly-snippets
        fzf-lua
        oil-nvim
        gitsigns-nvim
        conform-nvim
        nvim-dap
        nvim-nio
        nvim-dap-ui
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    clang-tools
    vtsls
    prettierd
    lua-language-server
    nixd
    nixfmt
    ripgrep
    fd
    fzf
    nodejs
    vue-language-server
    vscode-langservers-extracted
  ];

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.monaspace
  ];
}
