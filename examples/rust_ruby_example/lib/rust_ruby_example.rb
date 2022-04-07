# frozen_string_literal: true

begin
  RUBY_VERSION =~ /(\d+\.\d+)/
  require "#{$1}/rust_ruby_example"
rescue LoadError
  require "rust_ruby_example"
end