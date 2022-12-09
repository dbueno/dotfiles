{ config, lib, pkgs, ... }:

let
  unbroken-vim-ocaml =
    pkgs.vimUtils.buildVimPlugin {
      pname = "vim-ocaml";
      version = "2022-11-14";
      src = pkgs.fetchFromGitHub {
        owner = "ocaml";
        repo = "vim-ocaml";
        rev = "335ebc6e433afb972aa797be0587895a11dddab5";
        sha256 = "079pfc897zz36mb36as7vq38b9njy42phjvmgarqlyqrwgjc0win";
      };
      meta.homepage = "https://github.com/ocaml/vim-ocaml/";
    };
in


{
  programs.vim.plugins = with pkgs.vimPlugins; [
    unbroken-vim-ocaml
  ];

  programs.vim.extraConfig = ''
    if executable('ocamlmerlin')
        let &rtp = &rtp . "," . fnamemodify(exepath("ocamlmerlin"), ":p:h:h") . "/share/merlin/vim"
    endif

    " disables mappings from default ocaml ftplugin
    let g:no_ocaml_maps = 1
  '';
}
