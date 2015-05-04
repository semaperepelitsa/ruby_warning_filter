Gem::Specification.new do |gem|
  gem.name    = "ruby_warning_filter"
  gem.version = "1.0.0"
  gem.summary = "Get only relevant verbose Ruby warnings."
  gem.license = "MIT"
  gem.author  = "Semyon Perepelitsa"
  gem.email   = "sema@sema.in"

  gem.files = File.read("Manifest.txt").split("\n")
  gem.test_files = gem.files.grep(%r{^test/})
end
