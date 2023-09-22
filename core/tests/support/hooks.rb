# frozen_string_literal: true

require_relative 'helpers'
require 'invar/test'
require 'bcrypt'
require 'database_cleaner/sequel'

# =========================
#       Untagged Hooks
# =========================
#
# Hooks that are run for every scenario across all test suites (ie. core and faces).
# Face-specific hooks go in tests/support/hooks.rb in that face's directory.
##

# Cannot be nested in a BeforeAll hook, because the web face needs it loaded immediately before the server file is even
# loaded; due to the structure of Sinatra, it reads from invar config during class definition
Invar.after_load do |reality|
   reality[:configs][:mysql].pretend database: 'compthink_test'
   reality[:configs][:core].pretend log_dir: HelperMethods::TEST_TMP_LOG.to_s
end

# BeforeAll is one-time prior to the very first scenario.
BeforeAll name: 'Faster BCrypt' do
   # Disable bcrypt folding to speed up tests.
   BCrypt::Engine.cost = 1
end

Before name: 'Clear tmpdir' do
   # Reversing the list allows it to delete the deepest child nodes first and then it can delete the now-empty dirs
   HelperMethods::TEST_TMP_ROOT.glob('**/*').reverse.each(&:delete)
end

Before name: 'Reseed' do
   env        = persisters[:user].container
   connection = env.gateways[:default].connection

   db_name = connection.opts[:database]

   # Only clean databases ending with '_test'.
   # Not using `DatabaseCleaner.url_allowlist` because it only checks against env variable DATABASE_URL, not the
   # the actual connection names, which isn't as flexible.
   unless db_name.end_with? '_test'
      raise "[Reseed hook] Safety catch: Database name must end with '_test' but got #{ db_name }"
   end

   DatabaseCleaner[:sequel, db: connection]

   DatabaseCleaner.strategy = :deletion, {except: %w[schema_migrations sequel_schema_migrations]}

   DatabaseCleaner.clean
end

After name: 'Reset Timecop' do
   Timecop.return
end

After name: 'Reset FakeFS' do
   FakeFS.deactivate!
end

# After the very last scenario.
#   AfterAll do end

# =========================
#       Tagged Hooks
# =========================
#
# Hooks that should run for only the tag-matching scenarios.
# https://cucumber.io/docs/cucumber/api/?lang=ruby#hooks
# https://cucumber.io/docs/cucumber/api/?lang=ruby#tags
##

Before '@fakefs', name: 'Engage FakeFS' do
   FakeFS.activate!
   FakeFS::FileSystem.clear

   # need to create the file or else Logger will try to and that breaks under FakeFS
   FileUtils.mkdir_p('/dev/')
   FileUtils.touch('/dev/null')
   # FileUtils.mkdir_p(CORE_LOG_FILE_PATH.dirname)
   # FileUtils.touch(CORE_LOG_FILE_PATH)

   container.logger.reopen
end

After '@fakefs' do
   FakeFS.deactivate!
end
