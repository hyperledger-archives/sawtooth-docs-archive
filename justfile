# Copyright 2023 Bitwise IO, Inc.
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

build:
    #!/usr/bin/env sh
    set -e

    if [ $(uname -s) = "Darwin" ]; then
        export RUBY_VERSION=3.1.3
        source $(brew --prefix)/opt/chruby/share/chruby/chruby.sh
        chruby ruby-$RUBY_VERSION
    fi

    bundle install
    bundle exec jekyll build

clean:
    rm -rf \
        .jekyll-metadata/ \
        _site/ \
        Gemfile.lock

install-jekyll-via-brew:
    #!/usr/bin/env sh
    set -e

    brew install chruby ruby-install xz

    export RUBY_VERSION=3.1.3
    ruby-install ruby $RUBY_VERSION --no-reinstall --cleanup
    source $(brew --prefix)/opt/chruby/share/chruby/chruby.sh
    chruby ruby-$RUBY_VERSION

    gem install jekyll bundler mdl

install-mdl:
    #!/usr/bin/env sh
    set -e

    if [ $(uname -s) = "Darwin" ]; then
        export RUBY_VERSION=3.1.3
        source $(brew --prefix)/opt/chruby/share/chruby/chruby.sh
        chruby ruby-$RUBY_VERSION
    fi

    gem install mdl

run:
    #!/usr/bin/env sh
    set -e

    if [ $(uname -s) = "Darwin" ]; then
        export RUBY_VERSION=3.1.3
        source $(brew --prefix)/opt/chruby/share/chruby/chruby.sh
        chruby ruby-$RUBY_VERSION
    fi

    bundle install
    bundle exec jekyll serve --incremental

lint:
    #!/usr/bin/env sh
    set -e

    if [ $(uname -s) = "Darwin" ]; then
        export RUBY_VERSION=3.1.3
        source $(brew --prefix)/opt/chruby/share/chruby/chruby.sh
        chruby ruby-$RUBY_VERSION
    fi

    mdl -g -i -r ~MD001,~MD002,~MD003,~MD004,~MD005,~MD006,~MD007,~MD009,~MD012,~MD013,~MD014,~MD019,~MD022,~MD024,~MD023,~MD025,~MD026,~MD027,~MD028,~MD029,~MD030,~MD031,~MD032,~MD033,~MD034,~MD035,~MD036,~MD046,~MD047,~MD055,~MD056,~MD057 .
