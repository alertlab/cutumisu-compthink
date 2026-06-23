ko.components.register('group-editor', {
   template: {element: 'group-editor-template'},

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
         this.searchResults = ko.observable({results: []}).extend({
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
