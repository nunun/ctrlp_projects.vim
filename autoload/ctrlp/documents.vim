if exists('g:autoload_ctrlp_documents') && g:autoload_ctrlp_documents
  finish
endif
let g:autoload_ctrlp_documents = 1
let s:save_cpo = &cpo
set cpo&vim

let s:documents_var = {
\ 'init':   'ctrlp#documents#init()',
\ 'accept': 'ctrlp#documents#accept',
\ 'lname':  'documents',
\ 'sname':  'documents',
\ 'type':   'path',
\ 'nolim':  1
\}

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:documents_var)
else
  let g:ctrlp_ext_vars = [s:documents_var]
endif
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

let s:documents_dir = fnamemodify("~/Documents", ":p")
if has("win64") || has("win32") " NOTE: windows MyDocuments workaround
  if !isdirectory(s:documents_dir)
    let s:documents_dir = system("reg query \"HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders\" /v \"Personal\"")
    let s:documents_dir = substitute(s:documents_dir, '^.*REG_SZ\s\+\(.*\)\n\n', '\1', '')
  endif
endif
"let s:prefix = ":CtrlP ". fnamemodify(s:documents_dir, ":~")
let s:prefix = ""

function! ctrlp#documents#id() abort
  return s:id
endfunction

function! ctrlp#documents#init() abort
  if !isdirectory(s:documents_dir)
    echoerr "Documents directory not found: ". s:documents_dir
    return []
  endif
  let files = []
  for dir in split(globpath(s:documents_dir, "*",  1), "\n")
    if isdirectory(dir)
      let file = s:prefix. fnamemodify(dir, ":t")
      call add(files, file)
    endif
  endfor
  return files
endfunction

function! ctrlp#documents#accept(mode, str) abort
  let str  = a:str[strlen(s:prefix):]
  let file = s:documents_dir. "/". str
  if !s:ctrlp_nest(file, g:ctrlp_documents_forwards)
    call s:ctrlp_nest(file, [""])
  endif
endfunction

function s:ctrlp_nest(file, fwds)
  for fwd in a:fwds
    let file_fwd = a:file. '/'. fwd
    if isdirectory(file_fwd)
      call ctrlp#exit()
      if g:ctrlp_documents_filer_mode
        exec "tabnew ". file_fwd
      else
        exec "CtrlP ". file_fwd
      endif
      return 1
    endif
  endfor
  return 0
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
