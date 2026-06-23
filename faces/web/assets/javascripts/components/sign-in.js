ko.components.register('sign-in', {
   template: {element: 'sign-in-template'},

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
