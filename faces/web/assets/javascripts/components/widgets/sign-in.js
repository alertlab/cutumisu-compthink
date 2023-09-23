ko.components.register('sign-in', {
   template: '<h2 data-bind="text: titleText"></h2>\
              <form data-bind="submit: signIn">\
                 <ul data-bind="visible: isAdmin">\
                    <li>\
                       <label>\
                          <span>Email</span>\
                          <input type="email" name="email" placeholder="eg. jdoe@example.com" data-bind="value: email" />\
                       </label>\
                    </li>\
                    <li>\
                       <label>\
                          <span>Password</span>\
                          <input-password params="password: password"></input-password>\
                       </label>\
                    </li>\
                 </ul>\
                 <ul data-bind="visible: !isAdmin">\
                    <li>\
                       <label>\
                          <span>Group</span>\
                          <input type="text" name="group" data-bind="value: group" />\
                       </label>\
                    </li>\
                    <li>\
                       <label>\
                          <span>Username</span>\
                          <input type="text" name="username" data-bind="value: username" />\
                       </label>\
                    </li>\
                 </ul>\
                 <button type="submit"><span data-bind="text: buttonText"></span></button>\
              </form>',

   viewModel: function () {
      var self = this;

      self.user = window.currentUser;

      self.email = ko.observable('');
      self.password = ko.observable('');

      self.group = ko.observable().extend({
         storage: {
            type: 'query',
            key: 'group'
         }
      });
      self.username = ko.observable();

      self.isAdmin = !!(window.location.pathname.match(/^\/admin/) || window.location.search.match(/\?uri=%2Fadmin/));

      self.titleText = ko.pureComputed(function () {
         return self.isAdmin ? 'Admin Sign In' : 'Hello';
      });

      self.buttonText = ko.pureComputed(function () {
         return self.isAdmin ? 'Sign In' : 'Go!'
      });

      self.signIn = function () {
         var data;

         if (self.isAdmin)
            data = {
               admin: {
                  email: self.email(),
                  password: self.password()
               }
            };
         else
            data = {
               user: {
                  group: self.group(),
                  username: self.username()
               }
            };

         TenjinComms.ajax('/auth/sign-in', {
            data: data,
            onSuccess: function (response) {
               self.user(ko.mapping.fromJS(response.user));

               response.redirect = window.deserializeSearch().uri || response.redirect
            }
         });

         self.password(null);
      };
   }
});