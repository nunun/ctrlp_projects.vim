if exists('g:autoload_ctrlp_projects') && g:autoload_ctrlp_projects
  finish
endif
let g:autoload_ctrlp_projects = 1
let s:save_cpo = &cpo
set cpo&vim

let s:projects_var = {
\ 'init':   'ctrlp#projects#init()',
\ 'accept': 'ctrlp#projects#accept',
\ 'lname':  'projects',
\ 'sname':  'projects',
\ 'type':   'path',
\ 'nolim':  1
\}

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:projects_var)
else
  let g:ctrlp_ext_vars = [s:projects_var]
endif
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

let s:documents_dir = $HOME. '/Documents'
if has("win64") || has("win32")
  if !isdirectory(s:documents_dir)
    let s:documents_dir = system("reg query \"HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders\" /v \"Personal\"")
    let s:documents_dir = substitute(s:documents_dir, '^.*REG_SZ\s\+\(.*\)\n\n', '\1', '')
  endif
endif
let s:projects_vim = s:documents_dir. '/projects.vim'

function! ctrlp#projects#id() abort
  return s:id
endfunction

function! ctrlp#projects#init() abort
  if !isdirectory(s:documents_dir)
    echoerr "Documents directory not found: ". s:documents_dir
    return []
  endif
  if !filereadable(s:projects_vim)
    call writefile([
    \ "\" projects in Documents globpath",
    \ "\"let g:projects = [",
    \ "\"\\  [\"myproject\", \"**/*.txt\"]",
    \ "\"\\]"
    \], s:projects_vim)
  endif
  exec "source ". s:projects_vim
  if !exists("g:projects")
    let g:projects = []
  endif
  let files = [ "projects.vim" ]
  try
    exec "cd ". s:documents_dir
    for pair in g:projects
      let files = files + split(globpath(pair[0],  pair[1],  1), "\n")
    endfor
  finally
    cd -
  endtry
  return files
endfunction

function! ctrlp#projects#accept(mode, str) abort
  let file = s:documents_dir. "/". a:str
  call ctrlp#acceptfile(0, file)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
