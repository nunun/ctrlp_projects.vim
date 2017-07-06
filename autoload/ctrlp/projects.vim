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
if has("win64") || has("win32") " NOTE: windows MyDocuments workaround
  if !isdirectory(s:documents_dir)
    let s:documents_dir = system("reg query \"HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders\" /v \"Personal\"")
    let s:documents_dir = substitute(s:documents_dir, '^.*REG_SZ\s\+\(.*\)\n\n', '\1', '')
  endif
endif

let s:projects_vim  = s:documents_dir. '/projects.vim'

function! ctrlp#projects#id() abort
  return s:id
endfunction

function! ctrlp#projects#init() abort
  if !isdirectory(s:documents_dir)
    echoerr "Documents directory not found: ". s:documents_dir
    return []
  endif

  let files = ["projects.vim"]
  for dir in split(globpath(s:documents_dir, "*",  1), "\n")
    if isdirectory(dir)
      call add(files, fnamemodify(dir, ":t"))
    endif
  endfor

  let projects = s:read_projects_vim(s:projects_vim)
  let current  = s:get_current_project()
  exec "lcd ". s:documents_dir
  try
    if has_key(projects, current)
      for dir in projects[current]
        let files = files + split(globpath("", dir,  1), "\n")
      endfor
    endif
  finally
    lcd -
  endtry
  return files
endfunction

function! ctrlp#projects#accept(mode, str) abort
  let file = s:documents_dir. "/". a:str
  if a:str == "projects.vim"
    call s:refresh_project_vim(s:projects_vim, s:documents_dir)
    call ctrlp#acceptfile(0, s:projects_vim)
  else
    call ctrlp#acceptfile(0, file)
    exec "lcd ". s:documents_dir. "/". s:get_project(file)
  endif
endfunction

"------------------------------------------------------------------------------

function s:read_projects_vim(projects_vim)
  if !filereadable(s:projects_vim)
    call writefile(["let g:projects = {", "\\}"], a:projects_vim)
  endif
  exec "source ". s:projects_vim
  if !exists("g:projects")
    return {}
  endif
  return g:projects
endfunction

function s:refresh_project_vim(projects_vim, projects_dir)
  let separator = "\"----------"
  let lines = readfile(a:projects_vim)
  let index = index(lines, separator)
  if index >= 0
    let lines = lines[0:index]
  else
    let lines = add(lines, separator)
  end
  let dirs = split(globpath(a:projects_dir, "*"), "\n")
  for dir in dirs
    if isdirectory(dir)
      let name  = fnamemodify(dir, ':t')
      let lines = add(lines, "\"\\ \"". name. "\": [")
      let lines = add(lines, "\"\\   \"". name. "/**\",")
      let lines = add(lines, "\"\\ ],")
    endif
  endfor
  let lines = add(lines, "\"\\ \"[default]\": [")
  let lines = add(lines, "\"\\   \"default/**\",")
  let lines = add(lines, "\"\\ ],")
  call writefile(lines, a:projects_vim)
endfunction

function s:get_current_project()
  return s:get_project(fnamemodify(bufname("%"), ":p"))
endfunction

function s:get_project(file)
  let paths = split(fnamemodify(a:file, ":p:h"), "/")
  let index = index(paths, "Documents")
  if index >= 0 && index < (len(paths) - 1)
    return paths[index + 1]
  end
  return "[defualt]"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
