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

nnoremap <silent> <Plug>(tranquille_search_pattern) :TranquilleSearch pattern<CR>
nnoremap <silent> <Plug>(tranquille_search_word) :TranquilleSearch word<CR>

command! -nargs=1 TranquilleSearch
            \ let result = <SID>tranquille_search(<f-args>)
            \ | if result
                \ | set hls
                \ | endif

augroup tranquille_autocmds
    autocmd!
    autocmd CmdlineLeave * call s:delete_match()
augroup END

let s:tranquille_id = 67

fun! s:delete_match() abort
    try
        call matchdelete(s:tranquille_id)
    catch /\v(E802|E803)/
    endtry
endfun

fun! s:get_searchtxt(mode)
    augroup tranquille_textwatcher
        autocmd!
        autocmd CmdlineChanged * call s:update_hl(getcmdline())
    augroup END
    
    let l:search = ''
    
    if a:mode ==# 'pattern'
        if mode() ==# 'v' || mode() ==# 'V' || mode() ==# "\<C-v>"
            normal! "vy
            let l:search = '\V' . join(split(getreg('v'), '\n'), '\n')
        else
            let l:search = input('/')
        endif
    else
        let l:search = expand('<cword>')
    endif

    augroup tranquille_textwatcher
        autocmd!
    augroup END

    return l:search
endfun

fun! s:tranquille_search(mode)
    nohls

    let l:txt = s:get_searchtxt(a:mode)
    if l:txt !=# ''
        let @/ = l:txt
        redraw
        try
            if search(l:txt, 'n') == 0
                echohl ErrorMsg | echo 'E486: Pattern not found: '.l:txt | echohl None
            endif
        catch /.*/
            echohl ErrorMsg | echom 'Error with search term: '.l:txt | echohl None
        endtry
        return 1
    else
        return 0
    endif
endf

fun! s:update_hl(txt) abort
    call s:delete_match()

    let l:pattern = ''
    if !&magic
        let l:pattern .= '\M'
    endif
    if &ignorecase
        let l:pattern .= '\c'
    endif

    if a:txt !=# ''
        let l:pattern .= a:txt
        try
            call matchadd('Search', l:pattern, 0, s:tranquille_id)
        catch /.*/
        endtry
    endif
    redraw
endf

let &cpoptions = s:save_cpo
unlet s:save_cpo
