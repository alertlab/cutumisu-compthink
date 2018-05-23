ko.components.register('group-editor', {
   template: ' <basic-form params="header: headerText, \
                                   formClass: formClass,\
                                   onSave: save,\
                                   onDelete: deleteGroup, \
                                   canDelete: !isNewRecord(), \
                                   deleteConfirm: deleteConfirm,\
                                   cancelHref: \'/admin/groups\' ">\
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
                     <div class="participants" data-bind="visible: !isNewRecord()">\
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
                           <a href="#" class="bulk-add" data-bind="click: bulk.isVisible.toggle">Bulk Create...</a>\
                           <a href="#" class="add" data-bind="click: addParticipant">+1</a>\
                        </div>\
                        <float-frame class="bulk-participants" params="visibility: bulk.isVisible">\
                           <header>Add Multiple Participants</header>\
                           <label>\
                              <span>\
                                 Number\
                              </span>\
                              <input name="number" type="number" min="1" data-bind="value: $parent.bulk.number"/>\
                           </label>\
                           <label>\
                              <span>\
                                 Prefix\
                              </span>\
                              <input name="prefix" type="text" data-bind="value: $parent.bulk.prefix" />\
                           </label>\
                           <div class="controls">\
                              <button type="button" class="cancel" data-bind="click: $parent.bulk.isVisible.toggle">Cancel</button>\n\
                              <button type="button" class="add" data-bind="click: $parent.bulk.createUsers">Add</button>\
                           </div>\
                        </float-frame>\
                     </div>\
                  </div>\
               </basic-form>',

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
         isVisible: ko.observable(false).toggleable(),
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

            self.bulk.isVisible(false);
         }
      };

      self.datePickers = {
         start: new Pikaday({
            field: document.querySelector('input[name="start_date"]'),
            onSelect: function (date) {
               var input = document.querySelector('input[name="start_date"]');

               self.group.start_date(date.toISOString());
               input.value = humanDate(date.getTime() / 1000);
            }
         }),
         end: new Pikaday({
            field: document.querySelector('input[name="end_date"]'),
            onSelect: function (date) {
               var input = document.querySelector('input[name="end_date"]');

               self.group.end_date(date.toISOString());
               input.value = humanDate(date.getTime() / 1000);
            }
         })
      };

      self.formClass = ko.pureComputed(function () {
         return 'group-editor-' + (self.isNewRecord() ? 'new' : self.group.id());
      });

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
            self.group.start_date(humanDate(group.start_date || ''));
            self.group.end_date(humanDate(group.end_date || ''));

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
               payload.create_participants.push(userData);
            else
               payload.participants.push(userData.id);
         });

         ajax('post', uri, ko.mapping.toJSON(payload), function (response) {
            if (response.messages) {
               window.flash('notice', response.messages);
            }
         });
      };

      self.deleteGroup = function () {
         ajax('post', '/admin/delete_group', ko.mapping.toJSON({id: self.group.id()}), function (response) {
            if (response.messages)
               window.flash('notice', response.messages);
         });
      };

      self.deleteConfirm = ko.pureComputed(function () {
         return 'Are you sure you wish to delete ' + self.group.name() + '?';
      });

      self.buildUserLabel = function (user) {
         return user.first_name + ' ' + user.last_name;
      };

      self.userLink = function (user) {
         return '/admin/edit_person?id=' + user.id;
      };

      self.headerText = ko.pureComputed(function () {
         return self.isNewRecord() ? 'New Group' : 'Edit ' + self.group.name();
      });

      self.addParticipant = function () {
         self.group.participants.push({user: ko.observable()});
      };

      self.removeParticipant = function (userShell) {
         self.group.participants.remove(userShell);
      };
   }
});