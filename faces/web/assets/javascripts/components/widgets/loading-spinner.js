ko.components.register('loading-spinner', {
   template: ' <div data-bind="if: isLoading">\
                  <div class="message-container">\
                     <div data-bind="template: {nodes: content}">\
                     </div>\
                     <!-- ko if: content.length == 0 -->\
                        <span data-bind="text: message"></span><span data-bind="text: dots"></span>\
                     <!-- /ko -->\
                  </div>\
                  <div class="overlay"></div>\
               </div>',

   viewModel: {
      // See http://knockoutjs.com/documentation/component-custom-elements.html#passing-markup-into-components
      // for why this is a little different from most components
      createViewModel: function (params, componentInfo) {
         /**
          * A widget to show that something is in process of loading. Provides a simple loading message,
          * or displays HTML child nodes, if this tag has contents.
          *
          * @param params
          *        - target: An observable to use instead of its own internal state.
          *        - message: Optionsal text to display as the simple loading message. Default: "Loading"
          * @param content optional html content to show or hide within the loading spinner
          * @constructor
          */
         var LoadingSpinnerModel = function (params, content) {
            var self = this;

            self.target = params.target;
            self.content = content;
            self.message = ko.observable(params.message || 'Loading');
            self.dots = ko.observable('...');
            self.dotSpeed = 250;

            self.isLoading = ko.pureComputed(function () {
               return !self.target.isLoaded() || self.target.shouldReload();
            });

            self.updateDots = function () {
               var newDots, nDots;

               nDots = (self.dots().length + 1) % 4;

               newDots = '';

               for (var i = 0; i < nDots; i++) {
                  newDots = newDots + '.';
               }

               self.dots(newDots);
            };

            self.toggleInterval = function (isLoading) {
               if (isLoading)
                  self.dotInterval = window.setInterval(self.updateDots, self.dotSpeed);
               else
                  window.clearInterval(self.dotInterval);
            };

            self.isLoading.subscribe(self.toggleInterval);

            self.toggleInterval(true);
         };

         return new LoadingSpinnerModel(params, componentInfo.templateNodes);
      }
   }
});