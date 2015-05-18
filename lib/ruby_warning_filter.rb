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

  def initialize(io, ignore_path: Gem.path)
    super(io)

    @ruby_warnings = 0
    @ignored = false
    @ignore_path = ignore_path.to_set

    # Gem path can contain symlinks.
    # Some warnings use real path instead of symlinks so we need to ignore both.
    ignore_path.each do |a|
      @ignore_path << File.realpath(a) if File.exist?(a)
    end
  end

  def write(line)
    if @ignored && (backtrace?(line) || line == "\n")
      # Ignore the whole backtrace after ignored warning.
      # Some warnings write newline separately for some reason.
      @ignored = true
      nil
    elsif @ignored && eval_redefined?(line)
      # Some gems use eval to redefine methods and the second warning with the source does not have file path, so we need to ignore that explicitly.
      @ignored = false
      nil
    elsif ruby_warning?(line)
      @ignored = ignored_warning?(line)
      unless @ignored
        @ruby_warnings += 1
        super
      end
    else
      super
    end
  end

  private

  def ruby_warning?(line)
    line =~ %r{:(\d+|in `\S+'): warning:}
  end

  def ignored_warning?(line)
    external_warning?(line) || ignored_template_warning?(line)
  end

  def external_warning?(line)
    @ignore_path.any?{ |path| line.start_with?(path) }
  end

  # Variables used in tag attributes (Slim) always cause a warning.
  # TODO: Report this.
  def ignored_template_warning?(line)
    line =~ %r{\.slim:\d+: warning: possibly useless use of a variable in void context$}
  end

  def backtrace?(line)
    line.start_with?("\tfrom")
  end

  def eval_redefined?(line)
    line =~ /\(eval\):\d+: warning: previous definition of .+ was here/
  end
end
