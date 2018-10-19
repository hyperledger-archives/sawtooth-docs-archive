#!/bin/bash
# Copyright (c) 2018 Bitwise IO, Inc.
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/

until [ -f /srv/jekyll/lint.complete ]; do
    sleep .2
done

cp -rf /srv/jekyll/_site/* /usr/local/apache2/htdocs/
rm /srv/jekyll/*.complete

/usr/local/apache2/bin/httpd -DFOREGROUND