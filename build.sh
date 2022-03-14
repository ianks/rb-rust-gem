#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

setup_ruby() {
  export RUBY="$HOME/.rake-compiler/ruby/x86_64-redhat-linux/$RUBY_VERSION/bin/ruby"
  export GEM_BIN="$HOME/.rake-compiler/ruby/x86_64-redhat-linux/$RUBY_VERSION/bin/gem"
  echo "Using $RUBY_VERSION"
}

upgrade_rubygems() {
  git clone --single-branch --branch cargo-builder-target --depth 1 https://github.com/ianks/rubygems /tmp/rubygems
  pushd /tmp/rubygems
  # "$HOME/.rake-compiler/ruby/arm-linux-gnueabihf/$RUBY_VERSION/bin/ruby" setup.rb
  "$RUBY" setup.rb
  popd
  rm -rf /tmp/rubygems
}

setup_rust() {
  curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain "$RUST_TOOLCHAIN" --profile minimal -y
  export PATH=/root/.cargo/bin:$PATH
  source "$HOME/.cargo/env"
  rustup target add "$RUST_TARGET"
  export CARGO_BUILD_TARGET="$RUST_TARGET"
  export PKG_CONFIG_ALLOW_CROSS=1
}

build_example() {
  cd examples/rust_ruby_example
  mkdir build
  "$GEM_BIN" build --verbose rust_ruby_example.gemspec
  "$GEM_BIN" install --verbose rust_ruby_example-*.gem --install-dir "./build/$RUBY_TARGET"
  "$RUBY" -rrust_ruby_example -e "puts RustRubyExample.reverse('Hello, world!')"
}

setup_ruby
setup_rust
upgrade_rubygems
build_example
