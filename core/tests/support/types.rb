# frozen_string_literal: true

ParameterType(name:        'path',
              regexp:      %r{/(?:\S+/?)*},
              type:        Pathname,
              transformer: lambda do |str|
                 Pathname.new(str)
              end)

ParameterType(name:        'direction',
              regexp:      /(ascending|descending)/,
              type:        String,
              transformer: lambda do |str|
                 str
              end)

ParameterType(name:        'error level',
              regexp:      /(message|warning|error)/,
              type:        String,
              transformer: lambda { |str|
                 str = "#{ str }s" unless str.end_with?('s')

                 str.to_sym
              })

ParameterType(name:        'html element',
              regexp:      /<(\S+)>/,
              type:        String,
              transformer: ->(str) { str })
