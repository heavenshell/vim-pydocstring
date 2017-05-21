pydocstring.vim
===============

.. image:: https://travis-ci.org/heavenshell/vim-pydocstring.svg?branch=master
  :target: https://travis-ci.org/heavenshell/vim-pydocstring

.. image:: ./assets/vim-pydocstring.gif

Pydocstring is a generator for Python docstrings and is capable of automatically

* inserting one-line docstrings
* inserting multi-line docstrings
* inserting comments

This plugin is heavily inspired by `phpdoc.vim <http://www.vim.org/scripts/script.php?script_id=1355>`_ and `sonictemplate.vim <https://github.com/mattn/sonictemplate-vim>`_.

Usage
-----

1. Move your cursor on a `def` or `class` keyword line,
2. type `:Pydocstring` or enter `<C-l>` (default keymapping) and
3. watch a docstring template magically appear below the current line

Settings
--------
Pydocstring depends on ``softtabstop``.
You need to set like ``set softtabstop=4``.

Example ``.vimrc``

.. code::

  autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab

Key map
-------

If you want change default keymapping, set following to your `.vimrc`.

.. code::

  nmap <silent> <C-_> <Plug>(pydocstring)
