if exists('g:plugin_ctrlp_documents')
  finish
endif
let g:plugin_ctrlp_documents = 1
let s:save_cpo = &cpo
set cpo&vim

if !exists("g:ctrlp_documents_filer_mode")
    let g:ctrlp_documents_filer_mode = 0
endif
if !exists("g:ctrlp_documents_forwards")
    let g:ctrlp_documents_forwards = []
endif

command! CtrlPDocuments call ctrlp#init(ctrlp#documents#id())

noremap <plug>(ctrlp-documents) :<C-u>CtrlPDocuments<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
