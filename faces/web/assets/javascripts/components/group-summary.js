ko.components.register('group-summary', {
   template: {element: 'group-summary-template'},

   /**
    */
   viewModel: function (params) {
      var self = this;

      self.group = ko.unwrap(params.group || explode("Must provide 'group' parameter to group-summary"));

      self.edit_link = '/admin/edit-group?id=' + self.group.id;

      self.formatRoles = function (roleList) {
         return (roleList || []).map(function (roleName) {
            return roleName[0].toUpperCase() + roleName.substr(1);
         }).join(', ');
      };

      // BEHAVIOUR

   }
});