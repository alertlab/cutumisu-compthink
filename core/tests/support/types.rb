ParameterType(
      name:        'should',
      regexp:      /(should(?:[[:blank:]]+not)?)/,
      type:        TrueClass,
      transformer: lambda {|s| !s.match?('not')}
)

ParameterType(
      name:        'path',
      regexp:      %r[/(?:\S+/?)*],
      type:        Pathname,
      transformer: lambda do |str|
         Pathname.new(str)
      end
)

ParameterType(
      name:        'direction',
      regexp:      %r[(ascending|descending)],
      type:        String,
      transformer: lambda do |str|
         str
      end
)

ParameterType(
      name:        'error level',
      regexp:      %r[(message|warning|error)],
      type:        String,
      transformer: lambda {|str| str}
)


ParameterType(
      name:        'html element',
      regexp:      %r[<(\S+)>],
      type:        String,
      transformer: lambda {|str| str}
)


ParameterType(
      name:        'puzzle',
      regexp:      /levers?|hanoi/,
      type:        String,
      transformer: lambda {|s| s}
)

ParameterType(
      name:        'lever',
      regexp:      /[A-Z]/,
      type:        String,
      transformer: lambda {|s| s}
)

ParameterType(
      name:        'peg',
      regexp:      /[A-Z]/,
      type:        String,
      transformer: lambda {|s| s}
)

ParameterType(
      name:        'export data',
      regexp:      /clicks|users/,
      type:        String,
      transformer: lambda {|s| s}
)