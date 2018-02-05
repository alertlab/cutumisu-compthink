ko.bindingHandlers.dataUri = {
   init: function (element, valueAccessor, allBindings, viewModel, bindingContext) {
      var reader, value;

      reader = new FileReader();

      // not using addEventListener because poltergeist does not support it.
      reader.onload = function () {
         value = valueAccessor();

         value(reader.result);
      };

      element.addEventListener('change', function (event) {
         var file;

         file = element.files[0];

         if (file)
            reader.readAsDataURL(file);
      }, false);
   }//,
   // update: function (element, valueAccessor, allBindings, viewModel, bindingContext) {
   // This will be called once when the binding is first applied to an element,
   // and again whenever any observables/computeds that are accessed change
   // Update the DOM element based on the supplied values here.
   // }
};