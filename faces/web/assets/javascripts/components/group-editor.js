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
                     <div class="participation-type" data-bind="visible: !isNewRecord()">\
                        <header>\
                           Participation Type\
                        </header>\
                        <div class="participation-type-selector">\
                           <label>\
                              <input type="radio" name="participation-type" data-bind="checked: group.participationType" value="closed" />\
                              <span>Closed</span>\
                           </label>\
                           <label>\
                              <input type="radio" name="participation-type" data-bind="checked: group.participationType" value="open"/>\
                              <span>Open</span>\
                           </label>\
                           <label>\
                              <input type="radio" name="participation-type" data-bind="checked: group.participationType" value="custom" />\
                              <span>Custom</span>\
                           </label>\
                        </div>\
                        <div class="open" data-bind="visible: group.participationType() === \'custom\'">\
                           <p>\
                              Like Open, but you can be more restrictive on the allowed characters. \
                              <a href="https://rubular.com/" target="_blank">See here</a> for a list of regex codes.\
                           </p>\
                           <label>\
                              <span>Restricting Regular Expression</span>\
                              <input type="text" name="regex" data-bind="value: group.regex" />\
                           </label>\
                        </div>\
                        <div class="open" data-bind="visible: group.participationType() === \'open\'">\
                           <p>\
                              Open means any non-whitespace character will be accepted as user IDs.\
                           </p>\
                           <p>\
                              These users will be recorded and registered at the time of testing, not beforehand.\
                           </p>\
                        </div>\
                        <div class="closed" data-bind="visible: group.participationType() === \'closed\'">\
                           <p>\
                              Closed participation requires that the participants are pre-registered by an admin.\
                           </p>\
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
                              <a href="#" class="bulk-add" data-bind="click: bulk.isVisible.toggle">Bulk Create...</a>\
                              <a href="#" class="add" data-bind="click: addParticipant">+1</a>\
                           </div>\
                           <confirm-dialog class="bulk-participants" \
                                           params="header: \'Add Multiple Participants\',\
                                                   visibility: bulk.isVisible,\
                                                   onConfirm: bulk.createUsers,\
                                                   confirm: \'Add\'">\
                              <div class="mode">\
                                 <label>\
                                    <input type="radio" name="mode" data-bind="checked: bulk.mode" value="generating" />\
                                    <span>Generate</span>\
                                 </label>\
                                 <label>\
                                    <input type="radio" name="mode" data-bind="checked: bulk.mode" value="list" />\
                                    <span>Enter List</span>\
                                 </label>\
                              </div>\
                              <div class="mode-generating" data-bind="visible: bulk.isGenerating">\
                                 <label>\
                                    <span>How Many?</span>\
                                    <input name="number" type="number" min="1" data-bind="value: bulk.number"/>\
                                 </label>\
                                 <label>\
                                    <span>Prefix</span>\
                                    <input name="prefix" type="text" data-bind="textInput: bulk.prefix" />\
                                 </label>\
                                 <label class="example">\
                                    <span>eg.</span>\
                                    <span data-bind="text: bulk.exampleUserLast"></span>\
                                 </label>\
                              </div>\
                              <div class="mode-list" data-bind="visible: bulk.isList">\
                                 <textarea name="list" class="width" data-bind="value: bulk.list"></textarea>\
                                 <p class="example">\
                                   Enter a list of IDs, each on their own line. eg:\
                                 </p>\
                                 <p class="example">\
                                   janeway<br>\
                                   picard<br>\
                                   sisko\
                                 </p>\
                              </div>\
                           </confirm-dialog>\
                        </div>\
                     </div>\
                  </div>\
               </basic-form>',

   /**
    *
    */
   viewModel: function (params) {
      var self = this;

      // STATE
      self.group = {
         id: ko.observable(window.deserializeSearch().id || null),
         name: ko.observable(''),
         start_date: ko.observable(''),
         end_date: ko.observable(''),
         participants: ko.observableArray(),
         participationType: ko.observable('closed'),
         regex: ko.observable(''),
         open: ko.observable(false)
      };

      // regular expression shortcut for open groups
      self.openRegex = "\\S+";

      self.bulk = {
         number: ko.observable(1),
         prefix: ko.observable('user'),
         isVisible: ko.observable(false).toggleable(),
         list: ko.observable(''),
         mode: ko.observable('generating'),
         isGenerating: ko.pureComputed(function () {
            return self.bulk.mode() === 'generating';
         }),
         isList: ko.pureComputed(function () {
            return self.bulk.mode() === 'list';
         }),
         maxNumber: ko.pureComputed(function () {
            var maxNumber = 0;

            if (self.group.participants().length > 0) {
               maxNumber = self.group.participants().map(function (userShell) {
                  return parseInt(userShell.user().first_name.replace(self.bulk.prefix(), '')) || 0;
               }).reduce(function (a, b) {
                  return Math.max(a || 0, b || 0);
               });
            }

            return maxNumber;
         }),
         createUsers: function () {
            var newUsers;
            var ids = [];

            if (self.bulk.isGenerating()) {
               for (var i = 0; i < self.bulk.number(); i++) {
                  var name = self.bulk.prefix() + padDigitLeft(self.bulk.maxNumber() + i + 1, 3);

                  ids.push(name);
               }
            } else { // then is list
               ids = self.bulk.list().split("\n");
            }

            newUsers = ids.map(function (name) {
               return {
                  user: ko.observable({
                     first_name: name,
                     email: name + '-' + self.group.name() + '@example.com',
                     isNewUser: true
                  })
               };
            });

            self.group.participants(self.group.participants().concat(newUsers))
         },
         exampleUserLast: ko.pureComputed(function () {
            return self.bulk.prefix() + '15';
         })
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

            self.group.regex(group.regex);

            if (self.group.regex() === self.openRegex)
               self.group.participationType('open');
            else if (self.group.regex() === '' || self.group.regex() === null || self.group.regex() === undefined)
               self.group.participationType('closed');
            else
               self.group.participationType('custom');

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
         var uri, payload, pType;

         uri = self.isNewRecord() ? '/admin/create_group' : '/admin/update_group';

         payload = ko.mapping.toJS(self.group, {ignore: ['participants', 'open']});

         pType = self.group.participationType();

         if (pType === 'open')
            payload.regex = self.openRegex;
         else if (pType === 'closed')
            payload.regex = '';

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
