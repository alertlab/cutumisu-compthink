# frozen_string_literal: true

ParameterType(name:        'should',
              regexp:      /(should(?:[[:blank:]]+not)?)/,
              type:        TrueClass,
              transformer: ->(s) { !s.match?('not') })

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

ParameterType(name:        'puzzle',
              regexp:      /levers?|hanoi/,
              type:        String,
              transformer: ->(s) { s })

ParameterType(name:        'lever',
              regexp:      /[A-Z]/,
              type:        String,
              transformer: ->(s) { s })

ParameterType(name:        'peg',
              regexp:      /[A-Z]/,
              type:        String,
              transformer: ->(s) { s })

ParameterType(name:        'export data',
              regexp:      /clicks|users/,
              type:        String,
              transformer: ->(s) { s })
