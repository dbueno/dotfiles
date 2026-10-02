$pdflatex = "pdflatex -synctex=1 -halt-on-error %O %S";
$sleep_time = 2;
@generated_exts = (@generated_exts, 'synctex.gz');
$pdf_previewer = 'open -a Skim %S';
$pdf_update_method = 4;
$pdf_update_command = <<'END_OF_SCRIPT';
/usr/bin/osascript << EOF
  set theFile to POSIX file %S as alias
  tell application "Skim"
  set theDocs to get documents whose path is (get POSIX path of theFile)
  if (count of theDocs) > 0 then revert theDocs
  open theFile
  end tell
EOF
END_OF_SCRIPT
