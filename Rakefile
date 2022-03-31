# frozen_string_literal: true

require "yaml"

RCD_TAG = "1.2.1"
BUILDS = YAML.safe_load(File.read("builds.yaml"))
PLATFORMS = BUILDS.dig("platforms")
DOCKERFILES = Dir["docker/Dockerfile.*"]
DOCKERFILE_PLATFORMS = DOCKERFILES.map { |f| File.extname(f).delete(".") }
DOCKERFILE_PLATFORM_PAIRS = DOCKERFILES.zip(DOCKERFILE_PLATFORMS)
DOCKER = ENV.fetch("RBSYS_DOCKER", "docker")

desc "Pretty the code"
task :fmt do
  sh "shfmt -i 2 -w -ci -sr ./docker/setup"
  sh "standardrb --fix $(git ls-files '*.rb' '*Rakefile')"
end

def run_gh_workflow(file_name)
  require "json"
  require "yaml"

  workflow = YAML.load(File.read(file_name))

  sh "gh workflow run \"#{workflow["name"]}\" && sleep 3"
  id = JSON.parse(`gh run list --workflow=#{File.basename(file_name)} --limit=1 --json="databaseId"`).first["databaseId"]
  system "gh run watch #{id}"
  sh "osascript -e 'display notification \"#{workflow["name"]} workflow finished (#{id})\" with title \"GitHub Workflow\"'"
rescue Interrupt
  sh "gh run cancel #{id}"
end

desc "Build the native gems on github"
task ".github/workflows/build.yml" do |t, _args|
  run_gh_workflow t.name
end

desc "Build the docker images on github"
task ".github/workflows/docker.yml" do |t, _args|
  run_gh_workflow t.name
end

namespace :docker do
  DOCKERFILE_PLATFORM_PAIRS.each do |pair|
    dockerfile, arch = pair

    namespace :build do
      desc "Build docker image for %s" % arch
      task arch do
        sh "#{DOCKER} build #{ENV["RBSYS_DOCKER_BUILD_EXTRA_ARGS"]} -f #{dockerfile} --build-arg RCD_TAG=#{RCD_TAG} --tag rbsys/rcd:#{arch} --tag rbsys/rake-compiler-dock-mri-#{arch}:#{RCD_TAG} ./docker"
      end
    end

    namespace :sh do
      desc "Shell into docker image for %s" % arch
      task arch do
        system "docker run --rm --privileged --entrypoint /bin/bash -it rbsys/rcd:#{arch}"
      end
    end
  end

  desc "Build docker images for all platforms"
  task build: DOCKERFILE_PLATFORMS.map { |p| "build:#{p}" }

  DOCKERFILE_PLATFORMS.each do |arch|
    desc "Push #{arch} docker image"
    task "push:#{arch}" => "build:#{arch}" do
      sh "docker push rbsys/rake-compiler-dock-mri-#{arch}:#{RCD_TAG}"
      sh "docker push rbsys/rcd:#{arch}"
    end
  end

  desc "Push docker images for all platforms"
  task push: DOCKERFILE_PLATFORMS.map { |p| "push:#{p}" }
end

DOCKERFILE_PLATFORMS.each do |arch|
  desc "Build native gem for #{arch}"
  task "gem:native:#{arch}" do
    Dir.chdir "examples/rust_ruby_example" do
      sh "rake gem:native:#{arch}"
    end
  end
end
