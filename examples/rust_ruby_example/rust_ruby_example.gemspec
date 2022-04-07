Gem::Specification.new do |s|
  s.name = "rust_ruby_example"
  s.version = "0.1.0"
  s.summary = "A Rust extension for Ruby"
  s.extensions = ["Cargo.toml"]
  s.authors = ["Ian Ker-Seymer"]
  s.files = ["Cargo.toml", "Cargo.lock", "src/lib.rs"]
  s.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com"
  s.metadata["github_repo"] = "git@github.com:ianks/rb-rust-gem.git"
end
