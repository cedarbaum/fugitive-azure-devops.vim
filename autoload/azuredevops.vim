if exists('g:autoloaded_fugitive_azure_devops')
  finish
endif
let g:autoloaded_fugitive_azure_devops = 1
let s:fugitive_azure_devops_baseurl = get(g:, 'fugitive_azure_devops_baseurl', 'dev\.azure\.com')

function! azuredevops#fugitive_handler(opts, ...) abort
  let path   = substitute(get(a:opts, 'path', ''), '^/', '', '')
  let line1  = get(a:opts, 'line1')
  let line2  = get(a:opts, 'line2')
  let remote = get(a:opts, 'remote')

  let root = azuredevops#homepage_for_remote(remote)
  if empty(root)
    return ''
  endif

  " Handle git object paths
  if path =~# '^\.git/refs/heads/'
    return s:add_commit_query_param(root, path[16:-1])
  elseif path =~# '^\.git/refs/tags/'
    return s:add_tag_query_param(root, path[15:-1])
  elseif path =~# '^\.git\>'
    return root
  endif

  " Handle file/directory paths
  let url = s:add_path_query_param(root, path)
  let url = s:add_commit_query_param(url, a:opts.commit)

  " Add line number range for blobs
  if (get(a:opts, 'type', '') ==# 'blob' || path =~# '[^/]$') && line1 !=# 0
    return s:add_line_range_query_params(url, line1, line2)
  endif

  return url
endfunction

function! azuredevops#homepage_for_remote(remote) abort
  if !exists('g:fugitive_azure_devops_ssh_user')
    let g:fugitive_azure_devops_ssh_user = 'git'
  endif

  " Below are all supported url patterns. Note that for Azure DevOps only
  " variants (1) and (2) have been confirmed to be valid. Others should be
  " tested and removed as necessary.
  " 1.) https://user@domain/path
  " 2.) https://user@ssh.domain/path
  " 3.) https://domain/path
  " 4.) git://domain:path
  " 5.) ssh://git@domain/path.git
  " 6.) ssh://user@domain/path.git
  " 7.) ssh://git@domain:ssh_port/path.git
  let url = matchstr(a:remote, '^\%(https\=://\|' .
    \                          'git://\|' .
    \                          g:fugitive_azure_devops_ssh_user . '@\|' .
    \                          g:fugitive_azure_devops_ssh_user . '@ssh\.\|' .
    \                          'ssh://' . g:fugitive_azure_devops_ssh_user . '@\|\)' .
    \                          '\%(.\{-\}@\)\=\zs\(' . s:fugitive_azure_devops_baseurl . '\)[/:].\{-\}\ze\%(\.git\)\=$')

  if url == ''
    return ''
  endif

  " SSH urls don't have the required '_git' path segment. Add it here.
  if stridx(url, '/_git/') == -1
    let index_of_last_slash = strridx(url, '/')
    let url = strpart(url, 0, index_of_last_slash) .
      \       '/_git' .
      \       strpart(url, index_of_last_slash)
  endif

  " Remove double encoded spaces (%2F20) from path (see: https://github.com/tpope/vim-fugitive/issues/2230)
  let url = substitute(url, '%2F20', '%20', 'g')

  " Remove port or version specifier (e.g., v3), always use HTTPS.
  return 'https://' . substitute(url, ':v\=\d\{1,5}\/', '/', '')
endfunction

function! s:add_line_range_query_params(url, line1, line2) abort
  let l1_url = s:add_query_param(a:url, 'line', a:line1)
  let l2_url = s:add_query_param(l1_url, 'lineEnd', a:line2)
  " Start and end columns are always required.
  return l2_url . '&lineStartColumn=1&lineEndColumn=9999&lineStyle=plain'
endfunction

function! s:add_path_query_param(url, path) abort
  return s:add_query_param(a:url, 'path', a:path)
endfunction

function! s:add_tag_query_param(url, tag) abort
  return s:add_query_param(a:url, 'version', 'GT' . a:tag)
endfunction

function! s:add_commit_query_param(url, commit) abort
  " Determine if commit hash or HEAD of a branch
  if a:commit =~# '^\x\{40}'
    let version_prefix = "GC"
  else
    let version_prefix = "GB"
  endif

  return s:add_query_param(a:url, 'version', version_prefix . a:commit)
endfunction

function! s:add_query_param(url, param_name, param_value) abort
  " Either start a new query parameter suffix or append to the existing one
  if stridx(a:url, '?') == -1
    let url_base = a:url . '?'
  else
    let url_base = a:url . '&'
  endif

  let query_param = a:param_name . '=' . s:url_encode(a:param_value)
  return url_base . query_param
endfunction

" Modified snippet from vim-rhubarb (https://github.com/tpope/vim-rhubarb/blob/master/autoload/rhubarb.vim, commit 70713ca)
" See also: https://github.com/cedarbaum/fugitive-azure-devops.vim/issues/3
function! s:url_encode(str) abort
  return substitute(substitute(a:str, '[?@=&<>#/:+[:space:]]\|%\%(\x\x\)\@!', '\=printf("%%%02X", char2nr(submatch(0)))', 'g'), '%20', '+', 'g')
endfunction
