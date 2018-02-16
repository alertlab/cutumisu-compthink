ParameterType(
      name:        'should',
      regexp:      /(should(?:[[:blank:]]+not)?)/,
      type:        TrueClass,
      transformer: lambda do |s|
         !s.match?('not')
      end
)

ParameterType(
      name:        'lever',
      regexp:      /[A-Z]/,
      type:        String,
      transformer: lambda {|s| s}
)