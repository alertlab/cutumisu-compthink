ko.components.register('sign-in', {
   template: '<header>Sign In</header>\
              <form data-bind="submit: signIn">\
                 <ul>\
                    <li>\
                       <label for="email">Email</label>\
                       <input type="email" name="email" placeholder="eg. jdoe@example.com" data-bind="value: email" />\
                    </li>\
                    <li>\
                       <label for="password">Password</label>\
                       <input name="password" type="password" data-bind="value: password" />\
                    </li>\
                 </ul>\
                 <input type="submit" value="Sign In" />\
              </form>',

   viewModel: function () {
      var self = this;

      self.user = window.currentUser;

      self.email = ko.observable();
      self.password = ko.observable();

      self.signIn = function () {
         var data = ko.mapping.toJSON({
            user: {
               email: self.email(),
               password: self.password()
            }
         });

         ajax('post', '/auth/sign_in', data, function (response) {
            //if (response.notice)
            //   window.flash('notice', response.notice);

            self.user(ko.mapping.fromJS(response.user));

            var cookie = JSON.stringify({notices: [response.notice]});
            document.cookie = 'flash=' + encodeURIComponent(cookie);

            window.location = window.deserializeSearch().uri || '/admin/people';
         });

         self.password(null);
      };
   }
});