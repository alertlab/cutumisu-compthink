ko.components.register('session', {
   template: '<!--<a data-bind="visible: currentEmail(), text: currentEmail(), attr: {href: \'edit_account\'}"></a>-->\
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
            var cookie = JSON.stringify({notices: [response.notice]});

            document.cookie = 'flash=' + cookie + ';path=/';

            eatCookie('compthink.user_data');

            //window.flash('notice', response.notice);
            window.currentUser(null);

            window.location = '/';
         });
      };
   }
});