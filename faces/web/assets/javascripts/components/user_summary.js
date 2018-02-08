ko.components.register('user-summary', {
   template: ' <div class="user-summary" data-bind="attr: {id: \'user-\' + user.id}">\
                  <header>\
                     <a href="#" data-bind="attr: {href: edit_link}">\
                        <span data-bind="text: user.first_name"></span> <span data-bind="text: user.last_name"></span>\
                     </a>\
                  </header>\
                  <div>\
                     <span data-bind="text: formatRoles(user.roles)"></span>\
                  </div>\
                  <div>\
                     <a data-bind="text: user.email, attr:{ href: \'mailto:\' + user.email}"></a>\
                  </div>\
                  <div class="controls">\
                     <a href="#" data-bind="attr: {href: edit_link}">Edit</a>\
                  </div>\
               </div>',

   /**
    */
   viewModel: function (params) {
      var self = this;

      self.user = ko.unwrap(params.user || explode("Must provide 'user' parameter to user summary"));

      self.edit_link = '/admin/edit_person?id=' + self.user.id;

      self.formatRoles = function (roleList) {
         return (roleList || []).map(function (roleName) {
            return roleName[0].toUpperCase() + roleName.substr(1);
         }).join(', ');
      };

      // BEHAVIOUR

   }
});