ko.components.register('confirm-dialog', {
   template: ' <float-frame params="visibility: isVisible">\
                  <header data-bind="text: headerText">Add Multiple Participants</header>\
                  <div class="dialog-contents" data-bind="template: {nodes: content, data: context}">\
                  </div>\
                  <div class="controls">\
                     <a href="#" class="cancel" data-bind="click: toggleVisibility, text: cancelText"></a>\
                     <a href="#" class="confirm" data-bind="click: onConfirm, text: confirmText"></a>\
                  </div>\
               </float-frame>',


   // See http://knockoutjs.com/documentation/component-custom-elements.html#passing-markup-into-components
   // for why this is a little different from most components
   viewModel: {
      createViewModel: function (params, componentInfo) {
         params['context'] = params['context'] || ko.dataFor(componentInfo.element);

         /**
          * A widget that hides the content if the user does not have the provided role.
          *
          * @param params
          *        - visibility: the observable to watch & control for whether this dialog is visible
          *        - context: the KO data context to be available to the interior of this dialog. Default: $parent context to this <confirm-dialog>
          *        - header: the text to display as the title of the dialog. Default: "Confirm"
          *        - confirm: text for the button to accept the action
          *        - cancel: text for the button to cancel the action and dismiss the dialog
          * @param content the nodes to place within the main area of the dialog
          * @constructor
          */
         var FloatFrameModel = function (params, content) {
            var self = this;

            self.content = content;
            self.context = params['context'];

            self.headerText = params['header'] || 'Confirm';

            self.isVisible = params['visibility'] || ko.observable(false);

            self.confirmText = params['confirm'] || 'Ok';
            self.cancelText = params['cancel'] || 'Cancel';

            self.toggleVisibility = function () {
               self.isVisible(!self.isVisible());
            };

            self.onConfirm = function () {
               params['onConfirm']();

               self.toggleVisibility();
            }
         };

         return new FloatFrameModel(params, componentInfo.templateNodes, componentInfo.element);
      }
   }
});
