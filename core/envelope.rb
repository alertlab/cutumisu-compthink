# TODO: extract to a gem, and TDD it
class MissingEnv < StandardError
end

def expect_env(key)
   prefix = 'app_'

   key    = prefix + key unless key.start_with?(prefix)

   return if ENV[key]

   $stderr.puts "WARNING: Missing expected ENV variable #{ key }. Program may fail if running in full operation."
end

def require_env(key)
   prefix = 'app_'

   key    = prefix + key unless key.start_with?(prefix)

   return if ENV[key]

   app_vars = ENV.select do |k, v|
      k.start_with? prefix
   end

   raise(MissingEnv, "You must provide app environment variable '#{ key }'. Variables provided: #{ app_vars }")
end