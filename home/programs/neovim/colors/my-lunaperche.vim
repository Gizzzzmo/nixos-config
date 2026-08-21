" my-lunaperche: lunaperche base + personal overrides (dark only)

runtime! colors/lunaperche.vim

let g:colors_name = 'my-lunaperche'

if &background == 'dark'
  hi IblIdent guifg=#080808
  hi WinSeparator guifg=#444444
  hi Comment guifg=#ffc244
  hi LineNr guifg=#ccddff
  hi LineNrAbove guifg=#7e7e7e
  hi LineNrBelow guifg=#7e7e7e
  hi Normal guibg=#0c1016

  hi @variable.member guifg=#ee8866
  hi @lsp.type.property guifg=#ffbb99
  hi link @property @lsp.type.property
  hi link @variable.member @lsp.type.property
  hi Type gui=bold guifg=#5fd75f
  hi link @keyword.type Statement
  hi @function.call guifg=#6699dd
  hi @variable.parameter guifg=#cccc55
  hi link @lsp.type.parameter @variable.parameter
  hi link typstHashtagIdentifier @function.call
  hi link @lsp.type.function.typst @function.call

  hi @markup.link.label.markdown_inline guifg=#f584ff gui=underline
  hi @markup.link.url.markdown_inline guifg=#f584ff gui=underline
endif
