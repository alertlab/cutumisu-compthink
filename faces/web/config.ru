# frozen_string_literal: true

require 'rubygems'

require_relative 'sinatra/server'

require_relative 'localhost_shim'

Localhost::Authority::DEFAULT_HOSTNAME = 'compthink.local'

# Time to wake up, little one. There's science to be done.
run CompThink::WebFace::Server
