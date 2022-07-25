" XXX use FZF to find and insert filename <plug>(fzf-complete-path) or <plug>(fzf-complete-file)?

" Opens a zettel md file based on the current time, inserting a link to it
" from the current buffer.
function! ZettelNew(insert)
    let l:zettel_name = strftime("%Y%m%d%H%M")
    let l:zettel_fname = l:zettel_name . '.md'
    " inserts link to new zettel
    if a:insert
        call append(line('.'), '[](' . l:zettel_fname . ')')
    endif
    execute "split" l:zettel_fname
    " puts anchor into the new split buffer
    return append(0, readfile('ztl-template.md'))
endfunction

" Opens a zettel md file based on the current time, inserting a link in the
" new zettel back to the current buffer.
function! ZettelNewLinkBack()
    let l:zettel_src_fname = expand('%')
    call ZettelNew(0)
    " puts backlink into new split buffer
    return append(line('.'), '[](' . l:zettel_src_fname . ')')
endfunction

" Pops up a list of results linking to this zettel.
function! ZettelFindLinksTo()
    " Gets the anchor from the fimd line of the note.
    let l:name = expand('%:t')
    " let l:line = getline(1)
    " let l:prev_zettel_name = substitute(substitute(l:line, '^.. _', '', ''), ':$', '', '')
    " patterns: anchor_, `anchor`_, `link text <anchor>`_
    let search_term = l:name . '\)'
    let command = 'rg -m 1 --column --line-number --no-heading --color=always --smart-case '.shellescape(search_term)
    " don't use '-1' option because i want a list regardless
    call fzf#vim#grep(command, 1, fzf#vim#with_preview({'options': []}), 0)
endfunction

function! ZettelFiles()
    " let command = 'rg --column --line-number --no-heading --color=always --smart-case '.shellescape('^|#ztl')
    let command = 'ztl_filter'
    call fzf#vim#grep(command, 1, fzf#vim#with_preview({'options': ['-1']}), 0)
endfunction


" Opens in a split the link source from a file in the current directory (in
" FZF window if there are multiple).
function! ZettelFzfRgLinkSource()
    let word_under_cursor = expand("<cword>")
    " remove underscore at end of word and put one at beginning
    let search_term = '_' . substitute(word_under_cursor, '[_]$', '', '')
    let command = 'rg -m 1 --column --line-number --no-heading --color=always --smart-case '.shellescape(search_term)
    execute "split"
    call fzf#vim#grep(command, 1, fzf#vim#with_preview({'options': ['-1']}), 0)
endfunction
