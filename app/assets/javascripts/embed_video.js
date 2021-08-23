(function() {
  "use strict";
  App.EmbedVideo = {
    initialize: function() {
      $(".js-embedded-video").each(function() {
        var code;
        code = $(this).data("video-code");
        $(this).html(code);
      });
    }
  };
}).call(this);
