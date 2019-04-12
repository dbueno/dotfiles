" Early settings {{{
set nocompatible
let mapleader = ";"
let maplocalleader = mapleader

" enable mouse
set mouse=a

" Prevent jedi from loading (may be installed system-wide)
let g:loaded_jedi = 1


" Ignore files when completing
set suffixes+=.class,.pyc,.pyo
set suffixes+=.lo,.swo
" Don't ignore headers when completing
set suffixes-=.h

" use blowfish2 if i ask for crypto
set cm=blowfish2

" }}}

" defines a command like mkdir -p
command MkDirs call mkdir(expand('%:h'), 'p')

" my simple statusline, airline was a steaming pile
set statusline=%q%t\ @\ %P\ [ft=%Y%M%R%W%H]\ pos\ %l:%c\ %=%<%{expand('%:~:.:h')}

" Airline configuration {{{
"if !exists('g:airline_symbols')
"    let g:airline_symbols = {}
"endif
"
"let g:airline_left_sep="▓▒░"
"let g:airline_right_sep="░▒▓"
"
"let g:airline_inactive_collapse=0
"let g:airline#extensions#tabline#enabled=1
"let g:airline#extensions#tabline#show_buffers=0
"let g:airline_theme='zenburn'
"let g:airline_theme='dracula'
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

" Syntastic options from their website {{{
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0
"let g:syntastic_ocaml_checkers = ["merlin"]
" }}}
"
" FZF config {{{
if executable('fzf')
  set rtp+=/usr/local/opt/fzf
  set rtp+=bundle/junegunn-fzf.vim

  let $FZF_DEFAULT_COMMAND = 'ag -g "" --ignore "*.o" --ignore "*.so" --ignore "*.tmp" --ignore "*.class" --ignore-dir ".git"'
endif
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
let s:opamshare = substitute(system('opam config var share'),'\n$','','''')
let g:pathogen_disabled = [s:opamshare.'/ocp-index/vim', 'bling-vim-airline', 'vim-airline-vim-airline-themes', 'scrooloose-syntastic', 'scrooloose-nerdtree', 'ctrlp.vim']
runtime bundle/tpope-vim-pathogen/autoload/pathogen.vim
exec pathogen#infect('bundle/{}',s:opamshare.'/{}/vim')
syntax on
filetype plugin indent on
" }}}

function s:camel_word(dir)
    call search('\U\zs\u\|\<', a:dir)
endfunction

" Global mappings {{{
nnoremap <Leader>T :TagbarToggle<CR>

" functions from junegunn-fzf.vim
nnoremap <Leader>u :Buffers<CR>
nnoremap <Leader>f :<C-u>GitFiles<CR>
nnoremap <Leader>F :<C-u>Files<CR>
nnoremap <Leader>t :Tags<CR>

nnoremap <Leader>d :bd<CR>

" Insert current date into buffer. Used for note taking.
nnoremap <Leader>it "=strftime("%c")<CR>p

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
" }}}


" Basic configuration {{{
let g:jellybeans_overrides = {
          \ 'background': { 'guibg': '191919' },
          \ }
""if has('gui')
"colorscheme zenburn
colorscheme dracula
" extra space between lines because this helps with smaller font sizes
"set linespace=0
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

" disables mappings from default ocaml ftplugin
let g:no_ocaml_maps = 1

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

runtime vimrc_local



