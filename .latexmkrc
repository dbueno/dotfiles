$pdflatex = "pdflatex -synctex=1 -halt-on-error %O %S";
$pdf_previewer = 'open -a Skim';
@generated_exts = (@generated_exts, 'synctex.gz');
