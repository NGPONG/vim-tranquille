" Vim plugin for searching without moving the cursor
" Last Change:	2018 Nov 2
" Maintainer:	Adam P. Regasz-Rethy  <rethy.spud@gmail.com>
" License:	This file is placed in the public domain.

if exists('g:loaded_tranquille') || !has('autocmd')
  finish
endif
let g:loaded_tranquille = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

if mapcheck('g/') ==# '' && !hasmapto('<Plug>(tranquille_search)')
  nmap <unique> g/ <Plug>(tranquille_search)
endif

nnoremap <silent> <Plug>(tranquille_search) :TranquilleSearch<Return>

command! -nargs=0 TranquilleSearch call <SID>tranquille_search() | set hls

augroup tranquille_autocmds
  autocmd!
  autocmd CmdlineLeave * try | call matchdelete(s:tranquille_id) | catch /\v(E802|E803)/ | endtry
augroup END

let s:tranquille_id = 67

fun! s:tranquille_search() abort
  nohls
  augroup tranquille_textwatcher
    autocmd!
    autocmd CmdlineChanged * call s:update_hl()
  augroup END
  let search = input({'prompt': '/'})
  augroup tranquille_textwatcher
    autocmd!
  augroup END
  let @/ = search
endf

fun! s:update_hl() abort
  try
    call matchdelete(s:tranquille_id)
  catch /\v(E802|E803)/
  endtry

  let l:pattern = ''
  if !&magic
    let l:pattern .= '\M'
  endif
  if &ignorecase
    let l:pattern .= '\c'
  endif
  let l:cmdline = getcmdline()
  if l:cmdline !=# ''
    let l:pattern .= l:cmdline
    call matchadd('Search', l:pattern, 0, s:tranquille_id)
  endif
  redraw
endf

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim:set et foldlevel=1 sw=2 foldmethod=expr foldexpr=getline(v\:lnum)=~'^\"\ Section\:'?'>1'\:getline(v\:lnum)=~#'^fu'?'a1'\:getline(v\:lnum)=~#'^endf'?'s1'\:'=':
