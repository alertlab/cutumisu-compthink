ko.bindingHandlers.dynamicHtml = {
   init: function () {
      // Mark this as controlling its own descendants
      // so that KO doesn't try to double-bind on the initial load
      return {'controlsDescendantBindings': true};
   },

   update: function (element, valueAccessor, all, data, context) {
      ko.utils.setHtml(element, valueAccessor());

      ko.applyBindingsToDescendants(context, element);
   }
};
