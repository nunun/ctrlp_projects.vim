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
    call writefile(["let g:projects = {", "\\}"], s:projects_vim)
  endif
  exec "source ". s:projects_vim
  if !exists("g:projects")
    let g:projects = {}
  endif
  let project = s:get_project()
  exec "cd ". s:documents_dir
  try
    let files = ["projects.vim"]
    if has_key(g:projects, project)
      for dir in g:projects[project]
        let path  = s:documents_dir. "/". dir
        let files = files + split(globpath(dir, "**",  1), "\n")
      endfor
    endif
  finally
    cd -
  endtry
  return files
endfunction

function! ctrlp#projects#accept(mode, str) abort
  let file = s:documents_dir. "/". a:str
  if a:str == "projects.vim"
    call s:add_projects(file)
  endif
  call ctrlp#acceptfile(0, file)
endfunction

function s:get_project()
  let paths = split(expand("%:p:h"), "/")
  let index = index(paths, "Documents")
  if index >= 0
    return paths[index + 1]
  end
  return ""
endfunction

function s:add_projects(file)
  let separator = "\"----------"
  let lines = readfile(a:file)
  let index = index(lines, separator)
  if index >= 0
    let lines = lines[0:index]
  else
    let lines = add(lines, separator)
  end
  let dirs = split(globpath(s:documents_dir, "*"), "\n")
  for dir in dirs
    if isdirectory(dir)
      let line  = "\"\\ \"". fnamemodify(dir, ':t'). "\": [],"
      let lines = add(lines, line)
    endif
  endfor
  call writefile(lines, a:file)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
