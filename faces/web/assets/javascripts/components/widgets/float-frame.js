ko.components.register('float-frame', {
   template: ' <div class="frame" data-bind="visible: isVisible, template: {nodes: content, data: context}"></div>\
               <div class="overlay" data-bind="visible: isVisible, click: toggleVisibility"></div>',

   // See http://knockoutjs.com/documentation/component-custom-elements.html#passing-markup-into-components
   // for why this is a little different from most components
   viewModel: {
      createViewModel: function (params, componentInfo) {
         params['context'] = params['context'] || ko.dataFor(componentInfo.element);

         /**
          * A widget that hides the content if the user does not have the provided role.
          *
          * @param params
          *        - visibility: the observable to watch for visibility
          *        - context: the KO data context to be available to the interior of this frame. Default: $parent context to this <float-frame>
          * @param content the nodes to place within the main area of the dialog
          * @constructor
          */
         var FloatFrameModel = function (params, content) {
            var self = this;

            self.content = content;
            self.context = params['context'];

            self.isVisible = params['visibility'] || ko.observable(false);

            self.toggleVisibility = function () {
               self.isVisible(!self.isVisible());
            };
         };

         return new FloatFrameModel(params, componentInfo.templateNodes, componentInfo.element);
      }
   }
});