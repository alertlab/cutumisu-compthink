ko.components.register('group-editor', {
   template: ' <header data-bind="text: headerText()"></header>\
               <form data-bind="submit: save, css: formClass" autocomplete="off">\
                  <div class="group">\
                     <label>\
                        <span>Name</span>\
                        <input type="text" name="name" data-bind="value: group.name">\
                     </label>\
                     <label>\
                        <span>Start Date</span>\
                        <input type="text" name="start_date" data-bind="value: group.start_date">\
                     </label>\
                     <label>\
                        <span>End Date</span>\
                        <input type="text" name="end_date" data-bind="value: group.end_date">\
                     </label>\
                  </div>\
                  <div class="controls">\
                     <input type="button" class="delete" value="Delete" data-bind="visible: !isNewRecord(), click: toggleDeleteConfirm"/>\
                     <a href="/admin/people" class="cancel">Cancel</a>\
                     <input type="submit" value="Save" />\
                     <div class="delete-confirm" data-bind="visible: deleteConfirmVisible">\
                        <header>Confirm Deletion</header>\
                        <p>Are you sure you wish to delete <span data-bind="text: group.name"></span>? <strong>This action cannot be undone.</strong></p>\
                        <a href="#" data-bind="click: toggleDeleteConfirm">Cancel</a>\
                        <a href="#" data-bind="click: deleteGroup">Delete Permanently</a>\
                     </div>\
                     <div class="overlay" data-bind="visible: deleteConfirmVisible, click: toggleDeleteConfirm"></div>\
                  </div>\
               </form>',

   /**
    */
   viewModel: function (params) {
      var self = this;

      // STATE
      self.group = {
         id: ko.observable(window.deserializeSearch().id || null),
         name: ko.observable(''),
         start_date: ko.observable(''),
         end_date: ko.observable('')
      };

      self.formClass = ko.pureComputed(function () {
         return 'group-editor-' + (self.isNewRecord() ? 'new' : self.group.id());
      });

      self.onSave = function () {
         window.location = '/admin/people'
      };

      self.deleteConfirmVisible = ko.observable(false);

      self.isNewRecord = ko.pureComputed(function () {
         return !self.group.id();
      });

      self.getGroup = function () {
         var data;

         data = {
            count: 1,
            filter: {id: self.group.id()}
         };

         ajax('post', '/admin/search_groups', ko.toJSON(data), function (response) {
            var group = response.results[0] || {};

            // id is only defined on edit, not create
            self.group.id(group.id);

            self.group.name(group.name || '');
            self.group.email(group.email || '');
         });
      };

      if (!self.isNewRecord())
         self.getGroup();

      self.save = function () {
         var uri = self.isNewRecord() ? '/admin/create_group' : '/admin/update_group';

         var payload = ko.mapping.toJS(self.group, {ignore: ['pets']});

         ajax('post', uri, ko.mapping.toJSON(payload), function (response) {
            if (response.messages) {
               window.flash('notice', response.messages);
            }

            self.onSave();
         });
      };

      self.deleteGroup = function () {
         ajax('post', '/admin/delete_group', ko.mapping.toJSON({id: self.group.id()}), function (response) {
            if (response.messages)
               window.flash('notice', response.messages);

            self.toggleDeleteConfirm();
            self.onSave();
         });
      };

      self.headerText = ko.pureComputed(function () {
         return self.isNewRecord() ? 'New Group' : 'Edit ' + self.group.name();
      });

      self.toggleDeleteConfirm = function () {
         self.deleteConfirmVisible(!self.deleteConfirmVisible());
      };
   }
});