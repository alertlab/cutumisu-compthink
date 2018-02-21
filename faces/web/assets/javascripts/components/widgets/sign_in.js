ko.components.register('sign-in', {
   template: '<header>Sign In</header>\
              <form data-bind="submit: signIn">\
                 <ul data-bind="visible: isAdmin">\
                    <li>\
                       <label for="email">Email</label>\
                       <input type="email" name="email" placeholder="eg. jdoe@example.com" data-bind="value: email" />\
                    </li>\
                    <li>\
                       <label for="password">Password</label>\
                       <input name="password" type="password" data-bind="value: password" />\
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
                 <input type="submit" data-bind="value: buttonText"  />\
              </form>',

   viewModel: function () {
      var self = this;

      self.user = window.currentUser;

      self.email = ko.observable();
      self.password = ko.observable();

      self.group = ko.observable();
      self.username = ko.observable();

      self.isAdmin = !!(window.location.pathname.match(/^\/admin/) || window.location.search.match(/\?uri=\/admin/));

      self.buttonText = ko.pureComputed(function () {
         return self.isAdmin ? 'Sign In' : 'Go!'
      });

      self.signIn = function () {
         var data = {
            admin: {
               email: self.email(),
               password: self.password()
            },
            user: {
               group: self.group(),
               username: self.username()
            }
         };

         ajax('post', '/auth/sign_in', ko.mapping.toJSON(data), function (response) {
            var homepage, cookie;

            self.user(ko.mapping.fromJS(response.user));

            cookie = JSON.stringify({notices: [response.notice]});
            document.cookie = 'flash=' + encodeURIComponent(cookie);

            homepage = self.isAdmin ? '/admin' : '/games';

            window.location = window.deserializeSearch().uri || homepage;
         });

         self.password(null);
      };
   }
});