# fugitive-azure-devops.vim

This extension enables the `Gbrowse` functionality of the [fugitive.vim](https://github.com/tpope/vim-fugitive) plugin to work with [Azure DevOps](https://azure.microsoft.com/en-us/services/devops/) Git repositories.

## Installation

Make sure that you've installed the [fugitive.vim](https://github.com/tpope/vim-fugitive) plugin. Afterwards, install this plugin using your favorite plugin manager (e.g., [pathogen.vim](https://github.com/tpope/vim-pathogen), [vim-plug](https://github.com/junegunn/vim-plug)).

## FAQ

1. Which domains are supported?
> You can change the domain by setting `g:fugitive_azure_devops_baseurl`. Defaults is `dev.azure.com`
2. Is Omni completion supported?
> Not currently. This could be done via the [Azure DevOps REST API](https://docs.microsoft.com/en-us/rest/api/azure/devops/?view=azure-devops-rest-5.0).

## Acknowledgments

This plugin is heavily based on the [rhubarb.vim](https://github.com/tpope/vim-rhubarb) and [fugitive-gitlab.vim](https://github.com/shumphrey/fugitive-gitlab.vim) plugins, which add `Gbrowse` functionality for [GitHub](https://github.com/) and [GitLab](https://about.gitlab.com/), respectively. The test infrastructure, including many GBrowse tests, are also from the [fugitive-gitlab.vim](https://github.com/shumphrey/fugitive-gitlab.vim) plugin. Both plugins are distributed under Vim's license.

## License
Copyright (c) Sam Cedarbaum. Distributed under the same terms as Vim itself. See `:help license`.
