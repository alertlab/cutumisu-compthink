ko.components.register('user-editor', {
   template: ' <basic-form params="header: headerText, \
                                   formClass: formClass,\
                                   onSave: save,\
                                   onDelete: deleteUser, \
                                   canDelete: !isNewRecord(), \
                                   deleteConfirm: deleteConfirm,\
                                   cancelHref: \'/admin/people\' ">\
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
                     <fieldset class="participation">\
                        <legend>Participation</legend>\
                        <div>\
                           <div class="groups">\
                              <header>Groups</header>\
                              <div data-bind="foreach: user.groups">\
                                 <a data-bind="href: $parent.groupLink(id), text: name"></a>\
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
                              <confirm-dialog class="reset-clicks-confirm" params="visibility: showResetConfirm, \
                                                                                   header: \'Reset Click Data\',\
                                                                                   onConfirm: resetClicks, \
                                                                                   confirm: \'Reset Permanently\'">\
                                 <p>\
                                    Are you sure you wish to delete <strong>all clicks</strong> for \
                                    <span data-bind="text: user.first_name"></span> <span data-bind="text: user.last_name"></span>?\
                                 </p>\
                                 <p>\
                                    <strong>This action cannot be undone.</strong>\
                                 </p>\
                              </confirm-dialog>\
                           </div>\
                        </div>\
                     </fieldset>\
                  </div>\
                  <header>Security</header>\
                  <div class="security">\
                     <input-password-metered params="password: user.password"></input-password-metered>\
                     <div class="roles">\
                        <header>Roles</header>\
                        <input-checklist params="values: allRoles, checkedItems: user.roles"></input-checklist>\
                     </div>\
                  </div>\
               </basic-form>',

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
         password: ko.observable(''),
         roles: ko.observableArray(),
         groups: ko.observableArray(),
         puzzles_completed: ko.observableArray()
      };

      self.allPuzzles = ['hanoi', 'levers'];
      self.allRoles = JSON.parse(decodeURIComponent(window.appData.roles));

      self.showResetConfirm = ko.observable(false).toggleable();

      self.formClass = ko.pureComputed(function () {
         return 'user-editor-' + (self.isNewRecord() ? 'new' : self.user.id());
      });

      self.deleteConfirm = ko.pureComputed(function () {
         return 'Are you sure you wish to delete ' + self.user.first_name() + ' ' + self.user.last_name() + '?';
      });

      self.groupLink = function (id) {
         return '/admin/edit_group?id=' + id
      };

      self.isNewRecord = ko.pureComputed(function () {
         return !self.user.id();
      });

      self.resetClicks = function () {
         ajax('post', '/admin/reset_clicks', ko.toJSON({user_id: self.user.id}), function (response) {
            window.flash('notice', response.messages);

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
         });
      };

      self.headerText = ko.pureComputed(function () {
         return self.isNewRecord() ? 'New Person' : 'Edit ' + self.user.first_name() + ' ' + self.user.last_name();
      });
   }
});