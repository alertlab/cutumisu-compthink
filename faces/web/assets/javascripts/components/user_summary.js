ko.components.register('user-summary', {
   template: ' <div class="user-summary" data-bind="attr: {id: \'user-\' + user.id}">\
                  <header>\
                     <a href="#" data-bind="attr: {href: edit_link}">\
                        <span data-bind="text: user.first_name"></span> <span data-bind="text: user.last_name"></span>\
                     </a>\
                     <div class="roles" data-bind="foreach: user.roles">\
                        <span class="role" data-bind="text: $parent.formatRole($data), css: $parent.roleClass($data)"></span>\
                     </div>\
                  </header>\
                  <div class="email">\
                     <a data-bind="text: user.email, attr:{ href: \'mailto:\' + user.email}"></a>\
                  </div>\
                  <div class="groups">\
                     <span>Groups:</span>\
                     <div data-bind="foreach: user.groups">\
                        <a class="group" data-bind="href: $parent.groupLink(id), \
                                                  text: name"></a>\
                     </div>\
                     <span class="placeholder" data-bind="visible: !user.groups.length">- none -</span>\
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

      self.groupLink = function (id) {
         return '/admin/edit_group?id=' + id;
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