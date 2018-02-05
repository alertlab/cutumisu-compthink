ko.bindingHandlers.leftClick = {
   update: function (element, valueAccessor, all, data, context) {
      ko.utils.setHtml(element, valueAccessor());

      ko.applyBindingsToDescendants(context, element);
   }
};