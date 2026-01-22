" Basic Vim Configuration
" Extracted from NixVim configuration for use on remote servers
" Works with both Vim and Neovim

" ============================================================================
" GENERAL SETTINGS
" ============================================================================

" Enable syntax highlighting and filetype detection
syntax enable               " Enable syntax highlighting
filetype plugin indent on   " Enable filetype detection, plugins, and indent

colorscheme habamax

" Set leader key
let mapleader = " "

" Basic editor options
set number                  " Show line numbers
set relativenumber          " Show relative line numbers
set undofile                " Persistent undo
set expandtab               " Use spaces instead of tabs
set tabstop=4               " Tab width
set shiftwidth=4            " Indentation width
set scrolloff=12            " Keep cursor away from edges
set signcolumn=auto         " Show sign column only when needed
set conceallevel=1          " Conceal level for special chars
set pumheight=7             " Popup menu height
set foldlevel=99            " Start with folds open
set diffopt=vertical        " Vertical diff splits

" Reduce timeout for escape sequences (fixes delay when pressing Esc with Alt mappings)
set ttimeout                " Enable timeout on key codes
set ttimeoutlen=10          " Wait only 10ms for key code sequence (default is 100ms)
set timeoutlen=1000         " Wait 1000ms for mapped sequence (leader key, etc.)

" Cursor shape configuration
" Change cursor to vertical bar in insert mode, block in normal mode
if has('nvim')
  " Neovim uses guicursor (this is the default, but explicitly set for clarity)
  set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
else
  " Vim 8+ in terminal - use escape sequences
  " Works in most modern terminals (xterm, iTerm2, Alacritty, Kitty, etc.)
  let &t_SI = "\e[6 q"  " Vertical bar in insert mode
  let &t_EI = "\e[2 q"  " Block in normal mode
  let &t_SR = "\e[4 q"  " Underline in replace mode
endif

" ============================================================================
" NETRW - FILE EXPLORER (built-in alternative to Oil)
" ============================================================================
" Configure netrw to behave more like oil.nvim

" Netrw display settings
let g:netrw_banner = 0          " Hide banner (press I to toggle)
let g:netrw_liststyle = 3       " Tree view by default
let g:netrw_browse_split = 0    " Open files in current window
let g:netrw_winsize = 25        " 25% width for side splits
let g:netrw_altv = 1            " Open splits to the right
let g:netrw_preview = 1         " Preview splits vertically

" Netrw file hiding (similar to oil's hidden files)
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'  " Hide dotfiles by default (g. to toggle)

" Open netrw in current file's directory with '-' (like oil.nvim)
nnoremap - :Explore<CR>

" Custom netrw keybindings (set up after netrw buffer is created)
augroup NetrwCustomMaps
  autocmd!
  autocmd FileType netrw call s:setup_netrw_maps()
augroup END

function! s:setup_netrw_maps()
  " Custom mappings for oil-like behavior
  nmap <buffer> g. gh
  nmap <buffer> o %
  nmap <buffer> O d
  nmap <buffer> dd D
  
  " Keep useful defaults
  " <CR>  : Open file/directory
  " -     : Go up a directory
  " R     : Rename file
  " I     : Toggle banner
  " p     : Preview file
  " v     : Open file in vertical split
  " t     : Open file in new tab
endfunction

" ============================================================================
" TMUX NAVIGATOR - Seamless navigation between tmux panes and vim splits
" ============================================================================
" Source: https://github.com/christoomey/vim-tmux-navigator
" Modified to use Alt+h/j/k/l instead of Ctrl+h/j/k/l

if exists("g:loaded_tmux_navigator") || &cp || v:version < 700
  finish
endif
let g:loaded_tmux_navigator = 1

if !exists("g:tmux_navigator_save_on_switch")
  let g:tmux_navigator_save_on_switch = 0
endif

if !exists("g:tmux_navigator_disable_when_zoomed")
  let g:tmux_navigator_disable_when_zoomed = 0
endif

if !exists("g:tmux_navigator_preserve_zoom")
  let g:tmux_navigator_preserve_zoom = 0
endif

if !exists("g:tmux_navigator_no_wrap")
  let g:tmux_navigator_no_wrap = 0
endif

function! s:VimNavigate(direction)
  try
    execute 'wincmd ' . a:direction
  catch
    echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> executes, CTRL-C quits: wincmd k' | echohl None
  endtry
endfunction

if empty($TMUX)
  command! TmuxNavigateLeft call s:VimNavigate('h')
  command! TmuxNavigateDown call s:VimNavigate('j')
  command! TmuxNavigateUp call s:VimNavigate('k')
  command! TmuxNavigateRight call s:VimNavigate('l')
  command! TmuxNavigatePrevious call s:VimNavigate('p')
else

command! TmuxNavigateLeft call s:TmuxAwareNavigate('h')
command! TmuxNavigateDown call s:TmuxAwareNavigate('j')
command! TmuxNavigateUp call s:TmuxAwareNavigate('k')
command! TmuxNavigateRight call s:TmuxAwareNavigate('l')
command! TmuxNavigatePrevious call s:TmuxAwareNavigate('p')

let s:pane_position_from_direction = {'h': 'left', 'j': 'bottom', 'k': 'top', 'l': 'right'}

function! s:TmuxOrTmateExecutable()
  return (match($TMUX, 'tmate') != -1 ? 'tmate' : 'tmux')
endfunction

function! s:TmuxVimPaneIsZoomed()
  return s:TmuxCommand("display-message -p '#{window_zoomed_flag}'") == 1
endfunction

function! s:TmuxSocket()
  return split($TMUX, ',')[0]
endfunction

function! s:TmuxCommand(args)
  let cmd = s:TmuxOrTmateExecutable() . ' -S ' . s:TmuxSocket() . ' ' . a:args
  let l:x=&shellcmdflag
  let &shellcmdflag='-c'
  let retval=system(cmd)
  let &shellcmdflag=l:x
  return retval
endfunction

function! s:TmuxNavigatorProcessList()
  echo s:TmuxCommand("run-shell 'ps -o state= -o comm= -t ''''#{pane_tty}'''''")
endfunction
command! TmuxNavigatorProcessList call s:TmuxNavigatorProcessList()

let s:tmux_is_last_pane = 0
augroup tmux_navigator
  au!
  autocmd WinEnter * let s:tmux_is_last_pane = 0
augroup END

function! s:NeedsVitalityRedraw()
  return exists('g:loaded_vitality') && v:version < 704 && !has("patch481")
endfunction

function! s:ShouldForwardNavigationBackToTmux(tmux_last_pane, at_tab_page_edge)
  if g:tmux_navigator_disable_when_zoomed && s:TmuxVimPaneIsZoomed()
    return 0
  endif
  return a:tmux_last_pane || a:at_tab_page_edge
endfunction

function! s:TmuxAwareNavigate(direction)
  let nr = winnr()
  let tmux_last_pane = (a:direction == 'p' && s:tmux_is_last_pane)
  if !tmux_last_pane
    call s:VimNavigate(a:direction)
  endif
  let at_tab_page_edge = (nr == winnr())
  if s:ShouldForwardNavigationBackToTmux(tmux_last_pane, at_tab_page_edge)
    if g:tmux_navigator_save_on_switch == 1
      try
        update
      catch /^Vim\%((\a\+)\)\=:E32/
      endtry
    elseif g:tmux_navigator_save_on_switch == 2
      try
        wall
      catch /^Vim\%((\a\+)\)\=:E141/
      endtry
    endif
    let args = 'select-pane -t ' . shellescape($TMUX_PANE) . ' -' . tr(a:direction, 'phjkl', 'lLDUR')
    if g:tmux_navigator_preserve_zoom == 1
      let l:args .= ' -Z'
    endif
    if g:tmux_navigator_no_wrap == 1 && a:direction != 'p'
      let args = 'if -F "#{pane_at_' . s:pane_position_from_direction[a:direction] . '}" "" "' . args . '"'
    endif
    silent call s:TmuxCommand(args)
    if s:NeedsVitalityRedraw()
      redraw!
    endif
    let s:tmux_is_last_pane = 1
  else
    let s:tmux_is_last_pane = 0
  endif
endfunction

endif

" Custom keymaps using Alt+h/j/k/l (to avoid conflicts with other bindings)
" Note: Some terminals send <Esc>h instead of <M-h>, so we map both
nnoremap <silent> <M-h> :<C-U>TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :<C-U>TmuxNavigateDown<cr>
nnoremap <silent> <M-k> :<C-U>TmuxNavigateUp<cr>
nnoremap <silent> <M-l> :<C-U>TmuxNavigateRight<cr>
nnoremap <silent> <C-\> :<C-U>TmuxNavigatePrevious<cr>

" Alternative mappings for terminals that send Escape sequences
nnoremap <silent> <Esc>h :<C-U>TmuxNavigateLeft<cr>
nnoremap <silent> <Esc>j :<C-U>TmuxNavigateDown<cr>
nnoremap <silent> <Esc>k :<C-U>TmuxNavigateUp<cr>
nnoremap <silent> <Esc>l :<C-U>TmuxNavigateRight<cr>

inoremap <silent> <M-h> <Esc>:<C-U>TmuxNavigateLeft<cr>
inoremap <silent> <M-j> <Esc>:<C-U>TmuxNavigateDown<cr>
inoremap <silent> <M-k> <Esc>:<C-U>TmuxNavigateUp<cr>
inoremap <silent> <M-l> <Esc>:<C-U>TmuxNavigateRight<cr>
inoremap <silent> <C-\> <Esc>:<C-U>TmuxNavigatePrevious<cr>

if has('nvim') && !empty($TMUX)
  function! IsFZF()
    return &ft == 'fzf'
  endfunction
  tnoremap <expr> <silent> <M-h> IsFZF() ? "\<M-h>" : "\<C-w>:\<C-U>TmuxNavigateLeft\<cr>"
  tnoremap <expr> <silent> <M-j> IsFZF() ? "\<M-j>" : "\<C-w>:\<C-U>TmuxNavigateDown\<cr>"
  tnoremap <expr> <silent> <M-k> IsFZF() ? "\<M-k>" : "\<C-w>:\<C-U>TmuxNavigateUp\<cr>"
  tnoremap <expr> <silent> <M-l> IsFZF() ? "\<M-l>" : "\<C-w>:\<C-U>TmuxNavigateRight\<cr>"
  tnoremap <expr> <silent> <C-\> IsFZF() ? "\<C-\>" : "\<C-w>:\<C-U>TmuxNavigatePrevious\<cr>"
endif

" ============================================================================
" PAIR SNIPPETS - Type full pair to trigger
" ============================================================================
" Type () and get (|) with cursor in the middle, then <C-l> to jump out
" Similar to luasnip autosnippets but without the plugin

function! s:PairSnippet(open, close) abort
  " Move cursor back one position (we're after the close char)
  " Then move left past the open char, delete both chars, reinsert with cursor between
  return a:open . a:close . "\<Left>"
endfunction

" Snippet mappings for bracket pairs
inoremap <expr> () <SID>PairSnippet('(', ')')
inoremap <expr> [] <SID>PairSnippet('[', ']')
inoremap <expr> {} <SID>PairSnippet('{', '}')
inoremap <expr> <> <SID>PairSnippet('<', '>')
inoremap <expr> "" <SID>PairSnippet('"', '"')
inoremap <expr> '' <SID>PairSnippet("'", "'")

" Jump out of pairs with Ctrl-L (forward)
inoremap <C-l> <Esc>la

" ============================================================================
" COMMENTING - gc operator (like vim-commentary)
" ============================================================================
" Implements gc{motion} to toggle comments

function! s:CommentOperator(type) abort
  let start_line = line("'[")
  let end_line = line("']")
  call s:ToggleComment(start_line, end_line)
endfunction

function! s:ToggleComment(start_line, end_line) abort
  if !exists('&commentstring') || empty(&commentstring)
    echohl WarningMsg
    echo "No comment string defined for this filetype"
    echohl None
    return
  endif
  let cs = &commentstring
  let [l, r] = split(substitute(cs, '%s', '|', ''), '|', 1)
  let l = escape(l, '/*~')
  let r = escape(r, '/*~')
  let l = substitute(l, '^\s*', '', '')
  let r = substitute(r, '\s*$', '', '')
  let line = getline(a:start_line)
  let commented = line =~# '^\s*' . l
  if commented
    for lnum in range(a:start_line, a:end_line)
      let line = getline(lnum)
      if !empty(l)
        let line = substitute(line, '^\(\s*\)' . l . '\s\?', '\1', '')
      endif
      if !empty(r)
        let line = substitute(line, '\s\?' . r . '\s*$', '', '')
      endif
      call setline(lnum, line)
    endfor
  else
    " Find minimum indentation (ignoring empty lines)
    let min_indent = 9999
    for lnum in range(a:start_line, a:end_line)
      let line = getline(lnum)
      if !empty(line)
        let indent_len = len(matchstr(line, '^\s*'))
        if indent_len < min_indent
          let min_indent = indent_len
        endif
      endif
    endfor
    " Comment all lines with comment at the same column
    for lnum in range(a:start_line, a:end_line)
      let line = getline(lnum)
      if !empty(line)
        if min_indent > 0
          let indent = line[:min_indent-1]
          let rest = line[min_indent:]
        else
          let indent = ''
          let rest = line
        endif
        let line = indent . l . ' ' . rest
        if !empty(r)
          let line = line . ' ' . r
        endif
        call setline(lnum, line)
      endif
    endfor
  endif
endfunction

nnoremap <silent> gc :set operatorfunc=<SID>CommentOperator<CR>g@
vnoremap <silent> gc :<C-U>call <SID>ToggleComment(line("'<"), line("'>"))<CR>
nnoremap <silent> gcc :call <SID>ToggleComment(line('.'), line('.'))<CR>

" ============================================================================
" BASIC KEYMAPS
" ============================================================================

" General movements
nnoremap K a<cr><Esc>k$hl
inoremap <C-j> <cr><esc>O

" Toggle fold
nnoremap zt za

" Undo/Redo
nnoremap <M-U> <cmd>redo<cr>
inoremap <M-U> <cmd>redo<cr>

" Window resizing
nnoremap <M-K> <cmd>res +1<cr>
inoremap <M-K> <cmd>res +1<cr>
nnoremap <M-J> <cmd>res -1<cr>
inoremap <M-J> <cmd>res -1<cr>
nnoremap <M-H> <cmd>vertical:res -1<cr>
inoremap <M-H> <cmd>vertical:res -1<cr>
nnoremap <M-L> <cmd>vertical:res +1<cr>
inoremap <M-L> <cmd>vertical:res +1<cr>

" Location List navigation
nnoremap [1 <cmd>lprevious<cr>
nnoremap ]1 <cmd>lnext<cr>
nnoremap [L <cmd>lfirst<cr>
nnoremap ]L <cmd>llast<cr>

" Save without autocmds
nnoremap <C-M-s> <cmd>noautocmd write<cr><esc>
inoremap <C-M-s> <cmd>noautocmd write<cr><esc>

" ============================================================================
" AUTOCOMMANDS
" ============================================================================

" Set MDX files as markdown
augroup FiletypeDetect
  autocmd!
  autocmd BufRead,BufNewFile *.mdx setfiletype markdown
augroup END

" Terminal mode mappings (Neovim only - TermOpen doesn't exist in Vim)
if has('nvim')
  augroup TerminalMappings
    autocmd!
    autocmd TermOpen * nnoremap <buffer> <C-c> i<C-c>
  augroup END
endif

" Nix file settings
augroup NixSettings
  autocmd!
  autocmd BufEnter *.nix setlocal tabstop=2 shiftwidth=2 expandtab
augroup END

" Markdown settings
augroup MarkdownSettings
  autocmd!
  autocmd BufEnter *.md setlocal linebreak breakindent
augroup END

" C/C++ comment string
augroup CCommentString
  autocmd!
  autocmd FileType c,cpp setlocal commentstring=//\ %s
augroup END

" Remember cursor position
augroup RememberCursorPosition
  autocmd!
  autocmd BufReadPost * silent! normal! g`"zv
augroup END

" ============================================================================
" FZF.VIM - FUZZY FINDER (Optional but recommended)
" ============================================================================
" fzf.vim provides Telescope-like fuzzy finding for both Vim and Neovim
"
" INSTALLATION ON REMOTE SERVERS:
" 1. Install fzf binary:
"    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
"    ~/.fzf/install --bin
"
" 2. Install fzf.vim plugin:
"    mkdir -p ~/.vim/pack/plugins/start
"    git clone https://github.com/junegunn/fzf.vim ~/.vim/pack/plugins/start/fzf.vim
"    git clone https://github.com/junegunn/fzf ~/.vim/pack/plugins/start/fzf
"
" 3. Optional but recommended: Install ripgrep for better grep functionality
"    (available in most package managers as 'ripgrep' or 'rg')

" Set fzf runtime path if installed in home directory
if isdirectory(expand('~/.fzf'))
  set rtp+=~/.fzf
endif

" fzf.vim settings and keymaps
" Use autocommand to ensure fzf.vim is loaded before setting keymaps
augroup FzfConfig
  autocmd!
  autocmd VimEnter * call s:setup_fzf()
augroup END

function! s:setup_fzf()
  " Only proceed if fzf.vim is available
  if !exists(':Files')
    return
  endif
  
  " File finding
  nnoremap <leader>ff :Files<CR>
  nnoremap <leader>fo :History<CR>
  
  " Grep/search (uses ripgrep if available, falls back to grep)
  nnoremap <leader>fg :Rg<CR>
  
  " Buffer and help navigation
  nnoremap <M-\> :Buffers<CR>
  nnoremap <Esc>\ :Buffers<CR>
  inoremap <M-\> <Esc>:Buffers<CR>
  nnoremap <leader>fh :Helptags<CR>
  
  " Command history (closest to telescope resume)
  nnoremap <leader>fl :History:<CR>
  nnoremap <leader>fc :History:<CR>
  
  " fzf.vim layout settings
  " Use popup window (Vim 8.2+ and Neovim only)
  if has('nvim') || has('patch-8.2.191')
    let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.7 } }
  else
    let g:fzf_layout = { 'down': '40%' }
  endif
  
  " Customize fzf colors to match your color scheme
  let g:fzf_colors = {
    \ 'fg':      ['fg', 'Normal'],
    \ 'bg':      ['bg', 'Normal'],
    \ 'hl':      ['fg', 'Comment'],
    \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Label'],
    \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn', 'Comment'],
    \ 'hl+':     ['fg', 'Statement'],
    \ 'info':    ['fg', 'PreProc'],
    \ 'border':  ['fg', 'Ignore'],
    \ 'prompt':  ['fg', 'Conditional'],
    \ 'pointer': ['fg', 'Exception'],
    \ 'marker':  ['fg', 'Keyword'],
    \ 'spinner': ['fg', 'Label'],
    \ 'header':  ['fg', 'Comment']
    \ }
endfunction

" ============================================================================
" CONDITIONAL: LSP KEYMAPS (Neovim only)
" ============================================================================

if has('nvim')
  " LSP keymaps - only work in Neovim
  nnoremap gr <cmd>lua vim.lsp.buf.references()<cr>
  nnoremap <leader>r <cmd>lua vim.lsp.buf.rename()<cr>
  nnoremap <leader>lf <cmd>lua vim.lsp.buf.code_action({filter=function(a) return a.isPreferred end, apply=true})<cr>
  nnoremap <leader>lo <cmd>lua vim.lsp.buf.outgoing_calls()<cr>
  nnoremap <leader>li <cmd>lua vim.lsp.buf.incoming_calls()<cr>
  nnoremap <leader>lh <cmd>lua vim.lsp.buf.document_highlight()<cr>
  nnoremap <leader>lc <cmd>lua vim.lsp.buf.clear_references()<cr>
  nnoremap <leader>ld <cmd>lua vim.diagnostic.open_float()<cr>
  nnoremap <M-i> <cmd>lua vim.lsp.buf.hover()<cr>
  inoremap <M-i> <cmd>lua vim.lsp.buf.hover()<cr>

  " Enable LSP format on save for certain filetypes
  augroup LspFormatting
    autocmd!
    autocmd BufWritePre *.c,*.h,*.cpp,*.hpp,*.cc,*.hh,*.go,*.rs,*.json,*.typ,*.yaml,.clang-format,.clangd,.clang-tidy lua vim.lsp.buf.format()
  augroup END
endif

" ============================================================================
" EXTERNAL FORMATTER AUTOCOMMANDS
" ============================================================================
" Note: These require external tools to be installed

" Nix formatter (alejandra)
augroup NixFormatter
  autocmd!
  autocmd BufWritePost *.nix silent! !test -f alejandra.toml && alejandra '%'
augroup END

" Shell formatter (shfmt)
augroup ShellFormatter
  autocmd!
  autocmd BufWritePost *.sh silent! !test -f .editorconfig && shfmt -w '%'
augroup END

" CMake formatter (gersemi)
augroup CMakeFormatter
  autocmd!
  autocmd BufWritePost *.cmake,CMakeLists.txt silent! !test -f .gersemirc && gersemi -i '%'
augroup END

" Markdown formatter (mdformat)
augroup MarkdownFormatter
  autocmd!
  autocmd BufWritePost *.md silent! !test -f .mdformat.toml && mdformat '%'
augroup END

" Python formatter (ruff)
augroup PythonFormatter
  autocmd!
  autocmd BufWritePost *.py silent! !ruff format '%'
augroup END
