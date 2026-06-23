ko.components.register('user-listing', {
   template: {element: 'user-listing-template'},

   /**
    */
   viewModel: function (params) {
      var self = this;

      self.page = {
         size: ko.observable(),
         number: ko.observable(1).extend({retain: {prompt: false}}),
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

      // can't sub to searchResults or users because they fire when page observables change :(
      Object.values(self.search).concat(Object.values(self.sort)).forEach(function (observable) {
         observable.subscribe(self.page.number.reset)
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