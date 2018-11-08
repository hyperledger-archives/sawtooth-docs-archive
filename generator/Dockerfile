# Copyright (c) 2018 Bitwise IO, Inc.
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/

FROM ruby:2.5.3-slim-stretch

ENV PYTHONIOENCODING=utf-8

RUN apt-get update -q && \
    apt-get install -qq --no-install-recommends \
    python \
    python-dev \
    build-essential \
    curl \
    wget \
    python-pip \
    unzip && \
    rm -rf /var/lib/apt/lists/* && \
    pip install docutils pygments && \
    gem install jekyll bundler

COPY Gemfile .
COPY Gemfile.lock .
COPY _config.yml .
RUN gem install RbST
