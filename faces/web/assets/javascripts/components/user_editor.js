ko.components.register('user-editor', {
   template: ' <header data-bind="text: headerText()"></header>\
               <form data-bind="submit: save, css: formClass" autocomplete="off">\
                  <div class="personal">\
                     <fieldset class="contact-info">\
                        <label>\
                           <span>First Name</span>\
                           <input type="text" name="first_name" data-bind="value: user.first_name">\
                        </label>\
                        <label>\
                           <span>Last Name</span>\
                           <input type="text" name="last_name" data-bind="value: user.last_name">\
                        </label>\
                        <legend>Contact Information</legend>\
                        <label>\
                           <span>Email</span>\
                           <input type="email" name="email" data-bind="value: user.email">\
                        </label>\
                     </fieldset>\
                     <fieldset class="roles">\
                        <legend>Roles</legend>\
                        <div data-bind="foreach: allRoles">\
                           <label>\
                              <input type="checkbox" data-bind="value: $data.toLowerCase(), checked: $parent.user.roles">\
                              <span data-bind="text: $data"></span>\
                           </label>\
                        </div>\
                     </fieldset>\
                  </div>\
                  <fieldset class="participation">\
                     <legend>Participation</legend>\
                     <div>\
                        <div class="groups">\
                           <header>Groups</header>\
                           <div data-bind="foreach: user.groups">\
                              <a data-bind="href: $parent.groupLink(id),text: name"></a>\
                           </div>\
                           <span class="placeholder" data-bind="visible: !user.groups().length">- none -</span>\
                        </div>\
                        <div class="completed">\
                           <header>Completed Puzzles</header>\
                           <div data-bind="foreach: allPuzzles">\
                              <label class="puzzle" data-bind="css: $data">\
                                 <input type="checkbox" disabled data-bind="value: $data, checked: $parent.user.puzzles_completed" />\
                                 <span data-bind="text: titlecase($data)"></span>\
                              </label>\
                           </div>\
                           <a href="#" class="reset-clicks" data-bind="click: showResetConfirm">Reset Clicks</a>\
                           <float-frame class="reset-clicks-confirm" params="visibility: showResetConfirm">\
                              <header>Reset Click Data?</header>\
                              <p>\
                                 Are you sure you wish to delete <strong>all clicks</strong> for \
                                 <span data-bind="text: $parent.user.first_name"></span> <span data-bind="text: $parent.user.last_name"></span>?\
                              </p>\
                              <p>\
                                 <strong>This action cannot be undone.</strong>\
                              </p>\
                              <a href="#" data-bind="click: $parent.showResetConfirm.toggle">Cancel</a>\
                              <a href="#" data-bind="click: $parent.resetClicks">Delete Permanently</a>\
                           </float-frame>\
                        </div>\
                     </div>\
                  </fieldset>\
                  <!--<password-editor></password-editor>-->\
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
                        </p>\
                        <p>\
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
         email: ko.observable(''),
         roles: ko.observableArray(),
         groups: ko.observableArray(),
         puzzles_completed: ko.observableArray()
      };

      self.showResetConfirm = ko.observable(false).toggleable();

      self.allPuzzles = ['hanoi', 'levers'];

      self.formClass = ko.pureComputed(function () {
         return 'user-editor-' + (self.isNewRecord() ? 'new' : self.user.id());
      });

      self.groupLink = function (id) {
         return '/admin/edit_group?id=' + id
      };

      self.deleteConfirmVisible = ko.observable(false).toggleable();

      self.isNewRecord = ko.pureComputed(function () {
         return !self.user.id();
      });

      self.allRoles = JSON.parse(decodeURIComponent(params['roles'] || '[]'));

      self.resetClicks = function () {
         ajax('post', '/admin/reset_clicks', ko.toJSON({user_id: self.user.id}), function (response) {
            window.flash('notice', response.messages);

            self.showResetConfirm.toggle();

            self.getUser();
         });
      };

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

            self.user.roles(user.roles || []);
            self.user.groups(user.groups || []);

            self.user.puzzles_completed(user.puzzles_completed || []);
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