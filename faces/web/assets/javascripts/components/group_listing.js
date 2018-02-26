ko.components.register('group-listing', {
   template: ' <a class="add-group-button" href="#" data-bind="visible: !createEditorVisible(), click: function(){ toggleGroupCreator() }">\
                  Add Group\
               </a>\
               <div class="filter">\
                  <div class="simple-fields">\
                     <label>\
                        <span>Filter by Name</span>\
                        <input type="text" name="name" data-bind="textInput: search.name"/>\
                     </label>                        \
                  </div>\
               </div>\
               <div data-bind="visible: !createEditorVisible()">\
                  <p data-bind="visible: groups.isLoaded() && groups().length == 0">\
                     There are no groups yet. \
                  </p>\
                  <loading-spinner params="target: groups"></loading-spinner>\
               </div>\
               <div class="add-group-controls" data-bind="visible: createEditorVisible">\
                  <group-editor params="onSave: groupCreated, \
                                        onAbort: toggleGroupCreator"></group-editor>\
               </div>\
               <div class="group-summaries" data-bind="foreach: {data: groups, as: \'group\'}">\
                  <group-summary params="group: group"></group-summary>\
               </div>\
               <paginator params="data: groups, \
                                  uri: \'/admin/search_groups\',\
                                  filter: search,\
                                  sortWith: sort,\
                                  pageSizeOptions: [10],\
                                  scrollTo: \'group-listing\'"></paginator>',

   /**
    */
   viewModel: function (params) {
      var self = this;

      self.groups = ko.observableArray().extend({loadable: true});
      self.createEditorVisible = ko.observable(false);

      var searchLimit = 500;

      self.sort = {
         field: ko.observable(),
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
         self.groups.shouldReload(true);
      });

      self.sortOptions = [
         {name: 'First Name A-Z', value: 'first_name__asc'},
         {name: 'First Name Z-A', value: 'first_name__desc'},
         {name: 'Last Name A-Z', value: 'last_name__asc'},
         {name: 'Last Name Z-A', value: 'last_name__desc'}
      ];

      self.search = {
         name: ko.observable().extend({rateLimit: searchLimit})
      };

      self.formatRoles = function (roleList) {
         return roleList.map(function (roleName) {
            return roleName[0].toUpperCase() + roleName.substr(1);
         }).join(', ');
      };

      // BEHAVIOUR
      self.toggleGroupCreator = function () {
         self.createEditorVisible(!self.createEditorVisible());
      };

      self.groupCreated = function () {
         self.toggleGroupCreator();
         self.groups.shouldReload(true);
      };
   }
});