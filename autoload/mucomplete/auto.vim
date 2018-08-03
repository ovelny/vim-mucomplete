" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

fun! mucomplete#auto#enable_auto()
  augroup MUcompleteAuto
    autocmd!
    autocmd InsertCharPre * noautocmd call mucomplete#auto#insertcharpre()
    if get(g:, 'mucomplete#delayed_completion', 0)
      autocmd TextChangedI * noautocmd call mucomplete#auto#ic_autocomplete()
      autocmd  CursorHoldI * noautocmd call mucomplete#auto#autocomplete()
    else
      autocmd TextChangedI * noautocmd call mucomplete#auto#autocomplete()
    endif
  augroup END
endf

fun! mucomplete#auto#disable_auto()
  if exists('#MUcompleteAuto')
    autocmd! MUcompleteAuto
    augroup! MUcompleteAuto
  endif
endf

fun! mucomplete#auto#toggle_auto()
  if exists('#MUcompleteAuto')
    call mucomplete#auto#disable_auto()
    echomsg '[MUcomplete] Auto off'
  else
    call mucomplete#auto#enable_auto()
    echomsg '[MUcomplete] Auto on'
  endif
endf

if has('patch-8.0.0283')
  let s:insertcharpre = 0

  fun! mucomplete#auto#insertcharpre()
    let s:insertcharpre = !pumvisible() && (v:char =~# '\m\S')
  endf

  fun! mucomplete#auto#ic_autocomplete()
    if mode(1) ==# 'ic'  " In Insert completion mode, CursorHoldI in not invoked
      call mucomplete#autocomplete()
    endif
  endf

  fun! mucomplete#auto#autocomplete()
    if s:insertcharpre || mode(1) ==# 'ic'
      let s:insertcharpre = 0
      call mucomplete#autocomplete()
    endif
  endf

  finish
endif

" Code for Vim 8.0.0282 and older
if !(get(g:, 'mucomplete#no_popup_mappings', 0) || get(g:, 'mucomplete#no_mappings', 0) || get(g:, 'no_plugin_maps', 0))
  if !hasmapto('<plug>(MUcompletePopupCancel)', 'i')
    call mucomplete#map('imap', '<c-e>', '<plug>(MUcompletePopupCancel)')
  endif
  if !hasmapto('<plug>(MUcompletePopupAccept)', 'i')
    call mucomplete#map('imap', '<c-y>', '<plug>(MUcompletePopupAccept)')
  endif
  if !hasmapto('<plug>(MUcompleteCR)', 'i')
    call mucomplete#map('imap', '<cr>', '<plug>(MUcompleteCR)')
  endif
endif

let s:cancel_auto = 0
let s:insertcharpre = 0

fun! mucomplete#auto#popup_exit(keys)
  let s:cancel_auto = pumvisible()
  return a:keys
endf

fun! mucomplete#auto#insertcharpre()
  let s:insertcharpre = (v:char =~# '\m\S')
endf

fun! mucomplete#auto#ic_autocomplete()
  if s:cancel_auto
    let s:cancel_auto = 0
    return
  endif
  if !s:insertcharpre
    call mucomplete#autocomplete()
  endif
endf

fun! mucomplete#auto#autocomplete()
  if s:cancel_auto
    let [s:cancel_auto, s:insertcharpre] = [0,0]
    return
  endif
  if s:insertcharpre
    let s:insertcharpre = 0
    call mucomplete#autocomplete()
  endif
endf
