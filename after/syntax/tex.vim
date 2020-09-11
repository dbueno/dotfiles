" highlight lstlisting and lstinline as verbatim
syn region texZone start="\\begin{lstlisting}" end="\\end{lstlisting}\|%stopzone\>"
syn region texZone start="\\lstinputlisting" end="{\s*[a-zA-Z/.0-9_^]\+\s*}"
"syn match texInputFile "\\lstinline\s*\(\[.*\]\)\={.\{-}}" contains=texStatement,texInputCurlies,texInputFileOpt
syn region texZone start="\\lstinline\*\=\z([^\ta-zA-Z]\)"     end="\z1\|%stopzone\>"

