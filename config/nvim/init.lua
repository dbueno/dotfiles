" LSP and Treesitter config
lua << END
require'nvim-treesitter.configs'.setup {
ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
ignore_install = { }, -- List of parsers to ignore installing
highlight = {
  enable = true,              -- false will disable the whole extension
  disable = { "rust" },  -- list of language that will be disabled
  -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
  -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
  -- Using this option may slow down your editor, and you may see some duplicate highlights.
  -- Instead of true it can also be a list of languages
  additional_vim_regex_highlighting = false,
},
}

local cmp = require'cmp'

local kind_icons = {
Text = "",
Method = "",
Function = "",
Constructor = "",
Field = "",
Variable = "",
Class = "ﴯ",
Interface = "",
Module = "",
Property = "ﰠ",
Unit = "",
Value = "",
Enum = "",
Keyword = "",
Snippet = "",
Color = "",
File = "",
Reference = "",
Folder = "",
EnumMember = "",
Constant = "",
Struct = "",
Event = "",
Operator = "",
TypeParameter = ""
}

cmp.setup({
formatting = {
  format = function(entry, vim_item)
    -- Kind icons
    vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
    -- Source
    vim_item.menu = ({
      buffer = "[Buffer]",
      nvim_lsp = "[LSP]",
      luasnip = "[LuaSnip]",
      nvim_lua = "[Lua]",
      latex_symbols = "[LaTeX]",
    })[entry.source.name]
    return vim_item
  end
},
snippet = {
  expand = function(args)
  vim.fn["vsnip#anonymous"](args.body)
end,
},
mapping = {
    ["<Tab>"] = cmp.mapping(function(fallback)
        -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
        if cmp.visible() then
          local entry = cmp.get_selected_entry()
          if not entry then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          end
          cmp.confirm()
        else
          fallback()
        end
      end, {"i","s","c",}),
},
sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' },
    { name = 'cmdline'},
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

local lspconfig = require'lspconfig'

-- Setup lspconfig.
local on_attach = function(client, bufnr)
local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

--Enable completion triggered by <c-x><c-o>
buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

-- Mappings.
local opts = { noremap=true, silent=true }

-- See `:help vim.lsp.*` for documentation on any of the below functions
buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
--buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
buf_set_keymap('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

-- Get signatures (and _only_ signatures) when in argument lists.
require "lsp_signature".on_attach({
  doc_lines = 0,
  handler_opts = {
    border = "none"
  },
})
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())


local clangd_exe = '${pkgs.clang-tools}/bin/clangd'

-- enable C/C++ support
lspconfig.clangd.setup {
on_attach = on_attach,
cmd = {
  clangd_exe,
  "--background-index",
  "--suggest-missing-includes",
  },
capabilities = capabilities,

}

-- enable OCaml support
lspconfig.ocamllsp.setup {
on_attach = on_attach,
capabilities = capabilities,
}

-- enable Rust support
lspconfig.rust_analyzer.setup {
on_attach = on_attach,
flags = {
  debounce_text_changes = 150,
  },
settings = {
  ["rust-analyzer"] = {
    cargo = {
      allFeatures = true,
      },
    completion = {
      postfix = {
      enable = false,
      },
    },
  },
},
capabilities = capabilities,
}

-- enable Go support
lspconfig.gopls.setup {
on_attach = on_attach,
capabilities = capabilities,
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
vim.lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = true,
  signs = true,
  update_in_insert = true,
}
)

END

" Enable type inlay hints
autocmd CursorHold,CursorHoldI *.rs :lua require'lsp_extensions'.inlay_hints{ only_current_line = true }

" Plugin settings
let g:secure_modelines_allowed_items = [
              \ "textwidth",   "tw",
              \ "softtabstop", "sts",
              \ "tabstop",     "ts",
              \ "shiftwidth",  "sw",
              \ "expandtab",   "et",   "noexpandtab", "noet",
              \ "filetype",    "ft",
              \ "foldmethod",  "fdm",
              \ "readonly",    "ro",   "noreadonly", "noro",
              \ "rightleft",   "rl",   "norightleft", "norl",
              \ ]

" Lightline
let g:lightline = {
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'readonly', 'filename', 'modified' ] ],
    \   'right': [ [ 'lineinfo' ],
    \              [ 'percent' ],
    \              [ 'fileencoding', 'filetype' ] ],
    \ },
    \ 'component_function': {
    \   'filename': 'LightlineFilename'
    \ },
    \ }
function! LightlineFilename()
return expand('%:t') !=# ''' ? @% : '[No Name]'
endfunction

" enable syntax highlighting
syntax enable

" enable auto indentation
filetype plugin indent on

" enable a permanent gutter so that things don't move when there's an error
set signcolumn=yes

" show lines above and below cursor
set scrolloff=5

" indent two characters
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" save undo permanently
set undodir=~/.vimdid
set undofile

" configure file ignoring
set wildignore+=*/_build/*,*.o,*.swp,*.a,*.cmi,*.cmo,*.cmx,*.cmt,*.annot,*.dylib,*.cmxa

" incrementally search while typing
set incsearch

" bemove toolbar
set guioptions-=T

" kill beeps
set vb t_vb=

" backspace over newlines
set backspace=2

" disable folds
set nofoldenable

" don't redraw screen in the middle of scripts
set lazyredraw

" enable the status line
set laststatus=2

" show relative line numbers but also current line
set relativenumber
set number

" No whitespace in vimdiff
set diffopt+=iwhite

" Make diffing better: https://vimways.org/2018/the-power-of-diff/
set diffopt+=algorithm:patience
set diffopt+=indent-heuristic

" Enable mouse usage (all modes) in terminals
set mouse=a

" don't give |ins-completion-menu| messages.
set shortmess+=c


" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:20,%,n~/.nviminfo

" Jump to last edit position on opening file
if has("autocmd")
" https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Find files using Telescope command-line sugar.
nnoremap <C-p> <cmd>Telescope find_files<cr>
"nnoremap <leader>fg <cmd>Telescope live_grep<cr>
"nnoremap <leader>fb <cmd>Telescope buffers<cr>
"nnoremap <leader>fh <cmd>Telescope help_tags<cr>

set spell spelllang=en_us


