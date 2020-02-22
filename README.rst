pydocstring.vim
===============

.. image:: https://travis-ci.org/heavenshell/vim-pydocstring.svg?branch=master
  :target: https://travis-ci.org/heavenshell/vim-pydocstring

.. image:: ./assets/vim-pydocstring.gif

Pydocstring is a generator for Python docstrings and is capable of automatically

* inserting one-line docstrings
* inserting multi-line docstrings

This plugin is heavily inspired by `phpdoc.vim <http://www.vim.org/scripts/script.php?script_id=1355>`_ and `sonictemplate.vim <https://github.com/mattn/sonictemplate-vim>`_.

Install
-------

Since version 2, pydocstring requires `doq <https://pypi.org/project/doq/>`_.

You can install following command.

.. code::

  $ make install

If you want install doq manually, you can install from PyPi.

.. code::

  $ python3 -m venv ./venv
  $ ./venv/bin/pip3 install doq

Than set installed `doq` path to `g:pydocstring_doq_path`.

.. note::

  pydocstring is now support only Vim8.

Basic usage
-----------

1. Move your cursor on a `def` or `class` keyword line,
2. type `:Pydocstring` and
3. watch a docstring template magically appear below the current line

Format all
----------

type `:PydocstringFormat` will insert all docstrings to current buffer.

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

Custom template
---------------

You can set custom template

.. code::

  let g:pydocstring_template_path = '/path/to/custom/templates'
