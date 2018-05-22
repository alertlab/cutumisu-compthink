ko.components.register('basic-form', {
   template: ' <header data-bind="text: headerText()"></header>\
               <form data-bind="submit: save, css: formClass, attr: {autocomplete: autocomplete}">\
                  <div class="form-content" data-bind="template: {nodes: content}">\
                  </div>\
                  <div class="controls">\
                     <input type="button" class="delete" value="Delete" \
                            data-bind="visible: canDelete, click: deleteConfirmVisible.toggle"/>\
                     <div class="standard-buttons">\
                        <a href="#" class="cancel" data-bind="href: cancelHref">Cancel</a>\
                        <input type="submit" value="Save" />\
                     </div>\
                     <float-frame class="delete-confirm" params="visibility: deleteConfirmVisible">\
                        <header>Confirm Deletion</header>\
                        <p data-bind="html: deleteConfirmText">\
                        </p>\
                        <p>\
                           <strong>This action cannot be undone.</strong>\
                        </p>\
                        <a href="#" class="cancel" data-bind="click: $parent.deleteConfirmVisible.toggle">Cancel</a>\
                        <a href="#" class="action" data-bind="click: $parent.delete">Delete Permanently</a>\
                     </float-frame>\
                  </div>\
               </form>',

   /**
    * A generic wrapper form that provides a header and save/cancel/delete options.
    */
   viewModel: {
      // See http://knockoutjs.com/documentation/component-custom-elements.html#passing-markup-into-components
      // for why this is a little different from most components
      createViewModel: function (params, componentInfo) {
         /**
          * An expandable/collapsable pane that toggles between states.
          *
          * @param params
          *        - header: string or observable that will be used as header text.\
          *        - formClass: observable that returns a class for the form itself
          *        - autocomplete: observable or string value ("on", "off") for the autocomplete attribute
          *        - onSave: handler function that is called when the save button is clicked
          *        - onDelete: handler function that is called when the save button is clicked
          *        - canDelete: observable on whether there should be a delete action or not (eg. create vs update)
          *        - deleteConfirm: html or string to be used as the warning message in the delete confirm dialog
          *        - cancelHref: href string that will be used for the cancel button
          * @param content the content of the form (inputs, etc.)
          * @constructor
          */
         var ExpanderModel = function (params, content) {
            var self = this;

            self.headerText = params['header'] || 'Form';
            self.formClass = params['formClass'];
            self.autocomplete = params['autocomplete'] || 'on';

            self.save = params['onSave'];

            self.delete = function () {
               params['onDelete']();

               self.deleteConfirmVisible.toggle();
            };
            self.canDelete = params['canDelete'];
            self.deleteConfirmText = params['deleteConfirm'] || 'Are you sure you wish to delete this?';
            self.cancelHref = params['cancelHref'] || 'Are you sure you wish to delete this?';


            self.deleteConfirmVisible = ko.observable(false).toggleable();
         };

         return new ExpanderModel(params, componentInfo.templateNodes);
      }
   }
});