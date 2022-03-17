# frozen_string_literal: true

require 'yaml'

GH_ACTION = YAML.safe_load(File.read('.github/workflows/build.yml'))
PLATFORMS = GH_ACTION.dig('jobs', 'build', 'strategy', 'matrix', 'platform')

namespace :docker do
  desc 'Build docker images'
  task :build do
    Dir['docker/Dockerfile.*'].each do |file|
      arch = File.extname(file).gsub('.', '')
      sh "docker build -f #{file} --tag rbsys/rake-compiler-dock-mri-#{arch}:0.1.0 ."
    end
  end

  task :push do
    Dir['docker/Dockerfile.*'].each do |file|
      arch = File.extname(file).gsub('.', '')
      sh "docker push rbsys/rake-compiler-dock-mri-#{arch}:0.1.0"
    end
  end

  desc 'Generate dockerfiles'
  task :codegen do
    PLATFORMS.each do |plat|
      if File.exist?("docker/Dockerfile.#{plat['ruby_target']}")
        puts "Skip docker/Dockerfile.#{plat['ruby_target']}"
        next 
      else
        puts "Generate docker/Dockerfile.#{plat['ruby_target']}"
      end

      File.write "docker/Dockerfile.#{plat['ruby_target']}", <<~EOS
        FROM larskanis/rake-compiler-dock-mri-#{plat['ruby_target']}:1.2.0

        ENV RUBY_TARGET="#{plat['ruby_target']}" \\
            RUST_TARGET="#{plat['rust_target']}" \\
            RUST_TOOLCHAIN="stable" \\
            BINDGEN_EXTRA_CLANG_ARGS="#{plat['bindgen_extra_clang_args']}" \\
            PKG_CONFIG_ALLOW_CROSS="1" \\
            RUSTUP_HOME="/usr/local/rustup" \\
            CARGO_HOME="/usr/local/cargo" \\
            PATH="/usr/local/cargo/bin:$PATH"

        RUN set -eux; \\
            echo "export PATH=/usr/local/cargo/bin:\\$PATH" >> /etc/rubybashrc; \\
            echo "export RUSTUP_HOME=\\"$RUSTUP_HOME\\"" >> /etc/rubybashrc; \\
            echo "export CARGO_HOME=\\"$CARGO_HOME\\"" >> /etc/rubybashrc; \\
            echo "export RUBY_TARGET=\\"$RUBY_TARGET\\"" >> /etc/rubybashrc; \\
            echo "export RUST_TARGET=\\"$RUST_TARGET\\"" >> /etc/rubybashrc; \\
            echo "export RUST_TOOLCHAIN=\\"$RUST_TOOLCHAIN\\"" >> /etc/rubybashrc; \\
            echo "export BINDGEN_EXTRA_CLANG_ARGS=\\"$BINDGEN_EXTRA_CLANG_ARGS\\"" >> /etc/rubybashrc; \\
            echo "export PKG_CONFIG_ALLOW_CROSS=\\"$PKG_CONFIG_ALLOW_CROSS\\"" >> /etc/rubybashrc; \\
            echo "export LIBCLANG_PATH=\\"$LIBCLANG_PATH\\"" >> /etc/rubybashrc; \\
            echo "export CARGO_BUILD_TARGET=\\"$RUST_TARGET\\"" >> /etc/rubybashrc;

        RUN set -eux; \\
            url="https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init"; \\
            curl --retry 3 --proto '=https' --tlsv1.2 -sSf "$url" > rustup-init; \\
            chmod +x rustup-init; \\
            ./rustup-init --no-modify-path --default-toolchain "$RUST_TOOLCHAIN" --profile minimal -y; \\
            rm rustup-init; \\
            chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \\
            rustup --version; \\
            cargo --version; \\
            rustc --version; \\
            rustup target add #{plat['rust_target']};

        RUN set -eux; \\
            git clone --single-branch --branch cargo-builder-target --depth 1 https://github.com/ianks/rubygems /tmp/rubygems; \\
            cd /tmp/rubygems; \\
            bash -c "ruby setup.rb"; \\
            rm -rf /tmp/rubygems;
      EOS
    end