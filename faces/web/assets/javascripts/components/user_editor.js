ko.components.register('user-editor', {
   template: ' <header data-bind="text: headerText()"></header>\
               <form data-bind="submit: save, css: formClass" autocomplete="off">\
                  <div class="personal">\
                     <div class="identity">\
                        <label>\
                           <span>First Name</span>\
                           <input type="text" name="first_name" data-bind="value: user.first_name">\
                        </label>\
                        <label>\
                           <span>Last Name</span>\
                           <input type="text" name="last_name" data-bind="value: user.last_name">\
                        </label>\
                     </div>\
                     <fieldset class="contact-info">\
                        <legend>Contact Information</legend>\
                        <label>\
                           <span>Email</span>\
                           <input type="email" name="email" data-bind="value: user.email">\
                        </label>\
                     </fieldset>\
                  </div>\
                  <div class="controls">\
                     <input type="button" \
                            class="delete" \
                            value="Delete" \
                            data-bind="visible: !isNewRecord(), click: deleteConfirmVisible.toggle"/>\
                     <a href="/admin/people" class="cancel">Cancel</a>\
                     <input type="submit" value="Save" />\
                     <float-frame class="delete-confirm" params="visibility: deleteConfirmVisible">\
                        <header>Confirm Deletion</header>\
                        <p>\
                           Are you sure you wish to delete <span data-bind="text: $parent.user.first_name"></span> \
                           <span data-bind="text: $parent.user.last_name"></span>?\
                           <strong>This action cannot be undone.</strong>\
                        </p>\
                        <a href="#" data-bind="click: $parent.deleteConfirmVisible.toggle">Cancel</a>\
                        <a href="#" data-bind="click: $parent.deleteUser">Delete Permanently</a>\
                     </float-frame>\
                  </div>\
               </form>',

   /**
    */
   viewModel: function (params) {
      var self = this;

      // STATE
      self.user = {
         id: ko.observable(window.deserializeSearch().id || null),
         first_name: ko.observable(''),
         last_name: ko.observable(''),
         email: ko.observable('')
      };

      self.formClass = ko.pureComputed(function () {
         return 'user-editor-' + (self.isNewRecord() ? 'new' : self.user.id());
      });

      self.deleteConfirmVisible = ko.observable(false).toggleable();

      self.isNewRecord = ko.pureComputed(function () {
         return !self.user.id();
      });

      self.getUser = function () {
         var data;

         data = {
            count: 1,
            filter: {id: self.user.id()}
         };

         ajax('post', '/admin/search_users', ko.toJSON(data), function (response) {
            var user = response.results[0] || {};

            // id is only defined on edit, not create
            self.user.id(user.id);

            self.user.first_name(user.first_name || '');
            self.user.last_name(user.last_name || '');
            self.user.email(user.email || '');
         });
      };

      if (!self.isNewRecord())
         self.getUser();

      self.save = function () {
         var uri = self.isNewRecord() ? '/admin/create_user' : '/admin/update_user';

         var payload = ko.mapping.toJS(self.user, {ignore: ['pets']});

         ajax('post', uri, ko.mapping.toJSON(payload), function (response) {
            window.flash('notice', response.messages);
         });
      };

      self.deleteUser = function () {
         ajax('post', '/admin/delete_user', ko.mapping.toJSON({id: self.user.id()}), function (response) {
            window.flash('notice', response.messages);

            self.deleteConfirmVisible.toggle();
         });
      };

      self.headerText = ko.pureComputed(function () {
         return self.isNewRecord() ? 'New Person' : 'Edit ' + self.user.first_name() + ' ' + self.user.last_name();
      });
   }
});