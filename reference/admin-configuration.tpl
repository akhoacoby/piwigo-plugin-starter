{* ----------------------------------------------------------------- *}
{* <plugin_id> admin settings — mirrors the core Configuration→Options *}
{* page (admin/themes/default/template/configuration_main.tpl):        *}
{*   form.properties > fieldset.mainConf > legend(icon) > ul > li,      *}
{*   .font-checkbox/.icon-check switches, .sub-setting for dependents,  *}
{*   .formButtons submit row. Renders in the ADMIN theme (default/      *}
{*   clear/roma) — NOT modus/darkroom. Auto-escape is OFF.             *}
{* ----------------------------------------------------------------- *}

<form method="post" action="{$F_ACTION}" class="properties">
  <div id="<plugin_id>Config">

    <fieldset class="mainConf">
      <legend><span class="icon-cog icon-purple"></span>{'Settings'|@translate}</legend>
      <ul>
        <li>
          <label class="font-checkbox">
            <span class="icon-check"></span>
            <input type="checkbox" name="show_panel" id="show_panel"{if $cfg.show_panel} checked="checked"{/if}>
            {'Show the panel'|@translate}
          </label>
          {* dependent option — core uses .sub-setting, hidden when parent is off *}
          <div id="panel_opts" class="sub-setting"{if !$cfg.show_panel} style="display:none"{/if}>
            <label>
              {'Mode'|@translate}
              <select name="mode">
                {foreach from=$mode_options item=opt}
                  <option value="{$opt|@escape}"{if $cfg.mode == $opt} selected="selected"{/if}>{$opt|@escape}</option>
                {/foreach}
              </select>
            </label>
          </div>
        </li>

        <li>
          <label>
            {'Items per row'|@translate}
            <input type="number" name="per_row" min="1" max="12" value="{$cfg.per_row|@intval}">
          </label>
        </li>
      </ul>
    </fieldset>

    <p class="formButtons">
      <input class="submit" type="submit" name="<plugin_id>_save" value="{'Save Settings'|@translate}">
    </p>

    {* CSRF token — handler calls check_pwg_token() (04-security.md) *}
    <input type="hidden" name="pwg_token" value="{$PWG_TOKEN}">
  </div>
</form>

{* Toggle the dependent block with the parent checkbox (core pattern). *}
{footer_script}{literal}
(function(){
  function sync(){ jQuery('#panel_opts').toggle(jQuery('#show_panel').is(':checked')); }
  sync(); jQuery('#show_panel').on('change', sync);
}());
{/literal}{/footer_script}
