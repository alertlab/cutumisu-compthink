# frozen_string_literal: true

require 'rom'
require 'rom-sql'
require 'rom-repository'

# require ALL the repositories!
Dir["#{ Pathname.new(__dir__) }/repositories/**/*.rb"].each { |file| require file }

require 'persist/seeds'

# TODO: figure out how to auto load the default seed
# ROM.plant()
# ROM.replant(:demo)

module CompThink
   def self.build_persisters(invar)
      mysql_configs = invar / :configs / :mysql
      mysql_secrets = invar / :secrets / :mysql

      user = mysql_secrets / :user
      pass = mysql_secrets / :password
      host = mysql_configs / :host
      db   = mysql_configs / :database

      sql_uri = "mysql2://#{ user }:#{ pass }@#{ host }/#{ db }"

      migrations_path = Pathname.new(__dir__) / 'migrations'

      rom_container = ROM.container(default: [:sql, sql_uri, {migrator: {path: migrations_path}}]) do |config|
         config.auto_registration('./persist', namespace: 'CompThink::Persist')

         # Automatically run migrations on boot.
         # There is no situation where you'd want to run new code on an out-of-date database schema, if we regard the
         # code as the source of "correctness" (because it's tested).
         # (note: this is distinct from ROM's auto_migrate!, which might be better named auto_generate_migration)
         unless migrations_path.glob('*.rb').empty?
            config.gateways[:default].run_migrations(table: 'schema_migrations_dirt')
         end
      end

      {
            user:  UserRepository.new(rom_container),
            role:  RoleRepository.new(rom_container),
            click: ClickRepository.new(rom_container),
            group: GroupRepository.new(rom_container)
      }
   end
end
