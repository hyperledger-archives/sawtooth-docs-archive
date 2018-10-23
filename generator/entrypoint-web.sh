#!/bin/bash
# Copyright (c) 2018 Bitwise IO, Inc.
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/

until [ -f /srv/jekyll/lint.complete ]; do
    sleep .2
done

# test for files in build directory
if (shopt -s nullglob dotglob; f=(/srv/jekyll/_site/*); ((${#f[@]}))); then
    cp -rf /srv/jekyll/_site/* /usr/local/apache2/htdocs/
    rm /srv/jekyll/*.complete

    /usr/local/apache2/bin/httpd -DFOREGROUND
else
    rm /srv/jekyll/*.complete
	echo "Site was not built">&2
	exit 1
fi
