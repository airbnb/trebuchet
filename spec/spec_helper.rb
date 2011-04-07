$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'bundler'

# Bundler breaks things
#Bundler.require :default, :development

require 'trebuchet'
require 'user'
