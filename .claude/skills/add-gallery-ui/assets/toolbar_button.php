<?php
/**
 * Theme-aware gallery toolbar button for add_index_button() / add_picture_button().
 *
 * WHY THIS EXISTS: the $PLUGIN_*_ACTIONS slot lands in a different container per
 * theme — #imageToolBar (default/modus) vs a Bootstrap <ul class="navbar-nav">
 * (bootstrap_darkroom). A single markup mis-positions in one of them. So we
 * branch: bare .pwg-button anchor for default/modus, <li.nav-item>/<a.nav-link>
 * for darkroom. See theme-compat THEMES.md §4b.
 *
 * Rename yourplugin_* / .yourplugin-icon to your plugin's tokens.
 */

defined('PHPWG_ROOT_PATH') or die('Hacking attempt!');

/**
 * @param string $url    raw URL (escaped here)
 * @param string $label  translated, visible label
 * @param string $title  translated title/aria text
 * @return string button HTML for the current gallery theme
 */
function yourplugin_toolbar_button($url, $label, $title)
{
  global $user;

  $u = htmlspecialchars($url,   ENT_QUOTES, get_pwg_charset());
  $t = htmlspecialchars($title, ENT_QUOTES, get_pwg_charset());
  $l = htmlspecialchars($label, ENT_QUOTES, get_pwg_charset());

  $theme = isset($user['theme']) ? $user['theme'] : '';

  if ($theme === 'bootstrap_darkroom')
  {
    // Matches darkroom's navbar-nav siblings: <li.nav-item><a.nav-link><i.fas>.
    return '<li class="nav-item"><a class="nav-link" href="'.$u.'" title="'.$t.'" rel="nofollow">'
         . '<i class="fas fa-clone fa-fw" aria-hidden="true"></i>'
         . '<span class="pwg-button-text ml-2">'.$l.'</span>'
         . '</a></li>';
  }

  // default + modus: bare .pwg-button anchor inside #imageToolBar.
  return '<a class="pwg-state-default pwg-button" href="'.$u.'" title="'.$t.'" rel="nofollow">'
       . '<span class="pwg-icon yourplugin-icon" aria-hidden="true">&#10529;</span>'
       . '<span class="pwg-button-text">'.$l.'</span>'
       . '</a>';
}

/* Usage in a loc_end_picture / loc_end_index handler:

   global $template;
   $template->add_picture_button(
     yourplugin_toolbar_button($url, l10n('Compare'), l10n('Compare this photo with another')),
     BUTTONS_RANK_NEUTRAL
   );
*/
