ko.components.register('float-frame', {
   template: ' <div class="frame" data-bind="visible: isVisible, template: {nodes: content}"></div>\
               <div class="overlay" data-bind="visible: isVisible, click: toggleVisibility"></div>',

   // See http://knockoutjs.com/documentation/component-custom-elements.html#passing-markup-into-components
   // for why this is a little different from most components
   viewModel: {
      /**
       * A widget that hides the content if the user does not have the provided role.
       *
       * @param params
       *        - visibility: the observable to watch for visibility
       * @param content the content to expand and collapse
       * @param element the DOM node that will be bound to
       * @constructor
       */
      createViewModel: function (params, componentInfo) {
         var FloatFrameModel = function (params, content, element) {
            var self = this;

            self.content = content;

            self.isVisible = params['visibility'] || ko.observable(false);

            self.toggleVisibility = function () {
               self.isVisible(!self.isVisible());
            };
         };

         return new FloatFrameModel(params, componentInfo.templateNodes, componentInfo.element);
      }
   }
});