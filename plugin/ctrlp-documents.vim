if exists('g:plugin_ctrlp_documents')
  finish
endif
let g:plugin_ctrlp_documents = 1
let s:save_cpo = &cpo
set cpo&vim

command! CtrlPDocuments call ctrlp#init(ctrlp#documents#id())

noremap <plug>(ctrlp-documents) :<C-u>CtrlPDocuments<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
