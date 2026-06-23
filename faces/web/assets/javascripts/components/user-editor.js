ko.components.register('user-editor', {
   template: {element: 'user-editor-template'},

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

      self.reset = {
         visible: ko.observable(false).toggleable(),
         actions: {
            'Cancel': false,
            'Reset Permanently': function () {
               TenjinComms.ajax('/admin/reset-clicks', {
                  data: {user_id: self.user.id()},
                  onSuccess: function (response) {
                     self.getUser();
                  }
               });
            }
         }
      }

      self.formClass = ko.pureComputed(function () {
         return 'user-editor-' + (self.isNewRecord() ? 'new' : self.user.id());
      });

      self.deleteConfirm = ko.pureComputed(function () {
         return 'Are you sure you wish to delete ' + self.user.first_name() + ' ' + self.user.last_name() + '?';
      });

      self.groupLink = function (id) {
         return '/admin/edit-group?id=' + id
      };

      self.isNewRecord = ko.pureComputed(function () {
         return !self.user.id();
      });

      self.getUser = function () {
         var data;

         data = {
            count: 1,
            filter: {id: self.user.id()}
         };

         TenjinComms.ajax('/admin/search-users', {
            data: data,
            onSuccess: function (response) {
               var user = response.results[0] || {};

               // id is only defined on edit, not create
               self.user.id(user.id);

               self.user.first_name(user.first_name || '');
               self.user.last_name(user.last_name || '');
               self.user.email(user.email || '');

               self.user.roles(user.roles || []);
               self.user.groups(user.groups || []);


               self.user.puzzles_completed(user.puzzles_completed || []);
            }
         });
      };

      if (!self.isNewRecord())
         self.getUser();

      self.save = function () {
         var uri, ignore;

         ignore = ['puzzles_completed'];

         if (self.isNewRecord()) {
            uri = '/admin/create-user';
            ignore.push('id');
         } else {
            uri = '/admin/update-user';
         }

         var payload = ko.mapping.toJS(self.user, {ignore: ignore});

         TenjinComms.ajax(uri, {
            data: payload
         });
      };

      self.deleteUser = function () {
         TenjinComms.ajax('/admin/delete-user', {
            data: {id: self.user.id()}
         });
      };

      self.headerText = ko.pureComputed(function () {
         return self.isNewRecord() ? 'New Person' : 'Edit ' + self.user.first_name() + ' ' + self.user.last_name();
      });
   }
});