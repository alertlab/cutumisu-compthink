ko.components.register('user-summary', {
   template: {element: 'user-summary-template'},

   /**
    */
   viewModel: function (params) {
      var self = this;

      self.user = ko.unwrap(params.user || explode("Must provide 'user' parameter to user summary"));

      self.edit_link = '/admin/edit-person?id=' + self.user.id;

      self.groupLink = function (id) {
         return '/admin/edit-group?id=' + id;
      };

      self.roleClass = function (roleName) {
         return 'role-' + roleName.toLowerCase();
      };

      self.formatRole = function (roleName) {
         return roleName[0].toUpperCase() + roleName.substr(1);
      };

      // BEHAVIOUR
   }
});