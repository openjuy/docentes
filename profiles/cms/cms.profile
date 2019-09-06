<?php

/**
 * @file
 * Enables modules and site configuration for a Glazed CMS site installation.
 */

use Drupal\contact\Entity\ContactForm;
use Drupal\Core\Form\FormStateInterface;

/**
 * Implements hook_form_FORM_ID_alter().
 *
 * Allows the profile to alter the site configuration form.
 */
function cms_form_install_configure_form_alter(&$form, FormStateInterface $form_state) {
  $form['site_information']['site_name']['#default_value'] = t('Glazed Drupal CMS');
}

/**
 * Implements hook_install_tasks().
 */
function cms_install_tasks(&$install_state) {

  $tasks = [
    'cms_module_configure' => [
      'display_name' => t('Choose CMS features'),
      'type' => 'form',
      'function' => 'Drupal\cms\Form\ModuleConfigureForm',
    ],
    'cms_module_install' => [
      'display_name' => t('Install additional modules'),
      'type' => 'batch',
    ],
  ];

  return $tasks;
}

/**
 * Installs the CMS modules in a batch.
 *
 * @param array $install_state
 *   The install state.
 *
 * @return array
 *   A batch array to execute.
 */
function cms_module_install(array &$install_state) {

  $batch = [];
  if (count($install_state['cms_additional_modules']) > 0) {

    $modules = $install_state['cms_additional_modules'];
    array_unshift($modules, 'cms_core');

    // Default content module installs content by implementing
    // hook_modules_installed(). Since CMS modules have no dependency on Default
    // content we need to make sure the module is installed before them.
    // We also install admin_toolbar here because we don't want a dependency on that
    if ($install_state['cms_demo_content']) {
      array_unshift($modules, 'default_content', 'better_normalizers');
    }

    $operations = [];
    foreach ($modules as $module) {
      $operations[] = ['cms_install_module_batch', [$module]];
    }

    // Uninstall Default content and Better normalizers modules as they only
    // needed on installation process.
    if ($install_state['cms_demo_content']) {
      $operations[] = ['cms_cleanup_batch', []];
    }

    $batch = [
      'operations' => $operations,
      'title' => t('Installing additional modules'),
      'error_message' => t('The installation has encountered an error.'),
    ];
  }

  return $batch;
}

/**
 * Implements callback_batch_operation().
 *
 * Performs batch installation of modules.
 */
function cms_install_module_batch($module, &$context) {
  // CMS Modules are not available yet.
  Drupal::service('module_installer')->install([$module], TRUE);

  // We're doing this here because during hook_install it fails due to demo content loading
  // after installation (when default_content module steps in).
  if (strpos($module, '_demo') > 0) {
    $module_path = drupal_get_path('module', $module);
    if ($path = file_get_contents($module_path . '/front-path.txt')) {
      if ($nid = Drupal::database()->query("SELECT nid FROM {node} WHERE uuid = '" . $path . "'")->fetchField()) {
        Drupal::configFactory()->getEditable('system.site')->set('page.front', '/node/' . $nid)->save(TRUE);
      }
      else {
        Drupal::configFactory()->getEditable('system.site')->set('page.front', $path)->save(TRUE);
      }
    }
  }

  $context['results'][] = $module;
  $context['message'] = t('Installed %module_name module.', ['%module_name' => $module]);
}

/**
 * Implements callback_batch_operation().
 */
function cms_cleanup_batch(&$context) {
  Drupal::service('module_installer')->uninstall(['default_content', 'better_normalizers'], FALSE);

  // Update url aliases with menu tokens (only needed for alises that reflect menu structure)
  \Drupal::service('pathauto.alias_storage_helper')->deleteAll();
  $result = \Drupal::entityQuery('node')->execute();
  $entity_storage = \Drupal::entityTypeManager()->getStorage('node');
  $entities = $entity_storage->loadMultiple($result);
  foreach ($entities as $entity) {
    \Drupal::service('pathauto.generator')->updateEntityAlias($entity, 'update');
  }

  $context['message'] = t('Cleanup.');
}

/**
 * Implements hook_library_info_alter().
 */
function cms_toolbar_alter(&$items) {
  if (!empty($items['admin_toolbar_tools'])) {
    $items['admin_toolbar_tools']['#attached']['library'][] = 'cms/toolbar.icon';
  }
}
