/**
 * @file
 * Customize features selection.
 */

(function ($) {

  'use strict';

  $('div[data-drupal-selector="edit-cms-modules"]')
    .find('.js-form-item')
    .click(function (event) {
      var $this = $(this);
      var $checkBox = $this.find('input[type="checkbox"]');
      var checked = $checkBox.prop('checked');
      var tagName = event.target.tagName.toLowerCase();
      if (tagName != 'input' && tagName != 'label') {
        checked = !checked;
        $checkBox.prop('checked', checked);
      }
      $this.toggleClass('cms-feature-selected', checked);
    });

})(jQuery);
