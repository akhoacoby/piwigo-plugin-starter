{* ----------------------------------------------------------------- *}
{* <plugin_id> admin settings — modern pattern from the core           *}
{* Configuration→Search page. Reuses ADMIN-theme classes (no custom    *}
{* CSS): #configContent, fieldset+colored legend, .font-checkbox,      *}
{* fixed .savebar-footer with .buttonLike + .badge.info-message.       *}
{* Renders in the admin theme (default/clear/roma); NOT modus/darkroom. *}
{* Auto-escape is OFF — escape dynamic values. See ADMIN_UI.md.        *}
{* ----------------------------------------------------------------- *}

<form method="post" action="{$F_ACTION}" class="properties">
<div id="configContent">                {* reuse this id: core adds the save-bar bottom offset + legend styling *}

  <fieldset class="<plugin_id>Conf">
    <legend><span class="icon-cog icon-blue rotate-element"></span>{'Settings'|@translate}</legend>
    <ul>
      <li>
        <label class="font-checkbox">
          <span class="icon-check"></span>
          <input type="checkbox" name="show_panel" id="show_panel"{if $cfg.show_panel} checked="checked"{/if}>
          {'Show the panel'|@translate}
        </label>
        <span class="icon-help-circled tiptip" title="{'Display the plugin panel on the gallery'|@translate}" style="cursor:help"></span>

        {* dependent option — hidden when the parent is off (.sub-setting + tiny toggle script) *}
        <div id="panel_opts" class="sub-setting"{if !$cfg.show_panel} style="display:none"{/if}>
          <label class="no-bold">
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
        <label class="no-bold">
          {'Items per row'|@translate}
          <input type="number" name="per_row" min="1" max="12" value="{$cfg.per_row|@intval}">
        </label>
      </li>
    </ul>
  </fieldset>

</div>{* #configContent *}

<div class="savebar-footer">
  <div class="savebar-footer-start"></div>
  <div class="savebar-footer-end">
{if isset($save_success)}
    <div class="savebar-footer-block">
      <div class="badge info-message"><i class="icon-ok"></i>{$save_success|@escape}</div>
    </div>
{/if}
    <div class="savebar-footer-block">
      <button class="buttonLike" type="submit" name="<plugin_id>_save"{if $isWebmaster != 1} disabled{/if}>
        <i class="icon-floppy"></i> {'Save Settings'|@translate}
      </button>
    </div>
  </div>
  <input type="hidden" name="pwg_token" value="{$PWG_TOKEN}">
</div>
</form>

{* Toggle the dependent block from the parent checkbox (core pattern). *}
{footer_script}{literal}
(function(){
  function sync(){ jQuery('#panel_opts').toggle(jQuery('#show_panel').is(':checked')); }
  sync(); jQuery('#show_panel').on('change', sync);
}());
{/literal}{/footer_script}
