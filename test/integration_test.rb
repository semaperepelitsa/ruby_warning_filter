require "minitest/autorun"
require "tempfile"

class IntegrationTest < Minitest::Test
  GEM_PATH = File.expand_path("#{__dir__}/gems")
  GEM_PREFIX = File.join(GEM_PATH, "gems/bad_example-100/lib/bad_example")

  LIB = File.expand_path("#{__dir__}/../lib")
  CODE = <<-RUBY.gsub("\n", "; ")
$VERBOSE = true
require "ruby_warning_filter"
$stderr = RubyWarningFilter.new($stderr)
RUBY

  def test_custom
    assert_equal "Custom warning\n",
      ruby(CODE, 'warn "Custom warning"')
  end

  def test_internal
    assert_equal "-e:2: warning: instance variable @foo not initialized\n",
      ruby(CODE, 'true if @foo')
  end

  def test_external_non_filtered
    assert_equal <<-END, ruby('require "bad_example/basic"')
#{GEM_PREFIX}/basic.rb:1: warning: assigned but unused variable - foo
#{GEM_PREFIX}/basic.rb:2: warning: instance variable @foo not initialized
END
  end

  def test_external
    assert_equal "", ruby(CODE, 'require "bad_example/basic"')
  end

  def test_with_backtrace
    skip "Pending"
  end

  def test_eval_redefined
    skip "Pending"
  end

  def ruby(*lines)
    IO.pipe do |rd, wr|
      success = system({ "GEM_PATH" => GEM_PATH }, "ruby", "-w", "-I", LIB, "-e", lines.join("\n"), :err => wr)
      wr.close
      out = rd.read
      if success
        out
      else
        raise out
      end
    end
  end
end
