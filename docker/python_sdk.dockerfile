# Copyright 2022 Cargill Incorporated
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:focal as sawtooth-sdk-python-builder

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
