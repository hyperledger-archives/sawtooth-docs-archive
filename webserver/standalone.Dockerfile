# Copyright (c) 2018 Bitwise IO, Inc.
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/
FROM httpd:2.4

COPY ./generator/archive/htdocs/ /usr/local/apache2/htdocs/
COPY ./webserver/httpd.conf /usr/local/apache2/conf/httpd.conf
