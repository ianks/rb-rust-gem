#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

setup_ruby() {
}

upgrade_rubygems() {
  git clone --single-branch --branch cargo-builder-target --depth 1 https://github.com/ianks/rubygems /tmp/rubygems
  pushd /tmp/rubygems
  "$HOME/.rake-compiler/ruby/arm-linux-gnueabihf/ruby-$RUBY_VERSION/bin/ruby"
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
  cd examples/rust_ruby_example
  mkdir build
  "$HOME/.rake-compiler/ruby/arm-linux-gnueabihf/ruby-$RUBY_VERSION/bin/gem" build --verbose rust_ruby_example.gemspec
  "$HOME/.rake-compiler/ruby/arm-linux-gnueabihf/ruby-$RUBY_VERSION/bin/gem" install --verbose rust_ruby_example-*.gem --install-dir ./build/$RUBY_TARGET
  "$HOME/.rake-compiler/ruby/arm-linux-gnueabihf/ruby-$RUBY_VERSION/bin/ruby" -rrust_ruby_example -e "puts RustRubyExample.reverse('Hello, world!')"
}

setup_ruby
setup_rust
upgrade_rubygems
build_example
