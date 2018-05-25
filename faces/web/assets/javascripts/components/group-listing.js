ko.components.register('group-listing', {
   template: ' <div class="controls">\
                  <div class="filter">\
                     <header>Filter</header>\
                     <label>\
                        <span>Name</span>\
                        <input type="text" name="name" data-bind="textInput: search.name"/>\
                     </label>                        \
                  </div>\
                  <a class="add-group-button" href="#" data-bind="visible: !createEditorVisible(), click: createEditorVisible">\
                     <div class="icon">\
                        <img src="" data-bind="attr: {src: window.appData.imagePaths.people}"/>\
                        <span class="plus">+</span>\
                     </div>\
                     Add Group\
                  </a>\
                  <hr>\
                  <a class="download" href="/admin/export_data?type=clicks">\
                     Download Click Data\
                  </a>\
               </div>\
               <div data-bind="visible: !createEditorVisible()">\
                  <p data-bind="visible: groups.isLoaded() && groups().length == 0">\
                     There are no groups yet. \
                  </p>\
                  <loading-spinner params="target: groups"></loading-spinner>\
               </div>\
               <div class="group-summaries">\
                  <div class="add-group-controls" data-bind="visible: createEditorVisible">\
                     <group-editor params="onSave: groupCreated, \
                                           onAbort: createEditorVisible.toggle"></group-editor>\
                  </div>\
                  <div data-bind="foreach: {data: groups, as: \'group\'}">\
                     <group-summary params="group: group"></group-summary>\
                  </div>\
                  <paginator params="data: groups, \
                                     uri: \'/admin/search_groups\',\
                                     filter: search,\
                                     sortWith: sort,\
                                     pageSizeOptions: [10],\
                                     scrollTo: \'group-listing\'"></paginator>\
               </div>',

   /**
    */
   viewModel: function (params) {
      var self = this;

      self.groups = ko.observableArray().extend({loadable: true});
      self.createEditorVisible = ko.observable(false).toggleable();

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
      self.groupCreated = function () {
         self.groups.shouldReload(true);
         self.createEditorVisible.toggle();
      };
   }
});