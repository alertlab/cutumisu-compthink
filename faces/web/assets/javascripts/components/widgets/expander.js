ko.components.register('expander', {
   template: '<a href="#" data-bind="click: function(){ isVisible(!isVisible()) }">\
                    <span data-bind="html: labelText"></span>\
                    <span data-bind="html: labelArrow"></span>\
               </a>\
               <div data-bind="visible: isVisible, template: {nodes: content}">\
               </div>',

   /**
    * A control for expanding and collapsing a segment of the document.
    */
   viewModel: {
      // See http://knockoutjs.com/documentation/component-custom-elements.html#passing-markup-into-components
      // for why this is a little different from most components
      createViewModel: function (params, componentInfo) {
         /**
          * An expandable/collapsable pane that toggles between states.
          *
          * @param params
          *        - expandedObservable: An observable to use instead of its own internal state.
          *        - defaultExpanded: The default value to use if providing its own internal state
          *        - expandedText: The text to display while content is expanded.
          *        - collapsedText: The text to display while the content is collapsed
          * @param content the content to expand and collapse
          * @constructor
          */
         var ExpanderModel = function (params, content) {
            var self = this;

            self.content = content;
            self.isVisible = params['expandedObservable'] || ko.observable(true);

            if (params['defaultExpanded'] != null)
               self.isVisible(params['defaultExpanded']);

            self.expandedText = (params['expandedText'] || 'Hide');
            self.collapsedText = (params['collapsedText'] || 'Show');

            self.expandedArrow = '\u25Be';
            self.collapsedArrow = '\u25B4';

            self.labelText = ko.computed(function () {
               return ko.utils.unwrapObservable(self.isVisible() ? self.expandedText : self.collapsedText);
            });

            self.labelArrow = ko.computed(function () {
               return ko.utils.unwrapObservable(self.isVisible() ? self.expandedArrow : self.collapsedArrow);
            });
         };

         return new ExpanderModel(params, componentInfo.templateNodes);
      }
   }
});