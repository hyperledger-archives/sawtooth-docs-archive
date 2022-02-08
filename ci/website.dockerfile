# Copyright (c) 2018 Bitwise IO, Inc.
#
# Copyright 2020 Cargill Incorporated
#
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/

# -------------=== build python sdk docs ===-------------
FROM ubuntu:focal as sdk-python-docs

RUN apt-get update \
 && apt-get install gnupg -y

ENV VERSION=AUTO_STRICT
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y -q \
    git \
    pkg-config \
    python3 \
    python3-pip \
    python3-colorlog \
    python3-stdeb \
    python3-grpcio \
    python3-toml \
    python3-yaml \
    python3-zmq \
  && pip3 install secp256k1 grpcio-tools protobuf


WORKDIR /project

RUN git clone https://github.com/hyperledger/sawtooth-sdk-python.git

ENV PATH=$PATH:/project/sawtooth-sdk-python/bin

WORKDIR /project/sawtooth-sdk-python

RUN echo "\033[0;32m--- Building python sdk ---\n\033[0m" \
 && bin/protogen \
 && python3 setup.py clean --all \
 && python3 setup.py build

RUN pydoc3 -w sawtooth_sdk/processor/* \
 && mkdir -p /tmp/python_sdk/processor \
 && cp *.html /tmp/python_sdk/processor \
 && pydoc3 -w sawtooth_signing/* \
 && mkdir -p /tmp/python_sdk/signing \
 && cp *.html /tmp/python_sdk/signing

# -------------=== jekyll build ===-------------

FROM jekyll/jekyll:3.8 as jekyll

RUN gem install \
    bundler \
    jekyll-default-layout \
    jekyll-optional-front-matter \
    jekyll-readme-index \
    jekyll-redirect-from \
    jekyll-seo-tag \
    jekyll-target-blank \
    jekyll-titles-from-headings

ARG jekyll_env=development
ENV JEKYLL_ENV=$jekyll_env

COPY . /srv/jekyll

WORKDIR /srv/jekyll

RUN rm -rf /srv/jekyll/_site \
 && jekyll build --verbose --destination /tmp

# -------------=== log commit hash ===-------------

FROM alpine as git

RUN apk update \
 && apk add \
    git

COPY .git/ /tmp/.git/
WORKDIR /tmp
RUN git rev-parse HEAD > /commit-hash

# -------------=== apache docker build ===-------------

FROM httpd:2.4

COPY --from=jekyll /tmp/ /usr/local/apache2/htdocs/
COPY --from=sdk-python-docs /tmp/python_sdk /usr/local/apache2/htdocs/docs/1.2/sdks/python_sdk
COPY --from=git /commit-hash /commit-hash

RUN echo "\
\n\
ServerName sawtooth.hyperledger.org\n\
ErrorDocument 404 /404.html\
\n\
" >>/usr/local/apache2/conf/httpd.conf

EXPOSE 80/tcp
