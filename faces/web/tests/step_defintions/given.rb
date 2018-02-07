require 'core/tests/step_definitions/given/user_given'
require 'core/tests/step_definitions/given/time_given'

Given(/^"(.*?)" is signed in$/) do |first_name|
   step(%["#{ first_name }" signs in])
end

Given(/^"(.*?)" has password "(.*?)"$/) do |user_name, password|
   user     = @persisters[:user].find(first_name: user_name)

   password = 'sekret' if password.blank?

   auth = CompThink::Model::UserAuthentication.new(user_id:  user.id,
                                                   password: password)

   @persisters[:user].create_auth(auth.to_hash)
end

Given(/^"(.*?)" is at "(.*?)"$/) do |user_name, path|
   step(%["#{ user_name }" is signed in])

   visit(path)

   wait_for_ajax
end

# Given (/^the browser date is "(.*?)"$/) do |date_string|
#    page.evaluate_script(%q[
#       console.warn('Stubbing date.');
#
#       window.__RealDate = window.Date;
#       window.Date = function () {
#          var args, date;
#
#          // console.log('Using stubbed date.');
#          args = Array.prototype.slice.call(arguments);
#
#          date = eval('new __RealDate(' + args.join(',') + ')');
#
#          if (arguments.length == 0) {
#             date.setFullYear(date.getFullYear(), 5, 7); // June 7
#          }
#
#          return date;
#       };
#    ])
# end
