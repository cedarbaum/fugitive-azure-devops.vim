if exists('g:loaded_fugitive_azure_devops')
    finish
endif
let g:loaded_fugitive_azure_devops = 1

if !exists('g:fugitive_browse_handlers')
    let g:fugitive_browse_handlers = []
endif

if index(g:fugitive_browse_handlers, function('azuredevops#fugitive_handler')) < 0
    call insert(g:fugitive_browse_handlers, function('azuredevops#fugitive_handler'))
endif
