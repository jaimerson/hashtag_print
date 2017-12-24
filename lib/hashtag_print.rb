$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)
require 'rubygems'
require 'bundler/setup'

Bundler.setup(:default)

require 'watir'
require 'pry'

module HashtagPrint
  ROOT_PATH = File.join(__dir__, '..')
end

require 'hashtag_print/document'
require 'hashtag_print/instagram'
require 'hashtag_print/renderer'
require 'hashtag_print/listener'
