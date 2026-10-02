set nonumber
set fdl=3

map <buffer> <LocalLeader>zz :ZettelFiles<CR>
map <buffer> <LocalLeader>zg :ZettelFollowLink<CR>
map <buffer> <LocalLeader>zl :ZettelFindBackLinks<CR>
map <buffer> <LocalLeader>zn :ZettelNew<CR>
map <buffer> <LocalLeader>zN :ZettelNewLinkBack<CR>
" insert mode: pop up list of zettel tags
inoremap <expr> <c-x><c-t> fzf#vim#complete('ztl_tagcloud')

" these settings enable gq with bulleted lists
let g:vim_markdown_auto_insert_bullets=0
let g:vim_markdown_new_list_item_indent=0
setlocal formatlistpat=^\\s*\\d\\+[.\)]\\s\\+\\\|^\\s*[*+~-]\\s\\+\\\|^\\(\\\|[*#]\\)\\[^[^\\]]\\+\\]:\\s
setlocal comments=n:>
setlocal formatoptions+=cn
