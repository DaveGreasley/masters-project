#!/bin/sh

BASEDIR=$(dirname "$0")
cd $BASEDIR

./bots-alignment -f botsalgn > botsalgn.out 2>> botsalgn.err

