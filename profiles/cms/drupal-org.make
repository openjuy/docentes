api = 2
core = 8.x

defaults[projects][subdir] = contrib

; Contributed themes
projects[bootstrap] = "3.17"
projects[bootstrap][patch][] = "https://git.drupalcode.org/project/bootstrap/commit/55097255eda34eae9f1713922f42cba6e00e6381.patch"

; Installation Modules
projects[better_normalizers] = "1.0-beta3"
projects[default_content] = "1.0-alpha6"
projects[default_content][patch][] = "https://www.drupal.org/files/issues/default_content-drush_dcemr-2703607-17.patch"
projects[default_content][patch][] = "https://www.drupal.org/files/issues/naturalize-content-language-2900089-2.patch"

; Optional modules
projects[redirect] = "1.3"
projects[admin_toolbar] = "1.27"
projects[glazed_helper][subdir] = contrib

; CMS Core
; -------

projects[block_class] = "1.0"
projects[ctools] = "3.2"
projects[dropzonejs] = "2.0-alpha4"
projects[entity_browser] = "2.1"
# projects[entity_browser][patch][] = "https://www.drupal.org/files/issues/toolbar-tray-hiding-fluid-dialog-title-bar-2831656-4.patch"
projects[entity_embed] = "1.0-beta3"
projects[embed] = "1.0"
projects[field_formatter_class] = "1.1"
projects[field_group] = "1.0"
projects[file_browser][type] = "module"
projects[file_browser][version] = "1.x-dev"
projects[file_browser][patch][] = "https://www.drupal.org/files/issues/support-cardinality-in-views-selection-2917823-12.patch.txt"
projects[file_browser][patch][] = "https://www.drupal.org/files/issues/2018-03-26/2825555-8.patch"
projects[image_hover_effects] = "1.1"
projects[libraries] = "3.0-alpha1"
projects[pathauto] = "1.4"
projects[smart_trim] = "1.1"
projects[token] = "1.5"

; Libraries

libraries[dropzone][type] = library
libraries[dropzone][download][type] = get
libraries[dropzone][download][url] = https://github.com/enyo/dropzone/archive/v5.1.1.zip
libraries[masonry][type] = library
libraries[masonry][download][type] = get
libraries[masonry][download][url] = https://github.com/desandro/masonry/archive/v4.2.0.zip
libraries[imagesloaded][type] = library
libraries[imagesloaded][download][type] = get
libraries[imagesloaded][download][url] = https://github.com/desandro/imagesloaded/archive/v4.1.4.zip
projects[cms_core][subdir] = cms

; CMS Blog
; -------

projects[tagclouds] = "1.0"
projects[views_bootstrap] = "3.1"
projects[sooperthemes_gridstack] = "1.1"
projects[cms_blog][subdir] = cms

; CMS Events
; -------
projects[cms_events][subdir] = cms
projects[cms_news][subdir] = cms

; CMS Portfolio
; -------

projects[formatter_field] = "1.1"
projects[views_field_formatter] = "1.9"
projects[views_bootstrap] = "3.1"
projects[sooperthemes_gridstack] = "1.1"
projects[cms_portfolio][subdir] = cms
