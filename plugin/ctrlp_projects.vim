if exists('g:plugin_ctrlp_projects')
  finish
endif
let g:plugin_ctrlp_projects = 1
let s:save_cpo = &cpo
set cpo&vim

command! CtrlPProjects call ctrlp#init(ctrlp#projects#id())

nmap s<C-p> :CtrlPProjects<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
