ko.components.register('user-listing', {
   template: ' <expander params="expandedText: \'Filters\', \
                                 collapsedText: \'Filters\',\
                                 defaultExpanded: true">\
                  <div class="user-filter">\
                     <div class="simple-fields">\
                        <label>\
                           <span>Name</span>\
                           <input type="text" name="name" data-bind="textInput: $parent.search.name"/>\
                        </label>\
                        <label>\
                           <span>Email</span>\
                           <input type="text" name="email" data-bind="textInput: $parent.search.email"/>\
                        </label>\
                     </div>\
                     <fieldset class="roles">\
                        <legend>\
                           Role\
                        </legend>\
                        <label>\
                           <input type="checkbox" data-bind="checked: $parent.isAnyRole, \
                                                             enable: $parent.anyRoleEnabled, \
                                                             click: $parent.selectAllRoles"  />\
                           <span>Any</span>\
                        </label>\
                        <label>\
                           <input type="checkbox" value="admin" data-bind="checked: $parent.search.roles"/>\
                           <span>Admin</span>\
                        </label>\
                     </fieldset>\
                  </div>\
               </expander>\
               <label>\
                  <span>Sort</span>\
                  <select data-bind="value: sortBy, options: sortOptions, optionsText: \'name\', optionsValue: \'value\'"></select>\
               </label>\
               <a class="add-user-button" href="#" data-bind="visible: !createEditorVisible(), click: function(){ togglePersonCreator() }">\
                  <div class="icon">\
                     <img src="/assets/images/person.svg"/>\
                     <span class="plus">+</span>\
                  </div>\
                  Add Person\
               </a>\
               <div data-bind="visible: !createEditorVisible()">\
                  <p data-bind="visible: users.isLoaded() && users().length == 0">\
                     There are no people yet. \
                  </p>\
                  <loading-spinner params="target: users"></loading-spinner>\
               </div>\
               <div class="add-user-controls" data-bind="visible: createEditorVisible">\
                  <header>New Person</header>\
                  <user-editor params="onSave: personCreated, \
                                       onAbort: togglePersonCreator"></user-editor>\
               </div>\
               <div class="user-summaries" data-bind="foreach: {data: users, as: \'user\'}">\
                  <user-summary params="user: user"></user-summary>\
               </div>\
               <paginator params="data: users, \
                                  uri: \'/admin/search_users\',\
                                  sortWith: sort,\
                                  pageSizeOptions: [10],\
                                  scrollTo: \'user-listing\', \
                                  filter: search"></paginator>',

   /**
    */
   viewModel: function (params) {
      var self = this;

      self.users = ko.observableArray().extend({loadable: true});
      self.createEditorVisible = ko.observable(false);

      var searchLimit = 500;

      self.sort = {
         field: ko.observable('first_name'),
         direction: ko.observable(true).extend({notify: 'always'})
      };
      self.sortBy = ko.computed({
         write: function (newVal) {
            var field, dir;

            field = newVal.split('__')[0];
            dir = newVal.split('__')[1];

            self.sort.field(field);
            self.sort.direction(dir === 'asc');
         },
         read: function () {
            return self.sort.field() + '__' + self.sort.direction();
         }
      });
      self.sort.direction.subscribe(function () {
         self.users.shouldReload(true);
      });

      self.search = {
         name: ko.observable().extend({rateLimit: searchLimit}),
         email: ko.observable().extend({rateLimit: searchLimit}),
         roles: ko.observableArray()
      };

      self.selectAllRoles = function (viewModel, event) {
         // Needs timeout to delay the eval of whether it is checked
         // Preventing default, returning false, etc don't fix it
         window.setTimeout(function () {
            self.search.roles.removeAll();
         }, 0);
      };

      self.isAnyRole = ko.pureComputed(function () {
         return self.search.roles().length === 0
      });

      self.anyRoleEnabled = ko.pureComputed(function () {
         return self.search.roles().length > 0
      });

      self.sortOptions = [
         {name: 'First Name A-Z', value: 'first_name__asc'},
         {name: 'First Name Z-A', value: 'first_name__desc'},
         {name: 'Last Name A-Z', value: 'last_name__asc'},
         {name: 'Last Name Z-A', value: 'last_name__desc'}
      ];

      self.formatRoles = function (roleList) {
         return roleList.map(function (roleName) {
            return roleName[0].toUpperCase() + roleName.substr(1);
         }).join(', ');
      };

      // BEHAVIOUR
      self.isAddressEnabled = function () {
         return (self.adminVersion() && self.adminConfirmed()) || !self.adminVersion();
      };

      self.togglePersonCreator = function () {
         self.createEditorVisible(!self.createEditorVisible());
      };

      self.toggleBuildingChooser = function () {
         self.buildingChooserVisible(!self.buildingChooserVisible());
      };

      self.toggleVersion = function () {
         self.adminVersion(!self.adminVersion());
         self.adminConfirmed(false);
      };

      self.personCreated = function () {
         self.togglePersonCreator();
         self.users.shouldReload(true);
      };
   }
});