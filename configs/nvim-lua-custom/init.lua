require "custom.mappings"

vim.api.nvim_command('au VimEnter,VimResume * set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,sm:block')

vim.api.nvim_command('au VimLeave,VimSuspend * set guicursor=a:hor50')

vim.api.nvim_command('au VimLeave * call nvim_cursor_set_shape("vertical-bar")')

vim.api.nvim_command('augroup fmt')
vim.api.nvim_command('autocmd!')
vim.api.nvim_command('autocmd BufWritePre * undojoin | Neoformat')
vim.api.nvim_command('augroup END')

vim.api.nvim_command('let g:go_highlight_fields = 1')
vim.api.nvim_command('let g:go_highlight_functions = 1')
vim.api.nvim_command('let g:go_highlight_function_calls = 1')
vim.api.nvim_command('let g:go_highlight_extra_types = 1')
vim.api.nvim_command('let g:go_highlight_operators = 1')

vim.api.nvim_command('au filetype go inoremap <buffer> . .<C-x><C-o>')
--vim.api.nvim_command('let g:go_fmt_command = "goimports"')
