ko.bindingHandlers.href = {
   update: function (element, valueAccessor, all, data, context) {
      element.href = valueAccessor();
   }
};
