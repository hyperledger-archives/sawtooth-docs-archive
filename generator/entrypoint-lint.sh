#!/bin/sh

cd /srv/jekyll/

until [ -f /srv/jekyll/jekyll.complete ]; do
    sleep .2
done

ISSUES="$(mdl -i -r ~MD033 ./source 2>&1)"
EXITCODE=$?

if [ $EXITCODE -ne 0 ]; then
    echo -e '\e[93m=== START LINTING ===\e[0m'
    echo -e "$(echo "$ISSUES" | sed 's/^/\\e[31m/')\n"
    echo -e "\e[93mRemediate these formating issues before creating a PR\e[0m\n"
    echo -e '\e[93m=== END LINTING ===\e[0m'
    echo "<pre>${ISSUES}</pre>" > /srv/jekyll/_site/mdl.html
else
    echo -e '\e[32m=== NO LINTING ERRORS FOUND ===\e[0m'
fi

touch /srv/jekyll/lint.complete

exit $EXITCODE