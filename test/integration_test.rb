require "minitest/autorun"
require "tempfile"

class IntegrationTest < Minitest::Test
  LIB = File.expand_path("#{__dir__}/../lib")
  CODE = <<-RUBY
require "bundler/setup"
$VERBOSE = true
require "ruby_warning_filter"
$stderr = RubyWarningFilter.new($stderr)
RUBY

  def test_custom
    assert_equal "Custom warning\n",
      ruby(CODE, 'warn "Custom warning"')
  end

  def test_internal
    assert_equal "-e:6: warning: instance variable @foo not initialized\n",
      ruby(CODE, '@foo')
  end

  def test_external
    skip "Pending"
  end

  def test_with_backtrace
    skip "Pending"
  end

  def test_eval_redefined
    skip "Pending"
  end

  def ruby(*lines)
    IO.pipe do |rd, wr|
      system "ruby", "-I", LIB, "-e", lines.join("\n"), :err => wr
      wr.close
      rd.read
    end
  end
end
