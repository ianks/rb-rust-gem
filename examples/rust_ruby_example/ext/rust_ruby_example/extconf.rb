require 'mkmf'
require 'rubygems/ext'
require 'rubygems/ext/cargo_builder'

target = "rust_ruby_example"
dest_path = File.join( Dir.pwd, "target")
results = []
args = []
lib_dir = Dir.pwd 
cargo_dir = File.expand_path('../..', __dir__)
spec = Struct.new(:name, :metadata).new(target, {})

begin
  Gem::Ext::CargoBuilder.new(spec).build(nil, dest_path, results, args, lib_dir, cargo_dir)
rescue StandardError => e
  puts results
  raise
end

make_install = <<~EOF
  target_prefix = /#{target}

  TARGET = #{target}
  DLLIB = $(TARGET).bundle
  RUBYARCHDIR   = $(sitearchdir)$(target_prefix)
  CLEANLIBS = release/

  #{dummy_makefile(__dir__).join("\n").gsub("all install static install-so install-rb", "all static install-so install-rb")}

  install: $(DLLIB)
  \t$(INSTALL_PROG) $(DLLIB) $(RUBYARCHDIR)
EOF

File.write('Makefile', make_install)
