require 'mkmf'
require 'rubygems/ext'
require 'rubygems/ext/cargo_builder'

dest_path = __dir__
results = []
args = []
lib_dir = __dir__
cargo_dir = File.expand_path('../..', __dir__)
puts cargo_dir
spec = Struct.new(:name, :metadata).new('rust_ruby_example', {})
begin
  Gem::Ext::CargoBuilder.new(spec).build(nil, dest_path, results, args, lib_dir, cargo_dir)
rescue StandardError => e
  puts results
  raise
end

File.write('Makefile', dummy_makefile(__dir__))
