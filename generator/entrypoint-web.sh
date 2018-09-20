#!/bin/bash

until [ -f /srv/jekyll/lint.complete ]; do
    sleep .2
done

cp -rf /srv/jekyll/_site/* /usr/local/apache2/htdocs/
rm /srv/jekyll/*.complete

/usr/local/apache2/bin/httpd -DFOREGROUND