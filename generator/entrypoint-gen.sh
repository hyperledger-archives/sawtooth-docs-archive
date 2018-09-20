#!/bin/sh

cd /srv/jekyll/
rm -rf /srv/jekyll/_site/*
bundle exec jekyll build -Vs ./source --config ./_config.yml
EXITCODE=$?
touch jekyll.complete
exit $EXITCODE