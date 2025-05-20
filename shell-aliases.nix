{
  config,
  lib,
  pkgs,
  ...
}:
let
  ssh-script = pkgs.writeShellScriptBin "my-ssh" ''
    env ssh "$@"
  '';
  ssh-cmd = "${ssh-script}/bin/my-ssh";
  ls-command = "${pkgs.coreutils}/bin/ls -Frth --color=always";
in
(if pkgs.stdenv.isDarwin then { lldb = "PATH=/usr/bin:$PATH lldb"; } else { })
// {
  a = "${ls-command}";
  al = "${ls-command} -l";
  aa = "${ls-command} -a";
  aal = "${ls-command} -al";
  # there's always a story behind aliases like these
  rm = "rm -i";
  c = "clear";
  g = "git";
  p = "git pull";
  top = "git rev-parse --show-toplevel";
  pd = "cd \"$OLDPWD\"";
  # Evaluates to an iso-conformant date.  The iso-conformance is good because
  # lexicographic order coincides with date order.  'nows' just has seconds and
  # is also iso-conformant.
  now = "date '+%Y-%m-%dT%H%M'";
  nows = "date '+%Y-%m-%dT%H%M%S'";
  today = "date '+%Y-%m-%d'";
  shuf = "${pkgs.coreutils}/bin/shuf";
  ztl = ''vim -c ":cd %:p:h" "$HOME/thearchive/writing-projects.otl"'';

  # average = "${pkgs.R}/bin/Rscript -e 'd<-scan(\"stdin\", quiet=TRUE)' -e 'summary(d)'";

  # XXX where is hb-view
  hb-feat =
    let
      cmd = pkgs.writeShellScriptBin "hb-feat" ''
        # from @thingskatedid
        # otfinfo --features <file.otf> to see features
        # Default color is black so the sed changes it to whitish (nord palette).
        ${pkgs.harfbuzz}/bin/hb-view --features="$2" -O svg "$1" "$3" | \
            grep -v '<rect' | \
            sed 's/<g style="fill:rgb(0%,0%,0%);fill-opacity:1;">/<g style="fill:#ECEFF4">/' | \
            ${pkgs.librsvg}/bin/rsvg-convert | \
            ${pkgs.imagemagick}/bin/convert -trim -resize '25%' - - | \
            cat
      '';
    in
    "${cmd}/bin/hb-feat";

  ssh = "${ssh-cmd}";
  cpptags = "${pkgs.universal-ctags}/bin/ctags --c++-kinds=+pf --c-kinds=+p --fields=+imaSft --extra=+q -Rnu";
  d = "${config.programs.git.package}/bin/git diff";
}
