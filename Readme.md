# Hassle-free Ruby warnings

Ruby warnings are cool. They prevent you from making typos in instance variables, making unused variables, accidentally overriding methods, and more. Unfortunately, many libraries still don’t check their code for warnings. In a big enough project you end up with tons of warnings from all the libraries you use which renders the whole thing useless. But it doesn’t have to be this way!

With the help of this gem you can filter out all those useless messages and only get the warnings relevant to your code.

## Usage

Add to your Gemfile:

```ruby
gem "ruby_warning_filter", "~> 1.0.0"
```

Put the following code somewhere before your project is loaded. In a Rails application, a good place would be at the end of "config/boot.rb".

```ruby
$VERBOSE = true
require "ruby_warning_filter"
$stderr = RubyWarningFilter.new($stderr)
```

When running your app or tests you should see only relevant warnings. Now, go fix them!

## Feedback

[![Build Status](https://travis-ci.org/semaperepelitsa/ruby_warning_filter.svg?branch=master)](https://travis-ci.org/semaperepelitsa/ruby_warning_filter)

The filter works by proxying all writes to stderr. It has been running for a while in many of my work projects with good results. However, it is probably not comprehensive. Please, report any warnings that it misses or swallows by error.
