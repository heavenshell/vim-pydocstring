#!/bin/sh

set -e

if [ ! -v $VIRTUAL_ENV ]; then
  echo "You already in virtualenv. deactivate first."
  exit 1
fi

LIBDIR=$(cd $(dirname $0); pwd)

python3 -m venv ${LIBDIR}/venv
$LIBDIR/venv/bin/pip3 install -U pip
$LIBDIR/venv/bin/pip3 install doq
ln -sfn "${LIBDIR}/venv/bin/doq" "${LIBDIR}/doq"
