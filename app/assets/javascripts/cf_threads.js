cforum.cf_threads = {
  views: {
    tags: {
      tag: "<li class=\"tag label label-info\" style=\"display:none\"><input name=\"tags[]\" type=\"hidden\" value=\"{{tag}}\"><i class=\"icon icon-trash del-tag\"> </i> {{tag}}</li>"
    }
  },

  tags: {
    autocomplete_timeout: null,

    autocomplete: function() {
      cforum.cf_threads.tags.autocomplete_timeout = null;

      var $tag_input = $("#tags-input");

      if($tag_input.val().length >= 2) {
        $.get(
          cforum.baseUrl + '/' + cforum.currentForum.slug + '/tags.json',
          's=' + encodeURIComponent($tag_input.val()),
          function(data) {
            if(data.length > 0) {
              var val = $tag_input.val();
              var val_l = $.trim(val.toLowerCase());

              for(var i = 0; i < data.length; ++i) {
                if(val_l == data[i].tag_name.toLowerCase()) {
                  return;
                }
              }

              var tag = data[0].tag_name;

              $tag_input.val(val + tag.substring(val.length));
              $tag_input.selection(val.length, tag.length);
            }
          }
        );

      }
    },

    addTag: function(ev) {
      ev.preventDefault();
      var $this = $(this);

      if($.trim($this.val()) && $this.val() != ',') {
        var val = $.trim($this.val().replace(/,.*/, '').toLowerCase());
        cforum.cf_threads.tags.appendTag(val);

        v = $this.val();
        $this.val(v.indexOf(",") == -1 ? '' : v.replace(/.*,?/, ''));

        if(ev.type == 'focusout') {
          $this.focus();
        }
      }

    },

    appendTag: function(tag) {
      var list = $("#tags-list");
      list.append(Mustache.render(cforum.cf_threads.views.tags.tag, {tag: tag}));
      list.find(".tag").last().fadeIn('fast');
    },

    removeTag: function(ev) {
      var $this = $(ev.target);

      if($this.hasClass('del-tag')) {
        ev.preventDefault();
        $this.closest("li.tag").fadeOut('fast', function() { $(this).remove(); });
      }
    },

    initTags: function() {
      tags = $("#tags-input").val().split(",").map(function(x) {return $.trim(x);}).filter(function(x) {
        if(x) {
          return true;
        }

        return false;
      });

      for(var i = 0; i < tags.length; ++i) {
        cforum.cf_threads.tags.appendTag(tags[i]);
      }

      $("#tags-input").val("");
    },

    handleKeyUp: function(ev) {
      if(cforum.cf_threads.tags.autocomplete_timeout) {
        window.clearTimeout(cforum.cf_threads.tags.autocomplete_timeout);
      }

      if(ev.keyCode == 188) {
        cforum.cf_threads.tags.addTag.call($("#tags-input"), ev);
      }
      else {
        cforum.cf_threads.tags.autocomplete_timeout = window.setTimeout(cforum.cf_threads.tags.autocomplete, 800);
      }
    },

    init: function() {
      $("#tags-input").on('keyup', cforum.cf_threads.tags.handleKeyUp);
      $("#tags-input").on('focusout', cforum.cf_threads.tags.addTag);
      $("#tags-list").click(cforum.cf_threads.tags.removeTag);

      cforum.cf_threads.tags.initTags();
    }
  },

  new: function() {
    cforum.cf_threads.tags.init();
  },
  create: function() {
    cforum.cf_threads.tags.init();
  }
};

/* eof */