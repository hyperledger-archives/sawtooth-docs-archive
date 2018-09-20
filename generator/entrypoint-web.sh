#!/bin/bash

until [ -f /srv/jekyll/lint.complete ]; do
    sleep .2
done

cp -r /srv/jekyll/_site /usr/local/apache2/htdocs/info
rm /srv/jekyll/*.complete

/usr/local/apache2/bin/httpd -DFOREGROUND