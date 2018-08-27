" Early settings {{{
let g:auto_addons = ['The_NERD_tree', 'Solarized','neocomplcache','vim-addon-goto-thing-at-cursor', 'fugitive', 'vim-addon-scala']
runtime initialize_vam.vim

set nocompatible
let mapleader = ";"
let maplocalleader = mapleader

" Prevent jedi from loading (may be installed system-wide)
let g:loaded_jedi = 1


" Ignore files when completing
set suffixes+=.class,.pyc,.pyo
set suffixes+=.lo,.swo
" Don't ignore headers when completing
set suffixes-=.h

set cm=blowfish2

" }}}

command MkDirs call mkdir(expand('%:h'), 'p')

" Airline configuration {{{
"if !exists('g:airline_symbols')
"    let g:airline_symbols = {}
"endif
"
"let g:airline_left_sep="▓▒░"
"let g:airline_right_sep="░▒▓"
"
"let g:airline_inactive_collapse=0
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#show_buffers=0
"let g:airline_theme='zenburn'
let g:airline_theme='dracula'
" }}}

" CtrlP Configuration {{{
let g:ctrlp_custom_ignore = {
    \ 'file':   '\v\.(class|o|so|py[co])$',
    \ 'dir':    '\v/\.(git|hg|svn)$',
    \ }
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
if executable('ag')
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif
" }}}

let g:NERDTreeHijackNetrw=0

" Syntastic options from their website {{{
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
" }}}

" GUI options {{{
if has('gui')
    set guioptions-=m " no menu
    set guioptions-=T " no toolbar
    set guioptions-=r " no scrollbars
    set guioptions-=R
    set guioptions-=l
    set guioptions-=L
    set guioptions-=b
    "set guifont=Iosevka\ Term\ Medium:h11
    set guifont=SF\ Mono\ Regular:h13
endif
" }}}

" Pathogen invocation {{{
let g:pathogen_disabled = ['valloric-youcompleteme', 'kien-ctrlp']
runtime bundle/tpope-vim-pathogen/autoload/pathogen.vim
exec pathogen#infect()
syntax on
filetype plugin indent on
" }}}

function s:camel_word(dir)
    call search('\U\zs\u\|\<', a:dir)
endfunction

" Global mappings {{{

nnoremap <Leader>n :<C-u>NERDTreeToggle<CR>
" nnoremap <Leader>N :<C-u>NERDTreeFind<CR>

nnoremap <Leader>T :TagbarToggle<CR>

nnoremap <Leader>u :<C-u>CtrlPBuffer<CR>
nnoremap <Leader>f :<C-u>CtrlP<CR>
nnoremap <Leader><C-f> :<C-u>CtrlP %:h<CR>
nnoremap <Leader>F :<C-u>CtrlPMixed<CR>
nnoremap <Leader>t :<C-u>CtrlPTag<CR>
nnoremap <Leader>r :<C-u>CtrlPBufTag<CR>
nnoremap <Leader>d :bd<CR>

" Insert current date into buffer. Used for note taking.
nnoremap <Leader>it "=strftime("%c")<CR>p
" Insert comment separator
nnoremap <Leader>is o//*-------------------------------------------------------------------------------*<CR>

" select some text, then type // and it will search for the literal
vnoremap // y/\V<C-R>"<CR>

nnoremap <Leader>h :nohls<CR>
"nnoremap <Space> zz

nnoremap <Leader>c <C-w>c
nnoremap <Leader>o <C-w>o

nnoremap <C-n> :cnext<CR>
nnoremap <C-p> :cprevious<CR>

nnoremap <silent> _ :aboveleft sp<CR>:exe "normal \<Plug>VinegarUp"<CR>
nnoremap <silent> <Bar> :rightbelow vsp<CR>:exe "normal \<Plug>VinegarUp"<CR>

noremap <F1> <Esc>
inoremap <F1> <Esc>



" From: https://github.com/kien/ctrlp.vim/issues/280
let g:ctrlp_buffer_func = { 'enter': 'MyCtrlPMappings' }

func! MyCtrlPMappings()
    nnoremap <buffer> <silent> <c-@> :call <sid>DeleteBuffer()<cr>
endfunc

func! s:DeleteBuffer()
    let line = getline('.')
    let bufid = line =~ '\[\d\+\*No Name\]$' ? str2nr(matchstr(line, '\d\+'))
        \ : fnamemodify(line[2:], ':p')
    exec "bd" bufid
    exec "norm \<F5>"
endfunc
" }}}


" Basic configuration {{{
let g:jellybeans_overrides = {
          \ 'background': { 'guibg': '191919' },
          \ }
""if has('gui')
"colorscheme zenburn
colorscheme dracula
" extra space between lines because this helps with smaller font sizes
set linespace=1
"deus "spacegray
""else
  "colors jellybeans
  "hi CursorLine guibg=#404040
  "hi CursorColumn guibg=#404040
"endif
set ruler
" expand tabs, default shiftwidth is 4
set et sts=4 sw=4
" keep 4 lines above and below the cursor
set so=4

set showcmd
" ignore case except mixed lower and uppercase in patterns
set ignorecase smartcase

" unexplainable but helpful completion settings
set wildmenu wildmode=list,list:longest

" highlight matches in search
set hlsearch

" always include status line
set laststatus=2 

" keep buffers around when they are not visible
set hidden

" don't remember options in seccions
set sessionoptions-=options

" don't let search open a fold (very annoying)
set fdo-=search

" i have cores for a reason
set makeprg=make\ -j8

if executable('grin')
    set grepprg=grin\ -nH\ --emacs
endif

set tags=../../tags,../tags,./tags,./TAGS,tags,TAGS,./.tags,./.TAGS,.tags,.TAGS

" set this to add to places where vim searches #includes
"set path+=

" }}}

let g:syntastic_mode_map = { 'mode': 'passive' }

" Python indenting {{{
function PythonParenIndent(lnum)
    call cursor(a:lnum, 1)
    let [pline, pcol] = searchpairpos('(\|{\|\[', '', ')\|}\|\]', 'bW',
                        \ "synIDattr(synID(line('.'), col('.'), 1), 'name')" .
                        \ " =~ '\\(Comment\\|String\\)$'",
                        \ max([0,a:lnum-50]))
    let plinecontent = getline(pline)
    let lineend = match(plinecontent, '\s*$')
    if pcol >= lineend
        return &sw
    else
        return pcol-indent(pline)
    endif
endfunction

let g:pyindent_nested_paren='PythonParenIndent(a:lnum)'
let g:pyindent_open_paren='PythonParenIndent(a:lnum)'
" }}}


" XXX is this necessary?
runtime ftplugin/man.vim

" vim: set foldmethod=marker :
