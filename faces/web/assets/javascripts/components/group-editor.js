ko.components.register('group-editor', {
   template: ' <basic-form params="header: headerText, \
                                   formClass: formClass,\
                                   onSave: save,\
                                   onDelete: deleteGroup, \
                                   deletable: !isNewRecord(), \
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
                           <input type="date" name="start_date" data-bind="value: group.start_date" autocomplete="off">\
                        </label>\
                        <label>\
                           <span>End Date</span>\
                           <input type="date" name="end_date" data-bind="value: group.end_date" autocomplete="off">\
                        </label>\
                     </div>\
                     <div class="participation-type">\
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
                              Like Open, but you can be more restrictive on the allowed characters using Regular Expressions. \
                              <a href="https://rubular.com/" target="_blank">See here</a> for a list of regex codes.\
                           </p>\
                           <label>\
                              <span>Restricting Regex</span>\
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
                           <div class="controls">\
                              <button type="button" class="bulk-add" data-bind="click: bulk.isVisible.toggle">Bulk Create...</button>\
                              <button type="button" class="add" data-bind="click: addParticipant">+1</button>\
                           </div>\
                           <div class="list" data-bind="foreach: {data: group.participants, as: \'userShell\'}">\
                              <div>\
                                 <div class="new-participant" data-bind="visible: !userShell.user(), \
                                                                         if: !userShell.user()">\
                                    <input-search params="value: userShell.user,\
                                                          searchText: userShell.userSearch, \
                                                          searchResults: userShell.foundUsers">\
                                    <span data-bind="text: $data.first_name"></span>\
                                    <span data-bind="text: $data.last_name"></span>\
                                    </input-search>\
                                 </div>\
                                 <div class="participant" data-bind="visible: userShell.user(), \
                                                                     if: userShell.user()">\
                                    <a href="#" data-bind="href: $parent.userLink(userShell.user())">\
                                       <span data-bind="text: userShell.user().first_name"></span>\
                                       <span data-bind="text: userShell.user().last_name"></span>\
                                    </a>\
                                    <!--<user-summary params="user: userShell.user"></user-summary>-->\
                                 </div>\
                                 <button class="delete" title="Remove Participant" data-bind="click: function() { $parent.removeParticipant(userShell) }">x</button>\
                              </div>\
                           </div>\
                           <span class="placeholder" data-bind="hidden: group.participants().length">- nobody -</span>\
                           <dialog-confirm class="bulk-participants" \
                                           params="title: \'Add Multiple Participants\',\
                                                   visible: bulk.isVisible,\
                                                   actions: bulk.actions,\
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
                           </dialog-confirm>\
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

      var UserShell = function (user) {
         var shellSelf = this;
         this.user = ko.observable(user);
         this.userSearch = ko.observable('');
         this.searchResults = ko.observableArray().extend({
            loaded: {
               url: '/admin/search-users',
               params: {
                  filter: {
                     name: shellSelf.userSearch
                  }
               }
            }
         });
         this.foundUsers = ko.pureComputed(function () {
            return shellSelf.searchResults().results;
         });
      }

      self.bulk = {
         number: ko.observable(1),
         prefix: ko.observable('user'),
         isVisible: ko.observable(false).toggleable(),
         list: ko.observable(''),
         mode: ko.observable('generating'),
         actions: {
            'Cancel': false,
            'Add': function () {
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
                  return new UserShell({
                     first_name: name,
                     email: name + '-' + self.group.name() + '@example.com',
                     isNewUser: true
                  })
               });

               self.group.participants(self.group.participants().concat(newUsers))
            }
         },
         isGenerating: ko.pureComputed(function () {
            return self.bulk.mode() === 'generating';
         }),
         isList: ko.pureComputed(function () {
            return self.bulk.mode() === 'list';
         }),
         maxNumber: ko.pureComputed(function () {
            var maxNumber = 0;

            if (self.group.participants().length) {
               maxNumber = self.group.participants().map(function (userShell) {
                  return parseInt(userShell.user().first_name.replace(self.bulk.prefix(), '')) || 0;
               }).reduce(function (a, b) {
                  return Math.max(a || 0, b || 0);
               });
            }

            return maxNumber;
         }),
         exampleUserLast: ko.pureComputed(function () {
            return self.bulk.prefix() + '15';
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

         TenjinComms.ajax('/admin/search-groups', {
            data: data,
            onSuccess: function (response) {
               var group = response.results[0] || {};

               // id is only defined on edit, not create
               self.group.id(group.id);

               self.group.name(group.name || '');

               self.group.start_date(group.start_date.split('T')[0]);
               self.group.end_date(group.end_date.split('T')[0]);

               self.group.regex(group.regex);

               if (self.group.regex() === self.openRegex)
                  self.group.participationType('open');
               else if (self.group.regex() === '' || self.group.regex() === null || self.group.regex() === undefined)
                  self.group.participationType('closed');
               else
                  self.group.participationType('custom');

               self.group.participants(group.participants.map(function (p) {
                  return new UserShell(p);
               }));
            }
         });
      };

      if (!self.isNewRecord())
         self.getGroup();

      self.save = function () {
         var payload, pType;

         payload = ko.mapping.toJS(self.group, {ignore: ['participants', 'open', 'participationType']});

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

         TenjinComms.ajax('/admin/save-group', {
            data: payload
         });

         if (params['onSave'])
            params['onSave']();
      };

      self.deleteGroup = function () {
         TenjinComms.ajax('/admin/delete-group', {
            data: {id: self.group.id()}
         });
      };

      self.deleteConfirm = ko.pureComputed(function () {
         return 'Are you sure you wish to delete ' + self.group.name() + '?';
      });

      self.userLink = function (user) {
         return '/admin/edit-person?id=' + user.id;
      };

      self.headerText = ko.pureComputed(function () {
         return self.isNewRecord() ? 'New Group' : 'Edit ' + self.group.name();
      });

      self.addParticipant = function () {
         self.group.participants.push(new UserShell());
      };

      self.removeParticipant = function (userShell) {
         self.group.participants.remove(userShell);
      };
   }
});
