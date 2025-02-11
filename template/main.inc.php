<?php
/*
Version: auto
Plugin Name: Example plugin
Plugin URI: auto
Author: Linty
Author URI: https://github.com/LintyDev
Description: Piwigo plugin starter
Has Settings: true
*/

if (!defined('PHPWG_ROOT_PATH')) die('Hacking attempt!');

// check root directory
if (basename(dirname(__FILE__)) != 'example_plugin')
{
  add_event_handler('init', 'example_plugin_error');
  function example_plugin_error()
  {
    global $page;
    $page['errors'][] = 'Example plugin folder name is incorrect, uninstall the plugin and rename it to "example_plugin"';
  }
  return;
}

// +-----------------------------------------------------------------------+
// | Define plugin constants                                               |
// +-----------------------------------------------------------------------+
global $prefixeTable;

define('EXAMPLE_PLUGIN_ID', basename(dirname(__FILE__)));
define('EXAMPLE_PLUGIN_PATH', PHPWG_PLUGINS_PATH . EXAMPLE_PLUGIN_ID . '/');
define('EXAMPLE_PLUGIN_REALPATH', realpath(EXAMPLE_PLUGIN_PATH));
define('EXAMPLE_PLUGIN_ADMIN', get_root_url() . 'admin.php?page=plugin-' . EXAMPLE_PLUGIN_ID);

// +-----------------------------------------------------------------------+
// | Init Example Plugin                                                   |
// +-----------------------------------------------------------------------+

include_once(EXAMPLE_PLUGIN_PATH . 'include/functions.inc.php');

add_event_handler('init', 'example_plugin_init');