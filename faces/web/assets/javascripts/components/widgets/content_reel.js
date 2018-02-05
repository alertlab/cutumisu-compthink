ko.components.register('content-reel', {
    template: '<div data-bind="foreach: content">\
                    <img data-bind="attr: {src: $data}" />\
               </div>',

    /**
     * This is done as a KO component to prevent the page from blocking on loading remote-hosted images.
     * Eventually, HTML5 may support the lazyload attribute, but this will do for now.
     *
     * @param content A string list of image urls to load
     */
    viewModel: function (params) {
        var self = this;

        self.content = ko.observableArray(params['content']);
    }
});