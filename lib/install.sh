#!/bin/sh

set -e

if [ ! -v $VIRTUAL_ENV ]; then
  echo 'You already in virtualenv. deactivate first.'
  exit 1
fi

python3 -m venv ./venv
./venv/bin/pip3 install -U pip
./venv/bin/pip3 install doq
ln -s "./venv/bin/doq" .
