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
            var value = JSON.stringify([response.notice]);

            document.cookie = 'compthink.flash_notices=' + value + ';path=/';

            eatCookie('compthink.user_data');

            //window.flash('notice', response.notice);
            window.currentUser(null);

            window.location = '/';
         });
      };
   }
});