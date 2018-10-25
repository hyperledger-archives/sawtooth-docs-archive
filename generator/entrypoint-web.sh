#!/bin/bash
# Copyright (c) 2018 Bitwise IO, Inc.
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/
##

readonly wd="$(pwd)"

info(){
    echo -e "\e[94m${1}\e[93m"
}

get_archives(){
    wget -qNrA gz -nH --no-parent --no-check-certificate \
        https://sawtooth.hyperledger.org/archive/core/
    wget -qNO archive/core/sl.txt --no-check-certificate \
        https://sawtooth.hyperledger.org/archive/core/sl.txt
}

info "Retrieving docs"
get_archives

info "Extracting docs"
mkdir -p ./archive/docs
ls ./archive/core/*.gz | xargs -I{} tar --skip-old-files -xzf {} \
    -C ./archive/docs/

info "Retrieving nightlies"
for repo in core seth raft sabre supply-chain; do
    for branch in master; do
        url="https://build.sawtooth.me/job/Sawtooth-Hyperledger/job/"
        url="${url}sawtooth-${repo}"
        url="${url}/job/"
        url="${url}${branch}"
        url="${url}/lastSuccessfulBuild/artifact/docs/build/html/*zip*/html.zip"
        mkdir -p ./archive/nightly/${repo}
        wget -qNO ./archive/nightly/${repo}/${branch}.zip \
            --no-check-certificate "${url}"
        unzip -qn ./archive/nightly/${repo}/${branch}.zip \
            -d ./archive/nightly/${repo}/
        mkdir -p ./archive/docs/${repo}/nightly/${branch}/
        cp -rd ./archive/nightly/${repo}/html/* \
            ./archive/docs/${repo}/nightly/${branch}/
    done
done

info "Setting symlinks"
for line in $(cat ${wd}/archive/core/sl.txt); do
    parent=$(echo $line | cut -d: -f1)
    link=$(echo $line | cut -d: -f2)
    target=$(echo $line | cut -d: -f3)
    mkdir -p ${wd}/archive/docs/${parent}
    cd ${wd}/archive/docs/${parent}
    ln -frsT $target $link
done
cd ${wd}


until [ -f /srv/jekyll/lint.complete ]; do
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

    info "Copying build to container"
    cp -rf ./archive/htdocs/* /usr/local/apache2/htdocs/
    /usr/local/apache2/bin/httpd -DFOREGROUND
else
    rm /srv/jekyll/*.complete
    info "Site was not built"
    exit 1
fi
