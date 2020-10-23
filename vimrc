" Early settings {{{
set nocompatible
let mapleader = ";"
let maplocalleader = mapleader
set modeline modelines=5

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

" defines a command, MkDirs, that will make all the directories necessary so
" that the path to current buffer-file exists
command MkDirs call mkdir(expand('%:h'), 'p')

command CtagsCpp !ctags --c++-kinds=+p --c-kinds=+p --fields=+iaS --extra=+q -Rnu .

command HighlightCurrentLine :call matchadd('Search', '\%'.line('.').'l')<CR>
command ClearHighlightCurrentLine :call clearmatches()<CR>

" my simple statusline, airline was a steaming pile
set statusline=%q%t\ @\ %P\ [ft=%Y%M%R%W%H]\ char:0x%B\ pos\ %l:%c\ %=%<%{expand('%:~:.:h')}

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
  set grepprg=ag\ --vimgrep\ $*
  set grepformat=%f:%l:%c:%m
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
  let thepath=fnamemodify(exepath('fzf'), ':h:h')
  execute "set rtp+=" . thepath
  set rtp+=/usr/local/opt/fzf
  set rtp+=bundle/junegunn-fzf.vim

  let $FZF_DEFAULT_COMMAND = 'ag -g "" --ignore "*.o" --ignore "*.so" --ignore "*.tmp" --ignore "*.class" --ignore-dir ".git"'
  let g:fzf_preview_window = ''
 
  " :BD function to use fzf to delete buffers
  function! s:list_buffers()
      redir => list
      silent ls
      redir END
      return split(list, "\n")
  endfunction

  function! s:delete_buffers(lines)
      execute 'bwipeout' join(map(a:lines, {_, line -> split(line)[0]}))
  endfunction

  command! BD call fzf#run(fzf#wrap({
              \ 'source': s:list_buffers(),
              \ 'sink*': { lines -> s:delete_buffers(lines) },
              \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
              \ }))
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
let g:pathogen_disabled = ['bling-vim-airline', 'vim-airline-vim-airline-themes', 'scrooloose-syntastic', 'scrooloose-nerdtree', 'ctrlp.vim']
" s:opamshare.'/ocp-index/vim',
runtime bundle/tpope-vim-pathogen/autoload/pathogen.vim
exec pathogen#infect('bundle/{}')
"exec pathogen#infect('bundle/{}',s:opamshare.'/{}/vim')
filetype plugin indent on
syntax on
" }}}

function s:camel_word(dir)
    call search('\U\zs\u\|\<', a:dir)
endfunction

" Global mappings {{{
nnoremap <Leader>T :TagbarToggle<CR>

" functions from junegunn-fzf.vim
" each brings up fuzzy completion list
" <Leader>u - list of buffers
nnoremap <Leader>u :Buffers<CR>
" <Leader>f - list of files under the current Git repo
nnoremap <Leader>f :<C-u>GitFiles<CR>
" <Leader>f - list of files under the current directory
nnoremap <Leader>F :<C-u>Files<CR>
" <Leader>f - list of tags
nnoremap <Leader>t :Tags<CR>

" <Leader>d deletes the current buffer
nnoremap <Leader>d :bd<CR>

" Insert current date into buffer. Used for note taking.
nnoremap <Leader>it "=strftime("%c")<CR>p

" select some text, then type // and it will search for the literal text
vnoremap // y/\V<C-R>"<CR>

" highlight matches in search
" set hlsearch
" <Leader>h will turn off highlights
nnoremap <Leader>h :set hls!<CR>
"nnoremap <Space> zz

" close the current window
nnoremap <Leader>c <C-w>c
" make the current window the only window
nnoremap <Leader>o <C-w>o
" easier movement in splits
nnoremap <C-h> <C-w><C-h>
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>

" C-w ] will open tag in a split
" C-w g } will let you select tag for preview
"nnoremap <C-n> :cnext<CR>
"nnoremap <C-p> :cprevious<CR>
"nnoremap <Leader>n :tnext<CR>
"nnoremap <Leader>p :tprev<CR>

nnoremap <silent> _ :aboveleft sp<CR>:exe "normal \<Plug>VinegarUp"<CR>
nnoremap <silent> <Bar> :aboveleft vsp<CR>:exe "normal \<Plug>VinegarUp"<CR>
" }}}


" Basic configuration {{{
" let g:jellybeans_overrides = {
"           \ 'background': { 'guibg': '191919' },
"           \ }
" kthxbye
" let g:dracula_italic = 0
" colorscheme dracula

" set background=light
" colorscheme cosmic_latte

" too muted for now
" colorscheme nord

let g:gruvbox_contrast_dark = 'medium'
autocmd vimenter * colorscheme gruvbox

" default for .tex files is latex
let g:tex_flavor = "latex"

" R mode customizations
let R_assign = 2

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

" always include status line
set laststatus=2 

" keep buffers around when they are not visible
set hidden

" don't remember options in seccions
set sessionoptions-=options

" don't let search open a fold
" set fdo-=search

" i have cores for a reason
set makeprg=make\ -j8

" disables mappings from default ocaml ftplugin
let g:no_ocaml_maps = 1

if executable('grin')
    set grepprg=grin\ -nH\ --emacs
endif

set tags=./tags,./TAGS,tags,TAGS,./.tags,./.TAGS,.tags,.TAGS,../../tags,../tags

" set this to add to places where vim searches #includes
"set path+=

" }}}

" vimtex config {{{
let g:vimtex_disable_recursive_main_file_detection = 1
" }}}

let g:syntastic_mode_map = { 'mode': 'passive' }

" turn off markify automatically; use :MarkifyToggle or :Markify[Clear]
" let g:markify_autocmd = 0

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

" z3 specific style settings for c++
autocmd BufRead
     \ ~/work/inprogress/z3/*/{src,tools,tests}/*.{cc,cpp,h,inc}
     \ setlocal makeprg=make\ -C\ .vimbuild\ -j24\ all sw=4 cino=:0,l1,g0,t0,(0,w1,W4

runtime vimrc_local


