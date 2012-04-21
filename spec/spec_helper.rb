require 'rubygems'
require "bundler/setup"

ENV['RAILS_ENV'] ||= 'test'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rq_queue'
