ko.components.register('user-listing', {
   template: ' <div class="controls">\
                  <div class="filter">\
                     <header>Filter</header>\
                     <div class="simple-fields">\
                        <label>\
                           <span>Name</span>\
                           <input type="text" name="name" data-bind="textInput: search.name"/>\
                        </label>\
                        <label>\
                           <span>Email</span>\
                           <input type="text" name="email" data-bind="textInput: search.email"/>\
                        </label>\
                        <label>\
                           <span>Group</span>\
                           <select name="group" data-bind="optionsCaption: \'- Any -\', \
                                                           options: groupNames, \
                                                           value: search.group" ></select>\
                        </label>\
                     </div>\
                     <fieldset class="roles">\
                        <legend>\
                           Role\
                        </legend>\
                        <label>\
                           <input type="checkbox" data-bind="checked: isAnyRole, \
                                                             enable: anyRoleEnabled, \
                                                             click: selectAllRoles"  />\
                           <span>Any</span>\
                        </label>\
                        <label>\
                           <input type="checkbox" value="admin" data-bind="checked: search.roles"/>\
                           <span>Admin</span>\
                        </label>\
                     </fieldset>\
                  </div>\
                  <a class="add-user-button" \
                     href="#" \
                     data-bind="visible: !createEditorVisible(), click: createEditorVisible.toggle">\
                     <div class="icon">\
                        <img src="" data-bind="attr: {src: window.imagePaths.person}"/>\
                        <span class="plus">+</span>\
                     </div>\
                     Add Person\
                  </a>\
                  <hr>\
                  <a class="download" href="/admin/export_data?type=users">\
                     Download User Data\
                  </a>\
               </div>\
               <div data-bind="visible: !createEditorVisible()">\
                  <p data-bind="visible: users.isLoaded() && users().length == 0">\
                     There are no people yet. \
                  </p>\
                  <loading-spinner params="target: users"></loading-spinner>\
               </div>\
               <div class="user-summaries">\n\
                  <div class="add-user-controls" data-bind="visible: createEditorVisible">\
                     <user-editor params="onSave: personCreated, \
                                          onAbort: createEditorVisible.toggle"></user-editor>\
                  </div>\
                  <label class="sort">\
                     <span>Sort</span>\
                     <select data-bind="value: sortBy, options: sortOptions, optionsText: \'name\', optionsValue: \'value\'"></select>\
                  </label>\
                  <div data-bind="foreach: {data: users, as: \'user\'}">\
                     <user-summary params="user: user"></user-summary>\
                  </div>\
                  <paginator params="data: users, \
                                     uri: \'/admin/search_users\',\
                                     sortWith: sort,\
                                     pageSizeOptions: [10],\
                                     scrollTo: \'user-listing\', \
                                     filter: search"></paginator>\
               </div>',

   /**
    */
   viewModel: function (params) {
      var self = this;

      self.users = ko.observableArray().extend({loadable: true});
      self.createEditorVisible = ko.observable(false).toggleable();
      self.groupNames = JSON.parse(decodeURIComponent(params['groups'])) || [];


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
         group: ko.observable(),
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
      self.personCreated = function () {
         self.createEditorVisible.toggle();
         self.users.shouldReload(true);
      };
   }
});