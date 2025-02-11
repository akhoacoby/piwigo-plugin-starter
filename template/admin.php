<?php
if (!defined('PHPWG_ROOT_PATH')) die('Hacking attempt!');

global $page, $conf;

$page['tab'] = 'config';

// Create tabsheet
include_once(PHPWG_ROOT_PATH . 'admin/include/tabsheet.class.php');
$tabsheet = new tabsheet();
$tabsheet->set_id('example_plugin_tab');
$tabsheet->add('config', '<span class="icon-cog"></span>'.l10n('Configuration'), EXAMPLE_PLUGIN_ADMIN . '-config');
$tabsheet->select($page['tab']);
$tabsheet->assign();

$template->set_filename('example_plugin_content', EXAMPLE_PLUGIN_REALPATH . '/admin/template/configuration.tpl');
$template->assign_var_from_handle('ADMIN_CONTENT', 'example_plugin_content');