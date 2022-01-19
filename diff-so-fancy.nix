# This overlay is for someone's pending merge request. It fixes the color
# handling. It's enough of a fix so that it works with my dracula color
# settings.
result: prev: {
  diff-so-fancy = prev.diff-so-fancy.overrideAttrs (attrs: with attrs; {
    version = "HEAD";
    src = result.fetchFromGitHub {
      owner = "rwe";
      repo = "diff-so-fancy";
      rev = "cb73fa04e76e3c265b42040be307e3e7541d0b2d";
      sha256 = "xdc+hg8xpA1QsOu3WDIbk5H2e/1GDQMGD76Kvmiw68A=";
    };
  });
}
