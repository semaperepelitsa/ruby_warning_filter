# frozen_string_literal: true
require "delegate"
require "set"

# Filter IO from Ruby warnings that come out of external gems.
# There is no other way currently to filter out Ruby warnings other than hijacking stderr.
#
#   $VERBOSE = true
#   require "ruby_warning_filter"
#   $stderr = RubyWarningFilter.new($stderr)
#
# Number of occurred non-filtered warnings can be read with ruby_warnings:
#
#   $stderr.ruby_warnings #=> 0
#   @foo # warning: instance variable @foo not initialized
#   $stderr.ruby_warnings #=> 1
#
# The filter only overrides "write" method. This is OK since Ruby uses "write" internally
# when emitting warnings. Helper methods such as "puts", "print", "printf" will do native "write"
# bypassing the filter.
#
class RubyWarningFilter < DelegateClass(IO)
  attr_reader :ruby_warnings
  BACKTRACE = "\tfrom"
  RUBY_WARNING = %r{:(\d+|in `\S+'): warning:}
  EVAL_REDEFINED = /\(eval\):\d+: warning: previous definition of .+ was here/

  # Variables used in tag attributes (Slim) always cause a warning.
  # TODO: Report this.
  IGNORED_TEMPLATE_WARNING = %r{\.slim:\d+: warning: possibly useless use of a variable in void context$}

  # The source of this warning cannot be located so we have to ignore it completely
  # See example: https://github.com/deivid-rodriguez/pry-byebug/issues/221
  IGNORED_EVAL_WARNING = %r{^<main>:1: warning: .+ in eval may not return location in binding; use Binding#source_location instead$}

  def initialize(io, ignore_path: Gem.path)
    super(io)

    @ruby_warnings = 0
    @ignored = false

    # Gem path can contain symlinks.
    # Some warnings use real path instead of symlinks so we need to ignore both.
    ignore_full_path = ignore_path + ignore_path.select{ |a| File.exist?(a) }.map{ |a| File.realpath(a) }
    @ignore_regexp = Regexp.new("^(#{Regexp.union(ignore_full_path).source})")
  end

  def write(line)
    if @ignored && (line == "\n" || line.start_with?(BACKTRACE))
      # Ignore the whole backtrace after ignored warning.
      # Some warnings write newline separately for some reason.
      @ignored = true
      nil
    elsif @ignored && EVAL_REDEFINED.match?(line)
      # Some gems use eval to redefine methods and the second warning with the source does not have file path, so we need to ignore that explicitly.
      @ignored = false
      nil
    elsif RUBY_WARNING.match?(line)
      @ignored = IGNORED_TEMPLATE_WARNING.match?(line) ||
                 IGNORED_EVAL_WARNING.match?(line) ||
                 @ignore_regexp.match?(line)
      unless @ignored
        @ruby_warnings += 1
        super
      end
    else
      @ignored = false
      super
    end
  end
end
