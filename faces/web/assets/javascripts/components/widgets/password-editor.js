ko.components.register('password-editor', {
   template: '<div class="overlay" data-bind="click: showTips.toggle, visible: showTips"></div>\
              <label class="password-edit">\
                 <span>New Password</span>\
                 <password-input params="password: password"></password-input>\
                 <div class="strength">\
                    <meter min=0 max=4 high=3 low=2 optimum=4 value=0 data-bind="value: pwStrengthScore"></meter>\
                    <span>Strength:</span>\
                    <span class="score-label" data-bind="text: pwStrengthLabel"></span>\
                    <div class="tips-wrapper">\
                       <a href="#" data-bind="click: showTips.toggle, visible: pwStrengthTips().length > 0">Tips</a>\
                       <ul class="tips" data-bind="foreach: pwStrengthTips, visible: showTips">\
                          <li data-bind="text: $data"></li>\
                       </ul>\
                    </div>\
                 </div>\
              </label>',

   viewModel: function (params) {
      var self = this;

      self.scoreLabels = params['categories'] || [
         'Very Weak',
         'Weak',
         'Okay',
         'Strong',
         'Very Strong'
      ];

      self.user = window.currentUser;

      self.password = params['password'] || ko.observable('');

      self.showTips = ko.observable(false).toggleable();

      self.pwStrength = ko.pureComputed(function () {
         return zxcvbn(self.password());
      });

      self.pwStrengthScore = ko.pureComputed(function () {
         return self.pwStrength().score;
      });

      self.pwStrengthLabel = ko.pureComputed(function () {
         return self.scoreLabels[self.pwStrengthScore()];
      });

      self.pwStrengthTips = ko.pureComputed(function () {
         var feedback = self.pwStrength().feedback;

         if (feedback.warning)
            return feedback.suggestions.concat([feedback.warning]);
         else
            return feedback.suggestions;
      });

      self.setPassword = function () {
         // var data = {
         //    admin: {
         //       email: self.email(),
         //       password: self.password()
         //    },
         //    user: {
         //       group: self.group(),
         //       username: self.username()
         //    }
         // };
         //
         // ajax('post', '/auth/sign_in', ko.mapping.toJSON(data), function (response) {
         //    self.user(ko.mapping.fromJS(response.user));
         //
         //    document.cookie = 'compthink.flash_notices=' + encodeURIComponent(JSON.stringify([response.notice]));
         //
         //    response.redirect = window.deserializeSearch().uri || response.redirect
         // });
         //
         // self.password(null);
      };
   }
});