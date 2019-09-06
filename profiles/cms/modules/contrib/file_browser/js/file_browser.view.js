/**
 * @file file_browser.view.js
 */

(function ($, _, Backbone, Drupal) {

  "use strict";

  /**
   * Renders the file counter based on our internally tracked count.
   */
  function renderFileCounter () {
    $('.file-browser-file-counter').each(function () {
      $(this).remove();
    });
    var counter = [];
    $('.entities-list [data-entity-id]').each(function () {
      if (counter[this.dataset.entityId]) {
        ++counter[this.dataset.entityId];
      }
      else {
        counter[this.dataset.entityId] = 1;
      }
    });
    for (var id in counter) {
      var count = counter[id];
      if (count > 0) {
        var text = Drupal.formatPlural(count, 'Selected one time', 'Selected @count times');
        var $counter = $('<div class="file-browser-file-counter"></div>').text(text);
        $('[name="entity_browser_select[file:' + id + ']"]').closest('.grid-item').find('.grid-item-info').prepend($counter);
      }
    }
  }

  /**
   * Adjusts the padding on the body to account for the fixed actions bar.
   */
  function adjustBodyPadding () {
    setTimeout(function () {
      $('body').css('padding-bottom', $('.file-browser-actions').outerHeight() + 'px');
    }, 2000);
  }

  /**
   * Initializes Masonry for the view widget.
   */
  Drupal.behaviors.fileBrowserMasonry = {
    attach: function (context) {
      var $item = $('.grid-item', context);
      var $view = $item.parent().once('file-browser-init');
      if ($view.length) {
        $view.prepend('<div class="grid-sizer"></div><div class="gutter-sizer"></div>');

        // Indicate that images are loading.
        $view.append('<div class="ajax-progress ajax-progress-fullscreen">&nbsp;</div>');
        $view.imagesLoaded(function () {
          // Save the scroll position.
          var scroll = document.body.scrollTop;
          // Remove old Masonry object if it exists. This allows modules like
          // Views Infinite Scroll to function with File Browser.
          if ($view.data('masonry')) {
            $view.masonry('destroy');
          }
          $view.masonry({
            columnWidth: '.grid-sizer',
            gutter: '.gutter-sizer',
            itemSelector: '.grid-item',
            percentPosition: true,
            isFitWidth: true
          });
          // Jump to the old scroll position.
          document.body.scrollTop = scroll;
          // Add a class to reveal the loaded images, which avoids FOUC.
          $item.addClass('item-style');
          $view.find('.ajax-progress').remove();
        });
      }
    }
  };

  /**
   * Tracks when entities have been added or removed in the multi-step form,
   * and displays that information on each grid item.
   */
  Drupal.behaviors.fileBrowserEntityCount = {
    attach: function (context) {
      adjustBodyPadding();
      renderFileCounter();
      // Indicate when files have been selected.
      var $entities = $('.entities-list', context).once('file-browser-add-count');
      if ($entities.length) {
        $entities.bind('add-entities', function (event, entity_ids) {
          adjustBodyPadding();
          renderFileCounter();
        });

        $entities.bind('remove-entities', function (event, entity_ids) {
          adjustBodyPadding();
          renderFileCounter();
        });
      }
    }
  };

  var Selection = Backbone.View.extend({

    events: {
      'click .grid-item': 'onClick',
      'dblclick .grid-item': 'onClick'
    },

    initialize: function () {
      // This view must be created on an element which has this attribute.
      // Otherwise, things will blow up and rightfully so.
      this.uuid = this.el.getAttribute('data-entity-browser-uuid');

      // If we're in an iFrame, reach into the parent window context to get the
      // settings for this entity browser.
      var settings = (frameElement ? parent : window).drupalSettings.entity_browser[this.uuid];

      // Assume a single-cardinality field with no existing selection.
      this.count = settings.count || 0;
      this.cardinality = settings.cardinality || 1;
    },

    deselect: function (item) {
      this.$(item)
        .removeClass('checked')
        .find('input[name ^= "entity_browser_select"]')
        .prop('checked', false);
    },

    /**
     * Deselects all items in the entity browser.
     */
    deselectAll: function () {
      // Create a version of deselect() that can be called within each() with
      // this as its context.
      var _deselect = jQuery.proxy(this.deselect, this);

      this.$('.grid-item').each(function (undefined, item) {
        _deselect(item);
      });
    },

    select: function (item) {
      this.$(item)
        .addClass('checked')
        .find('input[name ^= "entity_browser_select"]')
        .prop('checked', true);
    },

    /**
     * Marks unselected items in the entity browser as disabled.
     */
    lock: function () {
      this.$('.grid-item:not(.checked)').addClass('disabled');
    },

    /**
     * Marks all items in the entity browser as enabled.
     */
    unlock: function () {
      this.$('.grid-item').removeClass('disabled');
    },

    /**
     * Handles click events for any item in the entity browser.
     *
     * @param {jQuery.Event} event
     */
    onClick: function (event) {

      var chosen_one = this.$(event.currentTarget);
      
      if (chosen_one.hasClass('disabled')) {
        return false;
      }
      else if (this.cardinality === 1) {
        this.deselectAll();
        this.select(chosen_one);

        if (event.type === 'dblclick') {
          this.$('.form-actions input').click().prop('disabled', true);
        }
      }
      else if (chosen_one.hasClass('checked')) {
        this.deselect(chosen_one);
        this.count--;
        this.unlock();
      }
      else {
        this.select(chosen_one);

        // If cardinality is unlimited, this will never be fulfilled. Good.
        if (++this.count === this.cardinality) {
          this.lock();
        }
      }
    }

  });

  Drupal.behaviors.fileBrowserSelection = {

    getElement: function (context) {
      // If we're in a document context, search for the first available entity
      // browser form. Otherwise, ensure that the context is itself an entity
      // browser form.
      return $(context)[context === document ? 'find' : 'filter']('form[data-entity-browser-uuid]').get(0);
    },

    attach: function (context) {
      var element = this.getElement(context);
      if (element) {
        $(element).data('view', new Selection({ el: element }));
      }
    },

    detach: function (context) {
      var element = this.getElement(context);

      if (element) {
        var view = $(element).data('view');

        if (view instanceof Selection) {
          view.undelegateEvents();
        }
      }
    }

  };

  Drupal.behaviors.changeOnKeyUp = {

    onKeyUp: _.debounce(function () {
      $(this).trigger('change');
    }, 600),

    attach: function (context) {
      $('.keyup-change', context).on('keyup', this.onKeyUp);
    },

    detach: function (context) {
      $('.keyup-change', context).off('keyup', this.onKeyUp);
    }

  };

})(jQuery, _, Backbone, Drupal);
