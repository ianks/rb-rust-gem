# frozen_string_literal: true

require 'rake_compiler_dock'
require 'yaml'

GH_ACTION = YAML.safe_load(File.read('.github/workflows/build.yml'))
PLATFORMS = GH_ACTION.dig('strategy', 'matrix', 'platform')
RUBY_VERSIONS = GH_ACTION.dig('strategy', 'matrix', 'ruby_version')

namespace :native do
  desc 'Builds all docker images'
  task build: PLATFORMS.flat_map { |plat| RUBY_VERSIONS.map { |rv| "native:build:#{rv}:#{plat['ruby_target']}" } }

  namespace :build do
    PLATFORMS.each do |platform|
      ruby_arch = platform['ruby_target']
      rust_target_triple = platform['rust_target']

      RUBY_VERSIONS.each do |ruby_version|
        namespace ruby_version do
          desc "Builds docker image for #{ruby_arch}"
          task ruby_arch.to_s do
            cmd = <<~SH
              export RUST_TARGET="#{rust_target_triple}"
              export RUBY_TARGET="#{ruby_arch}"
              export RUST_TOOLCHAIN="stable"
              export RUBY_VERSION="#{ruby_version}"

              ./build.sh
            SH

            RakeCompilerDock.sh cmd, platform: ruby_arch
          end
        end
      end
    end
  end
end
