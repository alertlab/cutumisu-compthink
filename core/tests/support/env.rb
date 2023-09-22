# frozen_string_literal: true

require 'simplecov'

SimpleCov.command_name 'core'

src_dir = File.expand_path('../../..', File.dirname(__FILE__))
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

require 'core/comp_think'
require 'persist/persist'
require 'timecop'
require 'pp' # needed to fix a conflict with FakeFS
require 'fakefs/safe'
require 'ostruct'

# require_relative './transformations'
require_relative 'hooks'
require_relative 'helpers'
require_relative 'mocks'

include CompThink
include CompThink::Interactor

World HelperMethods
