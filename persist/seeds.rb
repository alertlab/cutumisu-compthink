#!/usr/bin/env ruby

src_dir = File.expand_path('..', __dir__)
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

require 'core/comp_think'
require 'persist/setup'
require 'persist/garden/garden'
require 'yaml'

module Garden
   def self.build_seeder(env, persisters)
      SeedGarden.new(env, persisters) do |seed_bag|
         seed_bag.define_seed(:default) do |garden|
            garden.persisters[:role].create(name: 'admin')
            garden.persisters[:role].create(name: 'instructor')
         end

         seed_bag.define_seed(:production_data) do |garden|
            garden.replant(:default)
            garden.plant(:production_users)
         end

         seed_bag.define_seed(:production_users) do |garden|
            user_persister = garden.persisters[:user]
            role_persister = garden.persisters[:role]

            admin_data = YAML.load_file('persist/seed_secrets.yml')['admin']

            admin_role = garden.persisters[:role].role_with(name: 'admin')

            auth_hash = CompThink::Model::UserAuthentication.encrypt(admin_data['password'])

            admin = user_persister.create_with_auth(first_name:           'Alert',
                                                    last_name:            'Lab',
                                                    email:                admin_data[:email] || 'alertlab@exmaple.com',
                                                    user_authentications: {
                                                          encrypted_password: auth_hash
                                                    })

            # tenjin_hash = user_persister.create(first_name: 'Tenjin', last_name: 'Inc',
            #                                        email:      'tenjin@example.com')

            role_persister.assign_role(user: admin, role: admin_role)
         end

         seed_bag.define_seed(:demo_users) do |garden|
            user_persister = garden.persisters[:user]
            role_persister = garden.persisters[:role]

            admin_role = role_persister.role_with(name: 'admin')
            # guest_role = role_persister.role_with(name: 'admin')

            auth_hash = CompThink::Model::UserAuthentication.encrypt('sekret')

            userA = user_persister.create_with_auth(first_name:           'Kelly',
                                                    last_name:            'Myers',
                                                    email:                'kelly@example.com',
                                                    user_authentications: {
                                                          encrypted_password: auth_hash
                                                    })
            userB = user_persister.create_with_auth(first_name:           'Allan',
                                                    last_name:            'Daniels',
                                                    email:                'allan@example.com',
                                                    user_authentications: {
                                                          encrypted_password: auth_hash
                                                    })

            role_persister.assign_role(user: userA, role: admin_role)
            # role_persister.assign_role(user: userB, role: guest_role)
         end

         seed_bag.define_seed(:demo) do |garden|
            garden.plant(:production_data)
            garden.plant(:demo_users)
         end
      end
   end
end

# ==============================
# Main
#
# To purge the data and reset, run this file with:
#    bundle exec ruby persist/seed.rb <seedname>
# ==============================
if $PROGRAM_NAME == __FILE__
   begin
      env        = CompThink.build_persistence_environment
      persisters = CompThink.build_persisters(env)

      garden = Garden.build_seeder(env, persisters)

      garden.replant(ARGV[0].to_sym)
   rescue Garden::SeedError => e
      puts e.message
      return 1
   end
end
