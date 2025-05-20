# ycmd in nixpkgs is from 2020. like wtf. how does ycm + python work for
# anyone. the embedded parso it uses doesn't support parsing the version string
# '3.10.x' because the regex doesn't support the '10' because it uses \d.
# *shrugs violently*
# below, override ycmd and YouCompleteMe to use python38
result: prev: {
  ycmd = prev.ycmd.override {python = result.python38;};
  vimPlugins = prev.vimPlugins.extend (vresult: vprev: {
    # Copied this from the vim-plugins overrides.nix in nixpkgs
    YouCompleteMe = vprev.YouCompleteMe.overrideAttrs (old: {
      buildPhase = ''
        substituteInPlace plugin/youcompleteme.vim \
          --replace "'ycm_path_to_python_interpreter', '''" \
          "'ycm_path_to_python_interpreter', '${result.python38}/bin/python3'"

        rm -r third_party/ycmd
        ln -s ${result.ycmd}/lib/ycmd third_party
      '';
    });
  });
}
