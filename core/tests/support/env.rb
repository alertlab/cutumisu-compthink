# frozen_string_literal: true

src_dir = File.expand_path('../../..', File.dirname(__FILE__))
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

require 'core/comp_think'
require 'persist/persist'

require 'pp' # needed to fix a conflict with FakeFS

Bundler.require :test_core
require_relative 'hooks'
require_relative 'helpers'
require_relative 'mocks'

# Disabling because it's much more legible in steps
# rubocop:disable Style/MixinUsage
include CompThink
include CompThink::Command
# rubocop:enable Style/MixinUsage

World HelperMethods
