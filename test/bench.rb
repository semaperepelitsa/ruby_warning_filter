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
#          plain File     78.633k (± 2.0%) i/s -    393.692k in   5.008743s
#   RubyWarningFilter     39.980k (± 3.4%) i/s -    200.889k in   5.031314s
Benchmark.ips do |x|
  x.report "plain File" do
    write_errors(file)
  end

  x.report "RubyWarningFilter" do
    write_errors(filter)
  end
end


