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
let s:prefix = "ctrlp "

let s:documents_dir = $HOME. '/Documents'
if has("win64") || has("win32") " NOTE: windows MyDocuments workaround
  if !isdirectory(s:documents_dir)
    let s:documents_dir = system("reg query \"HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders\" /v \"Personal\"")
    let s:documents_dir = substitute(s:documents_dir, '^.*REG_SZ\s\+\(.*\)\n\n', '\1', '')
  endif
endif

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
  if isdirectory(file)
    call ctrlp#exit()
    exec "CtrlP ". file
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

"let files = ["documents.vim"]
" current project files
"let current = s:get_current_dir_project()
"if current != "[default]"
"  exec "lcd ". s:documents_dir
"  try
"    let files = files + split(globpath(current, "**",  1), "\n")
"  finally
"    lcd -
"  endtry
"endif
" related project files
"let documents = s:read_documents_vim(s:documents_vim)
"exec "lcd ". s:documents_dir
"try
"  if has_key(documents, current)
"    for dir in documents[current]
"      let files = files + split(globpath("", dir,  1), "\n")
"    endfor
"  endif
"finally
"  lcd -
"endtry
"let s:documents_vim  = s:documents_dir. '/documents.vim'
"function s:refresh_project_vim(documents_vim, documents_dir)
"  let separator = "\"----------"
"  let lines = readfile(a:documents_vim)
"  let index = index(lines, separator)
"  if index >= 0
"    let lines = lines[0:index]
"  else
"    let lines = add(lines, separator)
"  end
"  let dirs = split(globpath(a:documents_dir, "*"), "\n")
"  for dir in dirs
"    if isdirectory(dir)
"      let name  = fnamemodify(dir, ':t')
"      let lines = add(lines, "\"\\ \"". name. "\": [")
"      let lines = add(lines, "\"\\   \"". name. "/**\",")
"      let lines = add(lines, "\"\\ ],")
"    endif
"  endfor
"  let lines = add(lines, "\"\\ \"[default]\": [")
"  let lines = add(lines, "\"\\   \"default/**\",")
"  let lines = add(lines, "\"\\ ],")
"  call writefile(lines, a:documents_vim)
"endfunction
"if a:str == "documents.vim"
"  call s:refresh_project_vim(s:documents_vim, s:documents_dir)
"  call ctrlp#acceptfile(0, s:documents_vim)
"function s:read_documents_vim(documents_vim)
"  if !filereadable(s:documents_vim)
"    call writefile(["let g:documents = {", "\\}"], a:documents_vim)
"  endif
"  exec "source ". s:documents_vim
"  if !exists("g:documents")
"    return {}
"  endif
"  return g:documents
"endfunction
"------------------------------------------------------------------------------
"function s:get_current_buf_project()
"  return s:get_project(fnamemodify(bufname("%"), ":p"))
"endfunction
"function s:get_current_dir_project()
"  return s:get_dir_project(getcwd())
"endfunction
"function s:get_file_project(file)
"  return s:get_dir_project(fnamemodify(a:file, ":p:h"))
"endfunction
"function s:get_dir_project(dir)
"  let paths = split(a:dir, "/")
"  let index = index(paths, "Documents")
"echo paths
"echo index
"  if index >= 0 && index < (len(paths) - 1)
"    return paths[index + 1]
"  end
"  return "[defualt]"
"endfunction
