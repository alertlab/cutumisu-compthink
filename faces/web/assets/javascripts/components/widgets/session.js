ko.components.register('session', {
   template: '<span data-bind="text: currentEmail()"></span>\
              <a href="#" data-bind="click: signOut">Sign Out</a>',

   viewModel: function () {
      var self = this;

      self.currentEmail = function () {
         if (window.currentUser())
            return window.currentUser().email;
         else
            return '';
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