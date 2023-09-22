ko.components.register('input-password-metered', {
   template: '<div class="overlay" data-bind="click: showTips.toggle, visible: showTips"></div>\
              <label class="password-edit">\
                 <span>New Password</span>\
                 <input-password params="password: password"></input-password>\
                 <div class="strength">\
                    <meter min=0 max=4 high=3 low=2 optimum=4 value=0 data-bind="value: pwStrengthScore"></meter>\
                    <div class="score-label">\
                       <span class="label">Strength:</span>\
                       <span class="score" data-bind="text: pwStrengthLabel"></span>\
                    </div>\
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
   }
});