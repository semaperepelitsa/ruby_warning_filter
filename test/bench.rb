require "bundler/setup"
require_relative "../lib/ruby_warning_filter"
require "benchmark/ips"

file = File.new("/dev/null", "w")
filter = RubyWarningFilter.new(file, ignore_path: ["/path/to/gems"])

def write_errors(io)
  10.times do
    io.write("/path/to/gems/file.rb:297: warning: instance variable @object not initialized\n")
  end

  7.times do |i|
    io.write("\tfrom /something/foo/bar:#{i}:in  `<main>'")
    io.write("\n")
  end

  7.times do
    io.write("(eval):1: warning: previous definition of foo was here")
    io.write("\n")
  end
end


# Sample results in Ruby 2.3.1:
#
#          plain File     81.435k (± 2.5%) i/s -    411.632k in   5.057905s
#   RubyWarningFilter     41.323k (± 2.5%) i/s -    210.236k in   5.090913s
Benchmark.ips do |x|
  x.report "plain File" do
    write_errors(file)
  end

  x.report "RubyWarningFilter" do
    write_errors(filter)
  end
end
