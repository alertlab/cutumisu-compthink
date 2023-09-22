ko.components.register('group-summary', {
   template: ' <div class="group-summary" data-bind="attr: {id: \'group-\' + group.id}">\
                  <header>\
                     <a href="#" data-bind="attr: {href: edit_link}">\
                        <span data-bind="text: group.name"></span>\
                     </a>\
                  </header>\
                  <div>\
                     Active \
                     <span data-bind="text: humanDate(group.start_date)"></span>\
                     to \
                     <span data-bind="text: humanDate(group.end_date)"></span>\
                  </div>\
                  <div class="controls">\
                     <a href="#" data-bind="attr: {href: edit_link}">Edit</a>\
                  </div>\
               </div>',

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