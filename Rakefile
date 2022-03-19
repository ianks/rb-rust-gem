# frozen_string_literal: true

require 'yaml'

BUILDS = YAML.safe_load(File.read('builds.yaml'))
PLATFORMS = BUILDS.dig('platforms')
RCD_TAG = "1.2.0"

namespace :docker do
  dockerfiles = Dir['docker/Dockerfile.*']
  archs = dockerfiles.map { |f| File.extname(f).gsub('.', '') }
  pairs = dockerfiles.zip(archs)

  pairs.each do |pair|
    dockerfile, arch = pair

    namespace :build do
      desc 'Build docker image for %s' % arch
      task arch do
        sh "docker build -f #{dockerfile} --build-arg RCD_TAG=#{RCD_TAG} --tag rbsys/rake-compiler-dock-mri-#{arch}:#{RCD_TAG} ./docker"
        sh "docker image tag rbsys/rake-compiler-dock-mri-#{arch}:#{RCD_TAG} rbsys/rcd:#{arch}"
      end
    end

    namespace :sh do
      desc 'Shell into docker image for %s' % arch 
      task arch do
        system "docker run --rm --privileged --entrypoint /bin/bash -it rbsys/rcd:#{arch}"
      end
    end
  end

  desc "Build docker images for all platforms"
  task build: pairs.map { |pair| "build:#{pair.last}" }

  task :push do
    Dir['docker/Dockerfile.*'].each do |file|
      arch = File.extname(file).gsub('.', '')
      sh "docker push rbsys/rake-compiler-dock-mri-#{arch}:#{RCD_TAG}"
      sh "docker push rbsys/rcd:#{arch}"
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
        FROM larskanis/rake-compiler-dock-mri-#{plat['ruby_target']}:#{RCD_TAG}

        ENV RUBY_TARGET="#{plat['ruby_target']}" \\
            RUST_TARGET="#{plat['rust_target']}" \\
            RUST_TOOLCHAIN="stable" \\
            PKG_CONFIG_ALLOW_CROSS="1" \\
            RUSTUP_HOME="/usr/local/rustup" \\
            CARGO_HOME="/usr/local/cargo" \\
            PATH="/usr/local/cargo/bin:$PATH"

        COPY setup/lib.sh /lib.sh

        COPY setup/rubybashrc.sh /
        RUN /rubybashrc.sh

        COPY setup/rustup.sh /
        RUN /rustup.sh x86_64-unknown-linux-gnu $RUST_TARGET $RUST_TOOLCHAIN

        COPY setup/rubygems.sh /
        RUN /rubygems.sh

        RUN source /lib.sh && install_packages llvm-toolset-7 libclang-dev clang llvm-dev libc6-arm64-cross libc6-dev-arm64-cross

        ENV LIBCLANG_PATH="" \
            BINDGEN_EXTRA_CLANG_ARGS="#{plat['bindgen_extra_clang_args']}"
      EOS
    end
  end
end