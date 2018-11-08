#!/bin/bash
# Copyright (c) 2018 Bitwise IO, Inc.
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/
##

info(){
    echo -e "\e[94m${1}\e[93m"
}

cd /srv/jekyll/

until [ -f /srv/jekyll/lint.complete -a -f /srv/jekyll/jekyll.complete ]; do
    sleep .2
done

# test for files in build directory
if (shopt -s nullglob dotglob; f=(/srv/jekyll/_site/*); ((${#f[@]}))); then
    info "Copying builds to archive"
    rm -rf ./archive/htdocs
    # Static Repo
    cp -rf /usr/local/apache2/htdocs ./archive/
    # Archived Docs
    sed -i '/versions.json/s/https.*json/\/docs\/versions.json/' ./archive/docs/*/*/*/_static/version_switcher.js
    cp -rd ./archive/docs ./archive/htdocs/
    # Built site
    cp -rf /srv/jekyll/_site/* ./archive/htdocs/
    rm /srv/jekyll/*.complete

    info "Copying build to container: $(du -sh ./archive/htdocs | cut -f1)"
    cp -rf ./archive/htdocs/* /usr/local/apache2/htdocs/
    echo "$BUILDONLY" | grep -qEix 'yes|true|1|y' || /usr/local/apache2/bin/httpd -DFOREGROUND
else
    rm /srv/jekyll/*.complete
    info "Site was not built"
    exit 1
fi
