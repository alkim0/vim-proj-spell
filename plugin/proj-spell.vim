" proj-spell.vim - Plugin to enable project-specific spelling words
" Maintainer: Albert Kim
" Version: 0.1

if exists('g:proj_spell_loaded') || &compatible
  finish
endif

let g:proj_spell_loaded = 1
"
if !exists('g:proj_spell_dir')
  let g:proj_spell_dir = '.spell'
endif

if !exists('g:proj_spell_default_add_file')
  let g:proj_spell_default_add_file = 'words'
endif

let s:plugin_root = expand('<sfile>:p:h:h')
let s:python_root = s:plugin_root . '/python'

python3 << EOF
import os.path, sys, vim
#sys.path.insert(0, os.path.join(vim.eval('s:third_party_root')))
sys.path.insert(0, os.path.join(vim.eval('s:python_root')))
import proj_spell
EOF

function! s:add_new_word_global(word)
  let l:global_spellfile = expand('~/.vim/spell/en.utf-8.add')
  if s:orig_spellfile != ''
    let l:global_spellfile = s:orig_spellfile
  endif

  silent call writefile([a:word], l:global_spellfile, "a")
  silent! execute 'mkspell! ' . l:global_spellfile
  echo a:word . ' added to ' . l:global_spellfile
endfunc

function! s:add_new_word_proj(word)
  let l:current_dir = expand("%:p:h")
  let l:spell_dir = py3eval('proj_spell.lookup_spell_dir(vim.eval("l:current_dir"), vim.eval("g:proj_spell_dir"))')

  let l:proj_spellfile = ''
  if l:spell_dir == ''
    let b:tmp_spellfile = system('mktemp -p /tmp/vim-proj-spell')
    let l:proj_spellfile = b:tmp_spellfile
  else
    let l:proj_spellfile = l:spell_dir . '/' . g:proj_spell_default_add_file
  endif

  silent call writefile([a:word], l:proj_spellfile, "a")
  call s:proj_spell_hook()
  echo a:word . ' added to ' . l:proj_spellfile
endfunc


function! s:proj_spell_hook()
  if !exists('s:orig_spellfile')
    let s:orig_spellfile = &spellfile
  endif

  let l:current_dir = expand("%:p:h")
  let l:new_spellfile = py3eval('proj_spell.compile_proj_spell(vim.eval("l:current_dir"), vim.eval("g:proj_spell_dir"))')

  if l:new_spellfile != ''
    silent! execute 'mkspell! ' . l:new_spellfile
  endif

  let b:combined_spellfile = s:combine(s:orig_spellfile, l:new_spellfile)
  if exists('b:tmp_spellfile')
    let b:combined_spellfile = s:combine(b:combined_spellfile, b:tmp_spellfile)
  endif
  let &spellfile = b:combined_spellfile
endfunc

function! s:reload_proj_spell()
  if !exists('b:combined_spellfile') || &spellfile != b:combined_spellfile
    let s:orig_spellfile = &spellfile
    call s:proj_spell_hook()
  endif
endfunc

augroup proj_spell
  autocmd!
  autocmd BufNewFile,BufRead * call s:proj_spell_hook()
augroup END

function! s:combine(left, right)
  " Combines left and right using comma
  if a:left != '' && a:right != ''
    return a:left . ',' . a:right
  elseif a:left == ''
    return a:right
  elseif a:right == ''
    return a:left
  else
    return ''
  endif
endfunc

if !exists(":ProjSpellReload")
  command ProjSpellReload call s:reload_proj_spell()
endif

if !exists(":ProjSpellAddWordGlobal")
  command -nargs=1 ProjSpellAddWordGlobal call s:add_new_word_global(<args>)
endif

if !exists(":ProjSpellAddWordProj")
  command -nargs=1 ProjSpellAddWordProj call s:add_new_word_proj(<args>)
endif

"TODO add new mappings for adding to spellfiles (zg/zG) should be remapped
