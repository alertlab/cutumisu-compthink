PER_PAGE_DEFAULT = [10, 25, 50, 75];
PAGE_SPAN_DEFAULT = 7;

ko.components.register('paginator', {
   template: '<div class="meta-controls">\
                  <label data-bind="visible: page.sizeOptions.length > 1">\
                     <select class="per-page" data-bind="options: page.sizeOptions, value: page.size"></select>\
                     <span>Per Page</span>\
                  </label>\
              </div>\
              <a href="#" class="prev" data-bind="visible: page.current() > 1, click: page.previous">&#12296; Prev</a>\
              <div class="numbers">\
                  <a href="#" class="first" data-bind="click: function() { page.current(1) }, \
                                                       css: {current: page.current() == 1}">1</a>\
                  <span data-bind="visible: page.hasPrevious">...</span>\
                  <!-- ko foreach: page.numbers -->\
                     <a href="#" data-bind="text: $data, \
                                            click: function() { $parent.page.current($data) },\
                                            css: {current: $parent.page.current() == $data} "></a>\
                  <!-- /ko -->\
                  <span data-bind="visible: page.hasMore">...</span>\
              </div>\
              <a href="#" class="next" data-bind="visible: page.current() < page.totalPages(), click: page.next">Next &#12297;</a>\
              <div class="stats">\
                  <span class="label">Results</span>\
                  <span class="lower-bound" data-bind="text: page.lowerBound"></span>\
                  <span class="dash"> - </span>\
                  <span class="upper-bound" data-bind="text: page.upperBound"></span>\
                  <span class="total-prefix">of</span> \
                  <span class="total" data-bind="text: maxResults"></span>\
              </div>',

   /**
    *
    * @param params
    *          - pageSize:           The initial number of elements to fetch per page. Default: 25
    *          - pageSizeOptions:   An array of possible pageSize values.
    *          - scrollTo:          CSS query of the element to snap back to when the page changes (ie. to reset vertical)
    *          - data:              The observable array to load data inside of
    *          - uri:               The target AJAX endpoint to fetch data from
    *          - sortWith:          An object containing 'field' and 'direction' keys, each with an observable. Direction can be 'asc' or 'desc', field is the core model's field name.
    *          - filter:            Search object that will be added to the parameters
    */
   viewModel: function (params) {
      var self = this;

      self.scrollElementQuery = params['scrollTo'];
      self.filter = params['filter'];

      self.maxResults = ko.observable(0);

      self.data = params['data'];
      self.uri = params['uri'];

      if (!self.data)
         throw 'Must provide "data" param to paginator with a Knockout observableArray.';
      if (!self.uri)
         throw 'Must provide "uri" param to paginator with the uri endpoint to fetch data from.';

      self.page = {
         current: ko.observable(1),
         sizeOptions: params['pageSizeOptions'] || PER_PAGE_DEFAULT,
         size: ko.observable(),
         numberSpan: PAGE_SPAN_DEFAULT, // this should be kept under 10.
         underSpread: ko.pureComputed(function () {
            return Math.floor(self.page.numberSpan / 2)
         }),
         numbers: ko.pureComputed(function () {
            var nums = [];

            /*
             * The first page is hardcoded because it should always be visible (for good UX)
             */
            var lowPage = Math.max(self.page.current() - self.page.underSpread(), 2);

            for (var i = lowPage; i < Math.min(self.page.totalPages() + 1, lowPage + self.page.numberSpan); i++)
               nums.push(i);

            return nums;
         }),
         totalPages: ko.pureComputed(function () {
            return Math.ceil(self.maxResults() / self.page.size());
         }),
         hasPrevious: ko.pureComputed(function () {
            return self.page.current() - self.page.underSpread() > 2;
         }),
         hasMore: ko.pureComputed(function () {
            return self.page.numbers()[self.page.numbers().length - 1] != self.page.totalPages()
               && self.page.totalPages() > 1;
         }),
         lowerBound: ko.pureComputed(function () {
            return ((self.page.current() - 1) * self.page.size()) + 1;
         }),
         upperBound: ko.pureComputed(function () {
            return Math.min(self.page.current() * self.page.size(), self.maxResults());
         }),
         previous: function () {
            self.page.current(self.page.current() - 1);
         },
         next: function () {
            self.page.current(self.page.current() + 1);
         }
      };

      self.page.size(params['pageSize'] ? params['pageSize'] : self.page.sizeOptions[0]);

      self.sortSettings = {
         field: (params['sortWith'].field || ko.observable()).extend({
            notify: 'always'
         }),
         direction: params['sortWith'].direction || ko.observable('asc')
      };

      /// BEHAVIOUR
      self.getData = function () {
         var query;

         query = {
            count: self.page.size(),
            starting: (self.page.current() - 1) * self.page.size(),
            sort_by: self.sortSettings.field(),
            sort_direction: self.sortSettings.direction() ? 'asc' : 'desc'
         };

         if (self.filter)
            query.filter = self.filter;

         // don't snap on the initial load, because it's unexpected
         if (self.scrollElementQuery && self.data.isLoaded()) {
            document.querySelector(self.scrollElementQuery).scrollIntoView();
         }

         self.data.isLoaded(false);

         ajax('post', self.uri, ko.toJSON(query), function (response) {
            self.data(response.results || []);
            self.maxResults(response.all_data_count);
         });
      };

      self.page.current.subscribe(function () {
         self.getData();
      });
      self.page.size.subscribe(function () {
         self.getData();
      });
      self.data.shouldReload.subscribe(function (newVal) {
         if (newVal)
            self.getData();
      });

      Object.keys(self.filter || {}).forEach(function (key) {
         self.filter[key].subscribe(function () {
            self.page.current(1);
            self.data.shouldReload(true);
         })
      });

      self.sortSettings.direction.subscribe(function () {
         self.data.shouldReload(true);
      });

      self.getData();
   }
});