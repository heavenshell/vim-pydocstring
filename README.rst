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

Than set installed `doq <https://pypi.org/project/doq/>`_ path to `g:pydocstring_doq_path`.


Note
~~~~

pydocstring is now support only Vim8.
If you want use old version checkout `1.0.0 <https://github.com/heavenshell/vim-pydocstring/releases/tag/1.0.0>`_

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

Foramtter
---------

You can set built-in formatter(Sphinx, Numpy, Google).

.. code::

  leg g:pydocstring_formatter = 'numpy'


Custom template
---------------

You can set custom template. See `example <https://github.com/heavenshell/py-doq/tree/master/examples>`_.

.. code::

  let g:pydocstring_template_path = '/path/to/custom/templates'

Exceptions
----------

If you want add exceptions to docstring, create custom template
and visual select source block and hit `:'<,'>Pydocstring` and then 
excptions add to docstring.

.. code::

  def foo():
      """Summary of foo.

      Raises:
          Exception:
      """
      raise Exception('foo')

Thanks
------

The idea of venv installation is from `vim-lsp-settings <https://github.com/mattn/vim-lsp-settings>`_.
Highly applicate `@mattn <https://github.com/mattn/>`_ and all vim-lsp-settings contributors.
