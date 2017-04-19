Test cases for vim-pydocstring
==========================================

Prerequisite
------------

- [vader.vim](https://github.com/junegunn/vader.vim)

Before running test, clone vader into this directory with:

```
git clone https://github.com/junegunn/vader.vim
```


Run
---

```
./run.sh
```

Note that the command need to be executed under `test` folder.

Use TDD during development (optional)
-------------------------------------

You need [nodemon](https://github.com/remy/nodemon) to watch for files
change and re-run the test cases in given file. Here I already provide
nodemon configuration (see `nodemon.json`.)

Run (again, this need to be executed under `test` folder)

```
nodemon <test-file>.vader
```

Now, if you modify the `vader` or `vim` files in this project, nodemon will
re-run all the test cases (via `run-single-test-file.sh`).


### Know issue

Vim warns `Input is not from a terminal` when we run tests with
`nodemon`. Neovim doesn't. That why in the scripts, we prefer to use
`nvim` if it is found on path.
