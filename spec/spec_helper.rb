require 'rubygems'
require "bundler/setup"

ENV['RAILS_ENV'] ||= 'test'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'sk_queue'

require File.dirname(__FILE__) + '/test_class'
require File.dirname(__FILE__) + '/test_class2'
