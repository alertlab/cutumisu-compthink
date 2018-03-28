ko.components.register('search-select', {
   template: ' <input type="text" \
                      autocomplete="off" \
                      placeholder="Type to search" \
                      data-bind="textInput: searchText, \
                                 attr: {name: inputName},\
                                 event: {\
                                         focus: function() {hasFocus(true)}, \
                                         blur: function(){hasFocus(false)}, \
                                         keydown: keyHandler\
                                 }" />\
               <div class="results-section" data-bind="visible: optionsVisible,\
                                                       event: {mouseleave: function(){ highlighted(undefined) }},\
                                                       foreach: searchOptions">\
                     <div data-bind="click: function(){ $parent.select($data)}, \
                                     css: {highlighted: $parent.isHighlighted($data)},\
                                     event: {mouseover: function(){ $parent.highlighted($data) }},\
                                     text: $parent.labeller($data)">\
                     </div>\
               </div>',

   // TODO: it should allow user to choose non-listed value (ie. write it in) when limitOptions flag is disabled (enabled by default)

   /**
    * A selector input widget that you can type in to filter results.
    *
    * Sends a POST request to the given URI when text is entered, after a short delay.
    * The POST target is expected to return the options for selection. One of those results will be selected by the user
    * loaded into the observable provided in selectedObservable.
    *
    *  @param params
    *          - searchUri: the uri that will receive the POST request
    *          - selectedObservable: the observable to be populated with the selection choice
    */
   viewModel: function (params) {
      var self = this;

      self.hasFocus = ko.observable().extend({
         rateLimit: {timeout: 100, method: "notifyWhenChangesStop"}
      });

      self.highlighted = ko.observable();
      self.isHighlighted = function (data) {
         return self.highlighted() === data;
      };

      self.inputName = params['name'];

      self.searchUri = params['uri'] || explode('Must provide param "uri" to text-select component.');
      self.selectedOption = params['selectedObservable'] || explode('Must provide param "selectedObservable" to text-select component.');
      self.labeller = params['labelWith'] || function (data) {
         return ko.mapping.toJSON(data);
      };

      self.searchOptions = ko.observableArray([]);
      self.searchDisabled = false;
      self.optionsVisible = ko.pureComputed(function () {
         return self.searchOptions().length > 0 && self.hasFocus();
      });
      self.searchLoading = ko.observable();

      var defaultValue = self.selectedOption() ? self.labeller(self.selectedOption()) : undefined;

      self.searchText = ko.observable(defaultValue).extend({
         rateLimit: {timeout: 250, method: "notifyWhenChangesStop"}
      });

      self.searchText.subscribe(function () {
         self.getOptions();
      });

      self.select = function (data) {
         self.selectedOption(data);

         self.searchDisabled = true;
         self.searchText(self.labeller(self.selectedOption())); // TODO: probably should be a writable computed
         self.clearOptions();

         self.searchDisabled = false;
      };

      self.clearOptions = function () {
         self.searchOptions([]);
      };

      self.getOptions = function () {
         if (self.searchDisabled)
            return;

         if (self.searchText().length === 0) {
            self.clearOptions();
            return;
         }

         // TODO: make this search {fields: {all: searchText()}}
         ajax('post', self.searchUri, ko.mapping.toJSON({filter: {name: self.searchText()}}), function (response) {
            if (response.messages) {
               window.flash('notice', response.messages);
            }

            self.searchOptions(response.results);
         });
      };

      self.keyHandler = function (viewModel, event) {
         var isEnterKey, isArrowDownKey, isArrowUpKey;

         // key is not supported of all browers, but keyCode is, so always fall back
         isEnterKey = event.key === 'Enter' || event.keyCode === 13;
         isArrowDownKey = event.key === 'ArrowDown' || event.keyCode === 40;
         isArrowUpKey = event.key === 'ArrowUp' || event.keyCode === 38;

         // returning false for uparrow and down to prevent cursor moving to end of line in some browsers
         // and for Enter to prevent form submission.
         if (isEnterKey) {
            if (self.highlighted())
               self.select(self.highlighted());
            event.preventDefault();
            event.bubbles = false;
            return false;
         } else if (isArrowDownKey || isArrowUpKey) {
            var currentElement, currentElementIndex, nextElementIndex, nextElement, indexModifier;

            currentElement = self.highlighted();
            currentElementIndex = self.searchOptions().indexOf(currentElement);

            indexModifier = isArrowDownKey ? 1 : -1;

            nextElementIndex = (currentElementIndex + indexModifier) % self.searchOptions().length;
            nextElement = self.searchOptions()[nextElementIndex];

            self.highlighted(nextElement);

            return false;
         }

         // otherwise, do tha normal thang.
         return true;
      }
   }
});