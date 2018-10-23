#!/bin/sh
# Copyright (c) 2018 Bitwise IO, Inc.
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/

cd /srv/jekyll/
rm -rf /srv/jekyll/_site/*
bundle exec jekyll build -V --config ./_config.yml
EXITCODE=$?
touch jekyll.complete
exit $EXITCODE