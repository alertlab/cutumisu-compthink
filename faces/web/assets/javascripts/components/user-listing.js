ko.components.register('user-listing', {
   template: ' <div class="controls">\
                  <div class="filter">\
                     <header>Filter</header>\
                     <div class="simple-fields">\
                        <label>\
                           <span>Name</span>\
                           <input type="search" name="name" data-bind="textInput: search.name"/>\
                        </label>\
                        <label>\
                           <span>Email</span>\
                           <input type="search" name="email" data-bind="textInput: search.email"/>\
                        </label>\
                        <label>\
                           <span>Group</span>\
                           <select name="group" data-bind="optionsCaption: \'- Any -\', \
                                                           options: groupNames, \
                                                           value: search.group" ></select>\
                        </label>\
                     </div>\
                     <input-checklist params="name: \'role\', \
                                              options: allRoles,\
                                              checked: search.roles,\
                                              allLabel: \'Any\'"></input-checklist>\
                  </div>\
                  <button class="add-user-button" \
                     data-bind="hidden: createEditorVisible, click: createEditorVisible.toggle">\
                     <div class="icon">\
                        <img src="" alt="" data-bind="attr: {src: window.appData.imagePaths.person}"/>\
                        <span class="plus">+</span>\
                     </div>\
                     Add Person\
                  </button>\
                  <hr>\
                  <form method="post" action="/admin/export-data?type=users">\
                     <button type="submit" class="download">\
                        Download User Data\
                     </button>\
                  </form>\
               </div>\
               <div class="user-summaries">\
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
                  <div data-bind="hidden: createEditorVisible">\
                     <p data-bind="visible: users() && !users().length">\
                        There are no people yet. \
                     </p>\
                     <dialog-busy params="target: searchResults.isLoading"></dialog-busy>\
                  </div>\
                  <pane-paged params="page: page.number,\
                                      size: page.size,\
                                      sizeOptions: [10],\
                                      maxResults: page.maxResults,\
                                      scrollTo: \'user-listing\'"></pane-paged>\
               </div>',

   /**
    */
   viewModel: function (params) {
      var self = this;

      self.page = {
         size: ko.observable(),
         number: ko.observable(1).extend({resettable: true}),
         maxResults: ko.pureComputed(function () {
            return self.searchResults().all_data_count || 0;
         })
      }
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
         self.searchResults.load();
      });
      var searchLimit = 500;

      self.search = {
         name: ko.observable().extend({rateLimit: searchLimit}),
         email: ko.observable().extend({rateLimit: searchLimit}),
         group: ko.observable(),
         roles: ko.observableArray()
      };
      self.searchResults = ko.observable({}).extend({
         loaded: {
            url: '/admin/search-users',
            params: {
               filter: self.search,
               sort_by: self.sort.field,
               sort_direction: self.sort.direction,
               count: self.page.size,
               page: self.page.number
            }
         }
      });
      self.users = ko.pureComputed(function () {
         return self.searchResults().results || [];
      })

      self.createEditorVisible = ko.observable(false).toggleable();

      self.groupNames = JSON.parse(decodeURIComponent(params['groups'])) || [];
      self.allRoles = JSON.parse(decodeURIComponent(window.appData.roles));

      self.sortOptions = [
         {name: 'First Name A-Z', value: 'first_name__asc'},
         {name: 'First Name Z-A', value: 'first_name__desc'},
         {name: 'Last Name A-Z', value: 'last_name__asc'},
         {name: 'Last Name Z-A', value: 'last_name__desc'}
      ];

      // BEHAVIOUR
      self.personCreated = function () {
         self.createEditorVisible.toggle();
         self.searchResults.load();
      };
   }
});