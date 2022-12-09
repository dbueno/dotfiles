{ config, lib, pkgs, ... }:

{
  programs.vim.plugins = with pkgs.vimPlugins; [
    vim-ocaml
  ];

  programs.vim.extraConfig = ''
    if executable('ocamlmerlin')
        let &rtp = &rtp . "," . fnamemodify(exepath("ocamlmerlin"), ":p:h:h") . "/share/merlin/vim"
    endif

    " disables mappings from default ocaml ftplugin
    let g:no_ocaml_maps = 1
  '';
}
