ko.components.register('input-checklist', {
   template: ' <label data-bind="if: allLabelVisible">\
                  <input type="checkbox" \
                         data-bind="checked: isAllChecked,\
                                    enable: isAllEnabled,\
                                    click: selectAll" />\
                  <span data-bind="text: allLabel"></span>\
               </label>\
               <div data-bind="foreach: values">\
                  <label>\
                     <input type="checkbox" data-bind="checkedValue: $data, checked: $parent.checkedItems">\
                     <span data-bind="text: $parent.checkboxLabel($data)"></span>\
                  </label>\
               </div>',

   /**
    * An input widget that provides a list of checkboxes
    *
    *  @param params
    *          - checkedItems: Observable list of selected items.
    *          - values: Observable list or array of all possible items.
    *          - valueText: Object field name to read for the display label if the values list contains complex objects.
    *          - allLabel: The label to use for an "all" option. Checking this option will uncheck all other options
    *                      and clear the checkedItems list. Provide true to get a default label. This label will not
    *                      display if there is only one option in `values`. Default: false.
    */
   viewModel: function (params) {
      var self = this;

      self.checkedItems = params['checkedItems'];
      self.values = params['values'];
      self.valueText = params['valueText'];
      self.allLabel = params['allLabel'];

      // you can provide true to indicate to use the default label
      if (self.allLabel === true)
         self.allLabel = 'All';

      self.checkboxLabel = function (datum) {
         return self.valueText ? datum[self.valueText] : datum;
      };

      self.checkedItems.subscribe(function () {
         if (ko.unwrap(self.checkedItems).length === ko.unwrap(self.values).length
            && ko.unwrap(self.checkedItems).length)
            self.selectAll();
      });

      self.selectAll = function (viewModel, event) {
         if (self.allLabelVisible())
         // Needs timeout to delay the eval of whether it is checked
         // Preventing default, returning false, etc don't fix it
            window.setTimeout(function () {
               self.checkedItems.removeAll();
            }, 0);
      };

      self.allLabelVisible = ko.pureComputed(function () {
         return ko.unwrap(self.values).length > 1;
      });

      self.isAllChecked = ko.pureComputed(function () {
         return self.checkedItems().length === 0
      });

      self.isAllEnabled = ko.pureComputed(function () {
         return self.checkedItems().length > 0
      });
   }
});