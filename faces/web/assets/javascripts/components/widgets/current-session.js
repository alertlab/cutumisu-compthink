ko.components.register('current-session', {
   template: '<!-- ko if: signedIn -->\
                 <span class="user-id" data-bind="text: currentEmail()"></span>\
                 <a href="#" class="sign-out" data-bind="click: signOut">Sign Out</a>\
              <!-- /ko -->',

   viewModel: function () {
      var self = this;

      self.isAdmin = !!(window.location.pathname.match(/^\/admin/) || window.location.search.match(/\?uri=\/admin/));

      self.signedIn = ko.pureComputed(function () {
         return !!window.currentUser();
      });

      self.currentEmail = function () {
         if (!self.signedIn())
            return '';

         if (self.isAdmin)
            return window.currentUser().email;
         else
            return window.currentUser().first_name;
      };

      self.signOut = function () {
         ajax('post', '/auth/sign_out', null, function (response) {
            eatCookie('compthink.user_data');

            window.flash('notice', response.notice);

            window.currentUser(null);
         });
      };
   }
});