{* ----------------------------------------------------------------- *}
{* <plugin_id> public block — theme-neutral, escapes all output.      *}
{* Loaded via combine_css/combine_script from your loc_* hook.        *}
{* Smarty auto-escape is OFF — escape every dynamic value.            *}
{* ----------------------------------------------------------------- *}

{combine_css path=$YOURPLUGIN_PATH|@cat:'template/public.css'}

<div id="yourPluginBlock"
     class="yourplugin{if $YOURPLUGIN_IS_BOOTSTRAP} yourplugin--bootstrap{elseif $YOURPLUGIN_THEME == 'modus'} yourplugin--modus{/if}">

  <div class="yourplugin-panel">
    <p>{'Your plugin output'|@translate}</p>

    {* Example item loop — escape names/urls. *}
    {foreach from=$YOURPLUGIN_ITEMS item=it}
      <a class="yourplugin-btn{if $YOURPLUGIN_IS_BOOTSTRAP} btn btn-primary btn-sm{/if}"
         href="{$it.url|@escape:'url'}"
         title="{$it.label|@escape}">
        {if $YOURPLUGIN_IS_BOOTSTRAP}<i class="fas fa-image fa-fw" aria-hidden="true"></i>{/if}
        <span>{$it.label|@escape}</span>
      </a>
    {/foreach}
  </div>
</div>
