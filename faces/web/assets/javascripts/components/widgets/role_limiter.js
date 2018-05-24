ko.components.register('role-limiter', {
   template: ' <div data-bind="visible: hasRequiredRole, template: {nodes: content}">\
               </div>',

   viewModel: {
      // See http://knockoutjs.com/documentation/component-custom-elements.html#passing-markup-into-components
      // for why this is a little different from most components
      createViewModel: function (params, componentInfo) {
         /**
          * A widget that hides the content if the user does not have the provided role.
          *
          * WARNING: Do NOT rely on this for actual data security. It only hides widgets for UI-tweaking purposes.
          *
          * @param params
          *        - role: the name of the role that the user must have to display the interior widgets
          * @param content the content to expand and collapse
          * @param element the DOM node that will be bound to
          * @constructor
          */
         var RoleLimiterModel = function (params, content, element) {
            var self = this;

            self.content = content;

            if (!params['role'])
               throw('Must provide a role to params');

            self.hasRequiredRole = ko.pureComputed(function () {
               var user = window.currentUser();

               return user && user.roles().indexOf(params['role']) > -1
            });
         };

         return new RoleLimiterModel(params, componentInfo.templateNodes, componentInfo.element);
      }
   }
});