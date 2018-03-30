ko.components.register('group-editor', {
   template: ' <header data-bind="text: headerText()"></header>\
               <form data-bind="submit: save, css: formClass" autocomplete="off">\
                  <div class="group">\
                     <div class="basic-info">\
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
                     <div class="participants">\
                        <header>\
                           Participants (<span data-bind="text: group.participants().length"></span>)\
                        </header>\
                        <div class="list" data-bind="foreach: {data: group.participants, as: \'userShell\'}">\
                           <div>\
                              <div class="new-participant" data-bind="visible: !userShell.user(), \
                                                                      if: !userShell.user()">\
                                 <search-select params="uri: \'/admin/search_users\', \
                                                        selectedObservable: userShell.user,\
                                                        labelWith: $parent.buildUserLabel, \
                                                        name: \'participant-\'+ $index()"></search-select>\
                              </div>\
                              <div class="participant" data-bind="visible: userShell.user(), \
                                                                  if: userShell.user()">\
                                 <a href="#" data-bind="href: $parent.userLink(userShell.user())">\
                                    <span data-bind="text: userShell.user().first_name"></span>\
                                    <span data-bind="text: userShell.user().last_name"></span>\
                                 </a>\
                                 <!--<user-summary params="user: userShell.user"></user-summary>-->\
                              </div>\
                              <a href="#" class="delete" title="Remove Participant" data-bind="click: function() { $parent.removeParticipant(userShell) }">x</a>\
                           </div>\
                        </div>\
                        <span class="placeholder" data-bind="visible: !group.participants().length">- nobody -</span>\
                        <div class="controls">\
                           <a href="#" class="bulk-add" data-bind="click: bulk.toggleVisible">Bulk Create...</a>\
                           <a href="#" class="add" data-bind="click: addParticipant">+1</a>\
                        </div>\
                        <div class="bulk-participants" data-bind="visible: bulk.isVisible">\
                           <label>\
                              <span>\
                                 Number\
                              </span>\
                              <input name="number" type="number" min="1" data-bind="value: bulk.number"/>\
                           </label>\
                           <label>\
                              <span>\
                                 Prefix\
                              </span>\
                              <input name="prefix" type="text" data-bind="value: bulk.prefix" />\
                           </label>\
                           <hr>\
                           <button type="button" data-bind="click: bulk.createUsers">Add</button>\
                        </div>\
                        <div class="overlay" data-bind="visible: bulk.isVisible, click: bulk.toggleVisible"></div>\
                     </div>\
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
         end_date: ko.observable(''),
         participants: ko.observableArray()
      };

      self.bulk = {
         number: ko.observable(1),
         prefix: ko.observable('user'),
         isVisible: ko.observable(false),
         toggleVisible: function () {
            self.bulk.isVisible(!self.bulk.isVisible());
         },
         createUsers: function () {
            var maxNumber;
            var newUsers = [];

            if (self.group.participants().length > 0)
               maxNumber = self.group.participants().map(function (userShell) {
                  return parseInt(userShell.user().first_name.replace(self.bulk.prefix(), '')) || 0;
               }).reduce(function (a, b) {
                  return Math.max(a || 0, b || 0);
               });
            else
               maxNumber = 0;

            for (var i = 0; i < self.bulk.number(); i++) {
               var name = self.bulk.prefix() + padDigitLeft(maxNumber + i + 1, 3);

               newUsers.push({
                  user: ko.observable({
                     first_name: name,
                     email: name + '-' + self.group.name() + '@example.com',
                     isNewUser: true
                  })
               });
            }

            self.group.participants(self.group.participants().concat(newUsers))

            self.bulk.toggleVisible();
         }
      };

      self.formClass = ko.pureComputed(function () {
         return 'group-editor-' + (self.isNewRecord() ? 'new' : self.group.id());
      });

      self.onSave = function () {
         window.location = '/admin/groups'
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
            self.group.start_date(group.start_date || '');
            self.group.end_date(group.end_date || '');

            self.group.participants(group.participants.map(function (p) {
               return {
                  user: ko.observable(p)
               }
            }));
         });
      };

      if (!self.isNewRecord())
         self.getGroup();

      self.save = function () {
         var uri, payload;

         uri = self.isNewRecord() ? '/admin/create_group' : '/admin/update_group';

         payload = ko.mapping.toJS(self.group, {ignore: ['participants']});

         payload.participants = [];
         payload.create_participants = [];

         self.group.participants().forEach(function (userShell) {
            var userData = userShell.user();

            if (userData.isNewUser)
               payload.create_participants.push(userData)
            else
               payload.participants.push(userData.id);
         });

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

      self.buildUserLabel = function (user) {
         return user.first_name + ' ' + user.last_name;
      };

      self.userLink = function (user) {
         return '/admin/edit_person?id=' + user.id;
      };

      self.headerText = ko.pureComputed(function () {
         return self.isNewRecord() ? 'New Group' : 'Edit ' + self.group.name();
      });

      self.toggleDeleteConfirm = function () {
         self.deleteConfirmVisible(!self.deleteConfirmVisible());
      };

      self.addParticipant = function () {
         self.group.participants.push({user: ko.observable()});
      };

      self.removeParticipant = function (userShell) {
         self.group.participants.remove(userShell);
      };
   }
});