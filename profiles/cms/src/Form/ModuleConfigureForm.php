<?php

namespace Drupal\cms\Form;

use Drupal\Core\Form\FormBase;
use Drupal\Component\Utility\Environment;
use Drupal\Core\Form\FormStateInterface;

/**
 * Provides a Cms form.
 */
class ModuleConfigureForm extends FormBase {

  /**
   * {@inheritdoc}
   */
  public function getFormId() {
    return 'cms_module_configure';
  }

  /**
   * {@inheritdoc}
   */
  public function buildForm(array $form, FormStateInterface $form_state) {

    $f = fopen(dirname(__FILE__) . '../../../demopack', 'r');
    $demopack = str_replace(array("\r", "\n"), '', fgets($f));
    fclose($f);

    $form['#title'] = $this->t('Choose Components');

    $form['cms_modules'] = [
      '#type' => 'container',
      '#attributes' => ['class' => ['cms-features']],
      '#tree' => TRUE,
    ];

    if ($demopack) {
      $form['cms_modules'][$demopack] = [
        '#type' => 'checkbox',
        '#title' => ucwords(str_replace('_', ' ', $demopack)),
        '#description' => t('Design With Demo Content'),
        '#default_value' => TRUE,
      ];
    }

    $path = drupal_get_path('profile', 'cms');

    $democontent = TRUE;
    $desc = '';
    if ((version_compare(PHP_VERSION, '7.0.0') !== -1) && !Environment::checkMemoryLimit('128M')) {
      $desc = t('PHP memory limit too low for demo content import. Minimum value for php.ini memory_limit is 128M.');
      $democontent = FALSE;
    }
    elseif ((version_compare('7.0.0', PHP_VERSION) > 0) && !Environment::checkMemoryLimit('256M')) {
      $desc = t('PHP memory limit too low for demo content import. Minimum value for php.ini memory_limit is 128M for php 7 and 256MB for versions below 7.0.0.');
      $democontent = FALSE;
    }

    $form['demo_content'] = [
      '#type' => 'checkbox',
      '#title' => t('Install demo content'),
      '#description' => $desc,
      '#default_value' => $democontent,
    ];

    $form['actions'] = ['#type' => 'actions'];
    $form['actions']['submit'] = [
      '#type' => 'submit',
      '#value' => t('Save'),
    ];

    $form['#attributes']['class'][] = 'cms-features-form';

    return $form;
  }

  /**
   * Runs cron and reloads the page.
   */
  public function submitForm(array &$form, FormStateInterface $form_state) {
    $build_info = $form_state->getBuildInfo();
    $build_info['args'][0]['cms_additional_modules'] = array_keys(array_filter($form_state->getValue('cms_modules')));
    $build_info['args'][0]['cms_demo_content'] = $form_state->getValue('demo_content');
    $form_state->setBuildInfo($build_info);
  }

}
