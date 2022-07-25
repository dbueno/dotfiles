set nonumber

map <buffer> <LocalLeader>zz :ZettelFiles<CR>
map <buffer> <LocalLeader>zg :ZettelFollowLink<CR>
map <buffer> <LocalLeader>zl :ZettelFindBackLinks<CR>
map <buffer> <LocalLeader>zn :ZettelNew<CR>
map <buffer> <LocalLeader>zN :ZettelNewLinkBack<CR>
" insert mode: pop up list of zettel tags
inoremap <expr> <c-x><c-t> fzf#vim#complete('ztl_tagcloud')
