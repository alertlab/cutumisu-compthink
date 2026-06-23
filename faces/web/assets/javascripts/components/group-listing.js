ko.components.register('group-listing', {
   template: {element: 'group-listing-template'},
   /**
    */
   viewModel: function (params) {
      var self = this;

      self.createEditorVisible = ko.observable(false).toggleable();

      var searchLimit = 500;

      self.page = {
         size: ko.observable(),
         number: ko.observable(1).extend({retain: {prompt: false}}),
         maxResults: ko.pureComputed(function () {
            return self.searchResults().all_data_count || 0;
         })
      }
      self.search = {
         name: ko.observable().extend({rateLimit: searchLimit})
      };

      self.searchResults = ko.observable({}).extend({
         loaded: {
            url: '/admin/search-groups',
            params: {
               filter: self.search,
               count: self.page.size,
               page: self.page.number
            }
         }
      });
      self.groups = ko.pureComputed(function () {
         return self.searchResults().results || [];
      })
      // can't sub to searchResults or groups because they fire when page observables change :(
      Object.values(self.search).forEach(function (observable) {
         observable.subscribe(self.page.number.reset)
      })

      self.formatRoles = function (roleList) {
         return roleList.map(function (roleName) {
            return roleName[0].toUpperCase() + roleName.substr(1);
         }).join(', ');
      };

      // BEHAVIOUR
      self.groupCreated = function () {
         self.searchResults.load();
         self.createEditorVisible.toggle();
      };
   }
});
