#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

setup_ruby() {
  export PATH="$HONME/.rake-compiler/ruby/arm-linux-gnueabihf/ruby-$RUBY_VERSION/bin:$PATH"
}

upgrade_rubygems() {
  git clone --single-branch --branch cargo-builder-target --depth 1 https://github.com/ianks/rubygems /tmp/rubygems
  pushd /tmp/rubygems
  ruby setup.rb
  popd
  rm -rf /tmp/rubygems
}

setup_rust() {
  curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain $RUST_TOOLCHAIN --profile minimal -y
  export PATH=/root/.cargo/bin:$PATH
  source $HOME/.cargo/env
  rustup target add $RUST_TARGET
  export CARGO_BUILD_TARGET="$RUST_TARGET"
  export PKG_CONFIG_ALLOW_CROSS=1
}

build_example() {
  rvm use $RUBY_VERSION
  cd examples/rust_ruby_example
  mkdir build
  gem build --verbose rust_ruby_example.gemspec
  gem install --verbose rust_ruby_example-*.gem --install-dir ./build/$RUBY_TARGET
  ruby -rrust_ruby_example -e "puts RustRubyExample.reverse('Hello, world!')"
}

setup_ruby
setup_rust
upgrade_rubygems
build_example
