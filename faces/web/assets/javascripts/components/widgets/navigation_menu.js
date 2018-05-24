ko.components.register('navigation-menu', {
   template: ' <ul data-bind="foreach: {data: optionsList, as: \'option\'} ">\
                  <li data-bind="css: $parent.itemStyling(option)">\
                     <!--  ko if: $parent.isPureText(option) -->\
                     <img src="" data-bind="attr: {src: option.icon}"/><span data-bind="text: option.text"></span>\
                     <!-- /ko -->\
                     <a href="#" data-bind="attr: {href: option.url}, visible: option.url">\
                        <img src="" data-bind="attr: {src: option.icon}" /><span data-bind="text: option.text"></span>\
                     </a>\
                     <div data-bind="dynamicHtml: option.tag">\
                     </div>\
                     <!--  ko if: option.suboptions -->\
                        <navigation-menu params="options: option.suboptions"></navigation-menu>\
                     <!-- /ko -->\
                  </li>\
               </ul>',

   /**
    * A control for expanding and collapsing a segment of the document.
    */
   viewModel: function (params) {
      var self = this;

      self.options = params['options'];

      self.optionsList = Object.keys(self.options).map(function (optionName) {
         var props = self.options[optionName];

         if (typeof props === 'string')
            props = {url: props};

         return {
            text: optionName,
            url: props.url,
            icon: props.icon,
            tag: props.tag,
            suboptions: props.options
         }
      });

      self.itemStyling = function (option) {
         var styles = {'current-page': option.url === window.location.pathname};

         if (option.text)
            styles[option.text.replace(/[\W\s]+/, '-').toLowerCase()] = true;

         return styles
      };

      self.isPureText = function (option) {
         return option.text && !option.url && !option.tag;
      };
   }
});