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
#          plain File     75.140k (± 4.3%) i/s -    374.952k in   5.000983s
#   RubyWarningFilter     40.768k (± 4.6%) i/s -    205.377k in   5.050529s
Benchmark.ips do |x|
  x.report "plain File" do
    write_errors(file)
  end

  x.report "RubyWarningFilter" do
    write_errors(filter)
  end
end


