Gem::Specification.new do |gem|
  gem.name    = "ruby_warning_filter"
  gem.version = "1.0.1"
  gem.summary = "Hassle-free Ruby warnings"
  gem.license = "MIT"
  gem.author  = "Semyon Perepelitsa"
  gem.email   = "sema@sema.in"

  gem.homepage = "https://github.com/semaperepelitsa/ruby_warning_filter"

  gem.files = File.read("Manifest.txt").split("\n")
  gem.test_files = gem.files.grep(%r{^test/})
end
