# frozen_string_literal: true

require 'yaml'

RCD_TAG = '1.2.1'
BUILDS = YAML.safe_load(File.read('builds.yaml'))
PLATFORMS = BUILDS.dig('platforms')
DOCKERFILES = Dir['docker/Dockerfile.*']
DOCKERFILE_PLATFORMS = DOCKERFILES.map { |f| File.extname(f).gsub('.', '') }
DOCKERFILE_PLATFORM_PAIRS = DOCKERFILES.zip(DOCKERFILE_PLATFORMS)
DOCKER = ENV.fetch('RBSYS_DOCKER', 'docker')

desc 'Pretty the code'
task :fmt do
  sh 'shfmt -i 2 -w -ci -sr ./docker/setup'
  sh 'rubocop -A Rakefile'
end

namespace :docker do
  DOCKERFILE_PLATFORM_PAIRS.each do |pair|
    dockerfile, arch = pair

    namespace :build do
      desc 'Build docker image for %s' % arch
      task arch do
        sh "#{DOCKER} build #{ENV['RBSYS_DOCKER_BUILD_EXTRA_ARGS']} -f #{dockerfile} --build-arg RCD_TAG=#{RCD_TAG} --tag rbsys/rcd:#{arch} --tag rbsys/rake-compiler-dock-mri-#{arch}:#{RCD_TAG} ./docker"
      end
    end

    namespace :sh do
      desc 'Shell into docker image for %s' % arch
      task arch do
        system "docker run --rm --privileged --entrypoint /bin/bash -it rbsys/rcd:#{arch}"
      end
    end
  end

  desc 'Build docker images for all platforms'
  task build: DOCKERFILE_PLATFORMS.map { |p| "build:#{p}" }

  DOCKERFILE_PLATFORMS.each do |arch|
    task "push:#{arch}" do
      sh "docker push rbsys/rake-compiler-dock-mri-#{arch}:#{RCD_TAG}"
      sh "docker push rbsys/rcd:#{arch}"
    end
  end

  desc 'Push docker images for all platforms'
  task push: DOCKERFILE_PLATFORMS.map { |p| "push:#{p}" }

  desc 'Generate DOCKERFILES'
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
            PATH="/usr/local/cargo/bin:$PATH" \\
            LIBCLANG_PATH="" \\
            BINDGEN_EXTRA_CLANG_ARGS="#{plat['bindgen_extra_clang_args']}"

        COPY setup/lib.sh /lib.sh

        COPY setup/rubybashrc.sh /
        RUN /rubybashrc.sh

        COPY setup/rustup.sh /
        RUN /rustup.sh x86_64-unknown-linux-gnu $RUST_TARGET $RUST_TOOLCHAIN

        COPY setup/rubygems.sh /
        RUN /rubygems.sh

        RUN source /lib.sh && install_packages llvm-toolset-7 libclang-dev clang llvm-dev libc6-arm64-cross libc6-dev-arm64-cross
      EOS
    end
  end
end
