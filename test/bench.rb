require "bundler/setup"
require_relative "../lib/ruby_warning_filter"
require "benchmark/ips"

file = File.new("/dev/null", "w")
filter = RubyWarningFilter.new(file, ignore_path: ["/path/to/gems"])

def write_errors(io)
  10.times do
    io.write("/path/to/gems/file.rb:297: warning: instance variable @object not initialized\n")
  end

  10.times do |i|
    io.write("\tfrom /something/foo/bar:#{i}:in  `<main>'")
  end

  10.times do
    io.write("(eval):1: warning: previous definition of foo was here")
  end
end


# Sample results in Ruby 2.3.1:
#
#          plain File     80.673k (± 2.5%) i/s -    410.454k in   5.091134s
#   RubyWarningFilter     11.934k (± 4.7%) i/s -     59.721k in   5.017126s
Benchmark.ips do |x|
  x.report "plain File" do
    write_errors(file)
  end

  x.report "RubyWarningFilter" do
    write_errors(filter)
  end
end


