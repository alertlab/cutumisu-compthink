ko.components.register('group-listing', {
   template: ' <div class="controls">\
                  <div class="filter">\
                     <header>Filter</header>\
                     <label>\
                        <span>Name</span>\
                        <input type="search" name="name" data-bind="textInput: search.name"/>\
                     </label>                        \
                  </div>\
                  <button class="add-group-button" data-bind="visible: !createEditorVisible(), click: createEditorVisible">\
                     <div class="icon">\
                        <img src="" alt="" data-bind="attr: {src: window.appData.imagePaths.people}"/>\
                        <span class="plus">+</span>\
                     </div>\
                     Add Group\
                  </button>\
                  <hr>\
                  <form method="post" action="/admin/export-data?type=clicks">\
                     <button type="submit" class="download">\
                        Download Click Data\
                     </button>\
                  </form>\
               </div>\
               <div data-bind="visible: !createEditorVisible()">\
                  <p data-bind="visible: groups() && !groups().length">\
                     There are no groups yet. \
                  </p>\
                  <dialog-busy params="target: searchResults.isLoading"></dialog-busy>\
               </div>\
               <div class="group-summaries">\
                  <div class="add-group-controls" data-bind="visible: createEditorVisible">\
                     <group-editor params="onSave: groupCreated, \
                                           onAbort: createEditorVisible.toggle"></group-editor>\
                  </div>\
                  <div data-bind="foreach: {data: groups, as: \'group\'}">\
                     <group-summary params="group: group"></group-summary>\
                  </div>\
                  <pane-paged params="page: page.number,\
                                      size: page.size,\
                                      sizeOptions: [10],\
                                      maxResults: page.maxResults,\
                                      scrollTo: \'group-listing\'"></pane-paged>\
               </div>',

   /**
    */
   viewModel: function (params) {
      var self = this;

      self.createEditorVisible = ko.observable(false).toggleable();

      var searchLimit = 500;

      self.page = {
         size: ko.observable(),
         number: ko.observable(1).extend({resettable: true}),
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
