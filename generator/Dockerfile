# Copyright (c) 2018 Bitwise IO, Inc.
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/

FROM jekyll/builder:3.5

RUN apk add --update \
    python \
    python-dev \
    py-pip \
    build-base && \
    pip install --upgrade pip && \
    pip install docutils pygments && \
    rm -rf /var/cache/apk/*

COPY Gemfile .
COPY Gemfile.lock .
COPY _config.yml .
RUN gem install RbST