# frozen_string_literal: true

require 'rubygems'
require 'sinatra'

require_relative 'sinatra/server'

# Time to wake up, little one. There's science to be done.
run CompThink::WebFace::Server
