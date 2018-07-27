#!/bin/sh

BASEDIR=$(dirname "$0")
cd $BASEDIR


for i in {1..50}
do
    ./bots-alignment -f botsalgn > botsalgn.out 2>> botsalgn.err
done
