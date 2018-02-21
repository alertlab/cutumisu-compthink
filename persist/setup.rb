require 'rom'
require 'rom-sql'
require 'rom-repository'

# require ALL the repositories!
Dir["#{ Pathname.new(__dir__) }/repositories/**/*.rb"].each {|file| require file}

module CompThink
   def self.build_persistence_environment
      user = ENV['app_db_user']
      pass = ENV['app_db_pass']
      host = ENV['app_db_host']
      db   = ENV['app_db_name']

      sql_uri = "mysql2://#{ user }:#{ pass }@#{ host }/#{ db }"

      ROM.container(default: [:sql, sql_uri]) do |config|
         config.auto_registration(__dir__, namespace: 'CompThink::Persist')
      end
   end

   def self.build_persisters(rom_container)
      {
            user:  UserRepository.new(rom_container),
            role:  RoleRepository.new(rom_container),
            click: ClickRepository.new(rom_container),
            group: GroupRepository.new(rom_container)
      }
   end
end
