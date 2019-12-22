prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_190200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2019.10.04'
,p_release=>'19.2.0.00.18'
,p_default_workspace_id=>72616447716734322
,p_default_application_id=>298
,p_default_owner=>'E'
);
end;
/
 
prompt APPLICATION 298 - explorer IG Hide Interactive Grid Settings Plugin Demo
--
-- Application Export:
--   Application:     298
--   Name:            explorer IG Hide Interactive Grid Settings Plugin Demo
--   Date and Time:   21:14 Sunday December 22, 2019
--   Exported By:     ADMIN
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 4906257124580834
--   Manifest End
--   Version:         19.2.0.00.18
--   Instance ID:     218269090184964
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/com_uk_explorer_ighigs
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(4906257124580834)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.UK.EXPLORER.IGHIGS'
,p_display_name=>'Interactive Grid - Hide IG Settings'
,p_category=>'INIT'
,p_supported_ui_types=>'DESKTOP'
,p_image_prefix=>'&G_IGHIGS_FILE_PREFIX.'
,p_javascript_file_urls=>'#PLUGIN_FILES#js/explorerIgHigs#MIN#.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'--CREATE OR REPLACE PACKAGE BODY com_uk_explorer_ighigs',
'--AS',
'',
'  /*-------------------------------------',
'  * IG Hide IG Settings',
'  * Version: 19.2.0',
'  * Author:  Matt Mulvaney',
'  *-------------------------------------',
'  */',
'  FUNCTION render(p_dynamic_action IN apex_plugin.t_dynamic_action,',
'                  p_plugin         IN apex_plugin.t_plugin)',
'  RETURN apex_plugin.t_dynamic_action_render_result ',
'  IS',
'    -- plugin attributes',
'    l_result                   apex_plugin.t_dynamic_action_render_result;',
'    l_include_private          p_dynamic_action.attribute_01%TYPE := p_dynamic_action.attribute_01;',
'    l_hide_ig_cr_sl            p_dynamic_action.attribute_02%TYPE := p_dynamic_action.attribute_02;',
'    ',
'  BEGIN',
'',
'    -- Debug',
'    IF apex_application.g_debug ',
'    THEN',
'      apex_plugin_util.debug_dynamic_action(p_plugin         => p_plugin,',
'                                            p_dynamic_action => p_dynamic_action);',
'    END IF;',
'    ',
'      l_result.javascript_function := ',
'      q''[function() {',
'        explorerIgHigs.render({',
'          da: this,',
'          ajaxIdentifier: "#AJAX_IDENTIFIER#"',
'        });',
'      }]'';',
'      ',
'    l_result.javascript_function := replace(l_result.javascript_function,''#AJAX_IDENTIFIER#'', apex_plugin.get_ajax_identifier);',
'',
'    l_result.attribute_01        := l_include_private;',
'    l_result.attribute_02        := l_hide_ig_cr_sl;',
'',
'    RETURN l_result;',
'',
'  END render;',
'',
'  ------------------------------------------------------------------------------',
'  FUNCTION ajax(p_dynamic_action in apex_plugin.t_dynamic_action',
'              ,p_plugin         in apex_plugin.t_plugin) ',
'  RETURN apex_plugin.t_dynamic_action_ajax_result',
'  IS',
'',
'    l_report_id           varchar2(32767) default apex_application.g_x01;',
'    l_region_id           varchar2(32767) default apex_application.g_x02;',
'    l_settings_string     varchar2(32767) default apex_application.g_x03;',
'    l_applyToReports      varchar2(32767) default UPPER(apex_application.g_x04);',
'    ',
'    l_app_id              NUMBER DEFAULT nv(''APP_ID'');',
'    l_app_page_id         NUMBER DEFAULT nv(''APP_PAGE_ID'');',
'',
'    l_result              apex_plugin.t_dynamic_action_ajax_result;',
'    f sys_refcursor;',
'    c sys_refcursor;',
'    a sys_refcursor;',
'    h sys_refcursor;',
'    fb sys_refcursor;',
'    t0 pls_integer; ',
'    t1 pls_integer;',
'    ',
'    TYPE timing_rec IS RECORD ( MESSAGE VARCHAR2(32767), SPLIT_TIME NUMBER);',
'    TYPE tt IS TABLE OF timing_rec INDEX BY BINARY_INTEGER;',
'    tb tt;',
'',
'  BEGIN',
'    apex_debug.message(''>Interactive Grid - Hide IG Settings: AJAX Callback'');',
'    apex_debug.message(''Report ID: '' ||  l_report_id);',
'    apex_debug.message(''Region ID: '' ||  l_region_id);',
'    apex_debug.message(''App ID: '' ||  l_app_id);',
'    apex_debug.message(''App Page ID: '' ||  l_app_page_id);',
'    apex_debug.message(''Settings String: '' || l_settings_string);',
'    apex_debug.message(''Apply to Reports: '' || l_applyToReports);',
'    ',
'    t0 := dbms_utility.get_time;   ',
'    t1 := t0;',
'    ',
'    --# Filters',
'    IF INSTR(l_settings_string, '':F:'') > 0 THEN',
'      open f for ',
'    with reports as (',
'    select rpts.* from ',
'    APEX_APPLICATION_PAGE_REGIONS r, ',
'    APEX_APPL_PAGE_IG_RPTS rpts',
'    where r.application_id = l_app_id',
'    and r.page_id = l_app_page_id',
'    and NVL(r.static_id, ''R'' || r.region_id) = l_region_id',
'    and r.region_id = rpts.region_id ),',
'    current_report as ( select * from reports where report_id = l_report_id),',
'    base_report as ( select br.* from reports br, current_report cr where br.report_id = NVL(cr.base_report_id, cr.report_id ) ),',
'    /* Obtain Base/Current Unique IDXs */',
'    current_filters as ( select row_number() over (partition by f.type_code, f.name, f.column_id, f.comp_column_id, f.operator, f.is_case_sensitive, f.expression, f.is_enabled order by f.filter_id) idx, f.*,',
'    NVL((select heading from APEX_APPL_PAGE_IG_COLUMNS ic where ic.column_id = f.column_id), '''''''' || f.expression || '''''''' ) label',
'    from APEX_APPL_PAGE_IG_RPT_FILTERS f, current_report cr where f.report_id = cr.report_id ),',
'    base_filters as ( select row_number() over (partition by f.type_code, f.name, f.column_id, f.comp_column_id, f.operator, f.is_case_sensitive, f.expression, f.is_enabled order by f.filter_id) idx, f.*,',
'    NVL((select heading from APEX_APPL_PAGE_IG_COLUMNS ic where ic.column_id = f.column_id), '''''''' || f.expression || '''''''' ) label',
'    from APEX_APPL_PAGE_IG_RPT_FILTERS f, base_report br where f.report_id = br.report_id ),',
'    /* Decide what to be shown */',
'    display_filters as (select ',
'    idx, type_code, name, column_id, comp_column_id, operator, is_case_sensitive, expression, is_enabled',
'    from current_filters',
'    minus ',
'    select',
'    idx, type_code, name, column_id, comp_column_id, operator, is_case_sensitive, expression, is_enabled',
'    from base_filters),',
'    /* Use IDX to work out which can be removed */',
'    removable_filters as (',
'    select c.* from current_filters c',
'    , base_filters d',
'    where ',
'    c.idx = d.idx',
'    and ( c.type_code = d.type_code OR c.type_code IS NULL AND d.type_code IS NULL )',
'    and ( c.name = d.name OR c.name IS NULL AND d.name IS NULL )',
'    and ( c.column_id = d.column_id OR c.column_id IS NULL AND d.column_id IS NULL )',
'    and ( c.comp_column_id = d.comp_column_id OR c.comp_column_id IS NULL AND d.comp_column_id IS NULL )',
'    and ( c.operator = d.operator OR c.operator IS NULL AND d.operator IS NULL )',
'    and ( c.is_case_sensitive = d.is_case_sensitive OR c.is_case_sensitive IS NULL AND d.is_case_sensitive IS NULL )',
'    and ( c.expression = d.expression OR c.expression IS NULL AND d.expression IS NULL )',
'    and ( c.is_enabled = d.is_enabled OR c.is_enabled IS NULL AND d.is_enabled IS NULL )',
'    ),',
'    /* Final Filters for JSON */',
'    final_filters as (',
'    select TO_CHAR(c.filter_id) ID, NVL2(r.filter_id,''Y'',''N'') del, c.is_enabled, c.label from current_filters c,removable_filters r',
'    where c.filter_id = r.filter_id(+) )',
'    select * from final_filters;',
'',
'    tb(tb.COUNT+1).message := ''open filters'';',
'    tb(tb.COUNT).split_time := dbms_utility.get_time - t1;',
'    t1 := dbms_utility.get_time;',
'    END IF;',
'',
'    --# Control Breaks',
'    IF INSTR(l_settings_string, '':C:'') > 0 THEN',
'      open c for ',
'    with reports as (',
'    select rpts.* from ',
'    APEX_APPLICATION_PAGE_REGIONS r, ',
'    APEX_APPL_PAGE_IG_RPTS rpts',
'    where r.application_id = l_app_id',
'    and r.page_id = l_app_page_id',
'    and NVL(r.static_id, ''R'' || r.region_id) = l_region_id',
'    and r.region_id = rpts.region_id ),',
'    current_report as ( select * from reports where report_id = l_report_id),',
'    base_report as ( select br.* from reports br, current_report cr where br.report_id = NVL(cr.base_report_id, cr.report_id ) ),',
'    control_breaks_removable AS (',
'    select rc.column_id, ''Y'' DEL, break_is_enabled IS_ENABLED, c.heading from APEX_APPL_PAGE_IG_COLUMNS c, APEX_APPL_PAGE_IG_RPT_COLUMNS rc, current_report cr where c.column_id = rc.column_id and rc.report_id = cr.report_id and break_order IS NOT NUL'
||'L',
'    INTERSECT',
'    select rc.column_id, ''Y'' DEL, break_is_enabled IS_ENABLED, c.heading from APEX_APPL_PAGE_IG_COLUMNS c, APEX_APPL_PAGE_IG_RPT_COLUMNS rc, base_report cr where c.column_id = rc.column_id and rc.report_id = cr.report_id and break_order IS NOT NULL',
'    ),',
'    control_breaks_non_removable AS (',
'    select rc.column_id ID, ''N'' DEL, break_is_enabled IS_ENABLED, c.heading from APEX_APPL_PAGE_IG_COLUMNS c, APEX_APPL_PAGE_IG_RPT_COLUMNS rc, current_report cr where c.column_id = rc.column_id and rc.report_id = cr.report_id and break_order IS NOT '
||'NULL',
'    and not exists ( select 1 from control_breaks_removable cbr where cbr.column_id = rc.column_id ) ),',
'    final_control_breaks as (',
'    select * from control_breaks_removable',
'    union all',
'    select * from control_breaks_non_removable',
'    )',
'    select to_char(column_id) ID, DEL, IS_ENABLED, HEADING LABEL from final_control_breaks;',
'',
'    tb(tb.COUNT+1).message := ''open control breaks'';',
'    tb(tb.COUNT).split_time := dbms_utility.get_time - t1;',
'    t1 := dbms_utility.get_time;',
'    END IF;',
'',
'    IF INSTR(l_settings_string, '':A:'') > 0 THEN',
'    open a FOR',
'    with reports as (',
'    select rpts.* from ',
'    APEX_APPLICATION_PAGE_REGIONS r, ',
'    APEX_APPL_PAGE_IG_RPTS rpts',
'    where r.application_id = l_app_id',
'    and r.page_id = l_app_page_id',
'    and NVL(r.static_id, ''R'' || r.region_id) = l_region_id',
'    and r.region_id = rpts.region_id ),',
'    current_report as ( select * from reports where report_id = l_report_id),',
'    base_report as ( select br.* from reports br, current_report cr where br.report_id = NVL(cr.base_report_id, cr.report_id ) ),',
'    aggregates_removable AS (',
'    select  ''Y'' DEL, rc.is_enabled, rc.TOOLTIP, rc.FUNCTION, rc.COLUMN_ID, rc.COMP_COLUMN_ID, rc.SHOW_GRAND_TOTAL, c.heading from APEX_APPL_PAGE_IG_COLUMNS c, APEX_APPL_PAGE_IG_RPT_AGGS rc, current_report cr where c.column_id = rc.column_id and rc.re'
||'port_id = cr.report_id',
'    INTERSECT',
'    select ''Y'' DEL, rc.is_enabled, rc.TOOLTIP, rc.FUNCTION, rc.COLUMN_ID, rc.COMP_COLUMN_ID, rc.SHOW_GRAND_TOTAL, c.heading from APEX_APPL_PAGE_IG_COLUMNS c, APEX_APPL_PAGE_IG_RPT_AGGS rc, base_report cr where c.column_id = rc.column_id and rc.report'
||'_id = cr.report_id',
'    ),',
'    aggregates_non_removable AS (',
'    select ''N'' DEL, rc.is_enabled, rc.TOOLTIP, rc.FUNCTION, rc.COLUMN_ID, rc.COMP_COLUMN_ID, rc.SHOW_GRAND_TOTAL, c.heading from APEX_APPL_PAGE_IG_COLUMNS c, APEX_APPL_PAGE_IG_RPT_AGGS rc, current_report cr where c.column_id = rc.column_id and rc.rep'
||'ort_id = cr.report_id',
'    and ( rc.TOOLTIP, rc.is_enabled, rc.FUNCTION, rc.COLUMN_ID, rc.COMP_COLUMN_ID, rc.SHOW_GRAND_TOTAL) not in ',
'    ( ',
'    select a.TOOLTIP, a.is_enabled,a.FUNCTION, a.COLUMN_ID, a.COMP_COLUMN_ID, a.SHOW_GRAND_TOTAL from aggregates_removable a )',
'    ),',
'    final_aggregates as (',
'    select * from aggregates_removable',
'    union all',
'    select * from aggregates_non_removable',
'    )',
'    select to_char(rc.aggregate_id) ID, fa.DEL, rc.IS_ENABLED, fa.heading LABEL from final_aggregates fa, ',
'    ( select rc.* FROM APEX_APPL_PAGE_IG_RPT_AGGS rc, current_report cr where rc.report_id = cr.report_id ) rc',
'    where  ',
'    ( fa.TOOLTIP = rc.TOOLTIP OR fa.TOOLTIP IS NULL AND rc.TOOLTIP IS NULL )',
'    and ( fa.FUNCTION = rc.FUNCTION OR fa.FUNCTION IS NULL AND rc.FUNCTION IS NULL )',
'    and ( fa.COLUMN_ID = rc.COLUMN_ID OR fa.COLUMN_ID IS NULL AND rc.COLUMN_ID IS NULL )',
'    and ( fa.COMP_COLUMN_ID = rc.COMP_COLUMN_ID OR fa.COMP_COLUMN_ID IS NULL AND rc.COMP_COLUMN_ID IS NULL )',
'    and ( fa.SHOW_GRAND_TOTAL = rc.SHOW_GRAND_TOTAL OR fa.SHOW_GRAND_TOTAL IS NULL AND rc.SHOW_GRAND_TOTAL IS NULL )',
'    and ( fa.IS_ENABLED = rc.IS_ENABLED OR fa.IS_ENABLED IS NULL AND rc.IS_ENABLED IS NULL );',
'',
'    tb(tb.COUNT+1).message := ''open aggregates'';',
'    tb(tb.COUNT).split_time := dbms_utility.get_time - t1;',
'    t1 := dbms_utility.get_time;',
'    END IF;',
'',
'    -- Highlights',
'    IF INSTR(l_settings_string, '':H:'') > 0 THEN',
'    open h FOR',
'    with reports as (',
'    select rpts.* from ',
'    APEX_APPLICATION_PAGE_REGIONS r, ',
'    APEX_APPL_PAGE_IG_RPTS rpts',
'    where r.application_id = l_app_id',
'    and r.page_id = l_app_page_id',
'    and NVL(r.static_id, ''R'' || r.region_id) = l_region_id',
'    and r.region_id = rpts.region_id ),',
'    current_report as ( select * from reports where report_id = l_report_id),',
'    base_report as ( select br.* from reports br, current_report cr where br.report_id = NVL(cr.base_report_id, cr.report_id ) ),',
'    /* Obtain Base/Current Unique IDXs */',
'    current_highlights as ( select row_number() over (partition by f.NAME, f.COLUMN_ID, f.COMP_COLUMN_ID, f.BACKGROUND_COLOR, f.TEXT_COLOR, f.CONDITION_TYPE, f.CONDITION_TYPE_CODE, f.CONDITION_COLUMN_ID, f.CONDITION_COMP_COLUMN_ID, f.CONDITION_OPERAT'
||'OR, f.CONDITION_IS_CASE_SENSITIVE, CONDITION_EXPRESSION, f.is_enabled order by null) idx, f.*',
'    from APEX_APPL_PAGE_IG_RPT_HIGHLTS f, current_report cr where f.report_id = cr.report_id ),',
'    base_highlights as ( select row_number() over (partition by f.NAME, f.COLUMN_ID, f.COMP_COLUMN_ID, f.BACKGROUND_COLOR, f.TEXT_COLOR, f.CONDITION_TYPE, f.CONDITION_TYPE_CODE, f.CONDITION_COLUMN_ID, f.CONDITION_COMP_COLUMN_ID, f.CONDITION_OPERATOR,'
||' f.CONDITION_IS_CASE_SENSITIVE, CONDITION_EXPRESSION, f.is_enabled order by null) idx, f.*',
'    from APEX_APPL_PAGE_IG_RPT_HIGHLTS f, base_report br where f.report_id = br.report_id ),',
'    /* Decide what to be shown */',
'    display_highlights as (select ',
'    idx, NAME, COLUMN_ID, COMP_COLUMN_ID, BACKGROUND_COLOR, TEXT_COLOR, CONDITION_TYPE, CONDITION_TYPE_CODE, CONDITION_COLUMN_ID, CONDITION_COMP_COLUMN_ID, CONDITION_OPERATOR, CONDITION_IS_CASE_SENSITIVE, CONDITION_EXPRESSION, is_enabled',
'    from current_highlights',
'    minus ',
'    select',
'    idx, NAME, COLUMN_ID, COMP_COLUMN_ID, BACKGROUND_COLOR, TEXT_COLOR, CONDITION_TYPE, CONDITION_TYPE_CODE, CONDITION_COLUMN_ID, CONDITION_COMP_COLUMN_ID, CONDITION_OPERATOR, CONDITION_IS_CASE_SENSITIVE, CONDITION_EXPRESSION, is_enabled',
'    from base_highlights),',
'    /* Use IDX to work out which can be removed */',
'    removable_highlights as (',
'    select c.* from current_highlights c',
'    , base_highlights d',
'    where ',
'    c.idx = d.idx',
'    and ( c.name = d.name OR c.name IS NULL AND d.name IS NULL )',
'    and ( c.column_id = d.column_id OR c.column_id IS NULL AND d.column_id IS NULL )',
'    and ( c.comp_column_id = d.comp_column_id OR c.comp_column_id IS NULL AND d.comp_column_id IS NULL )',
'    and ( c.BACKGROUND_COLOR = d.BACKGROUND_COLOR OR c.BACKGROUND_COLOR IS NULL AND d.BACKGROUND_COLOR IS NULL )',
'    and ( c.TEXT_COLOR = d.TEXT_COLOR OR c.TEXT_COLOR IS NULL AND d.TEXT_COLOR IS NULL )',
'    and ( c.CONDITION_TYPE = d.CONDITION_TYPE OR c.CONDITION_TYPE IS NULL AND d.CONDITION_TYPE IS NULL )',
'    and ( c.CONDITION_TYPE_CODE = d.CONDITION_TYPE_CODE OR c.CONDITION_TYPE_CODE IS NULL AND d.CONDITION_TYPE_CODE IS NULL )',
'    and ( c.CONDITION_COLUMN_ID = d.CONDITION_COLUMN_ID OR c.CONDITION_COLUMN_ID IS NULL AND d.CONDITION_COLUMN_ID IS NULL )',
'    and ( c.CONDITION_COMP_COLUMN_ID = d.CONDITION_COMP_COLUMN_ID OR c.CONDITION_COMP_COLUMN_ID IS NULL AND d.CONDITION_COMP_COLUMN_ID IS NULL )',
'    and ( c.CONDITION_OPERATOR = d.CONDITION_OPERATOR OR c.CONDITION_OPERATOR IS NULL AND d.CONDITION_OPERATOR IS NULL )',
'    and ( c.CONDITION_IS_CASE_SENSITIVE = d.CONDITION_IS_CASE_SENSITIVE OR c.CONDITION_IS_CASE_SENSITIVE IS NULL AND d.CONDITION_IS_CASE_SENSITIVE IS NULL )',
'    and ( c.CONDITION_EXPRESSION = d.CONDITION_EXPRESSION OR c.CONDITION_EXPRESSION IS NULL AND d.CONDITION_EXPRESSION IS NULL )',
'    and ( c.IS_ENABLED = d.IS_ENABLED OR c.IS_ENABLED IS NULL AND d.IS_ENABLED IS NULL )',
'    ),',
'    /* Final highlights for JSON */',
'    final_highlights as (',
'    select to_char(c.highlight_id) ID, NVL2(r.highlight_id,''Y'',''N'') del, c.is_enabled, c.name label from current_highlights c,removable_highlights r',
'    where c.highlight_id = r.highlight_id(+) )',
'    select * from final_highlights;',
'',
'    tb(tb.COUNT+1).message := ''open highlights'';',
'    tb(tb.COUNT).split_time := dbms_utility.get_time - t1;',
'    t1 := dbms_utility.get_time;',
'    END IF;',
'',
'    -- Flashbacks',
'    IF INSTR(l_settings_string, '':FB:'') > 0 THEN',
'    open fb FOR',
'    with reports as (',
'    select rpts.* from ',
'    APEX_APPLICATION_PAGE_REGIONS r, ',
'    APEX_APPL_PAGE_IG_RPTS rpts',
'    where r.application_id = l_app_id',
'    and r.page_id = l_app_page_id',
'    and NVL(r.static_id, ''R'' || r.region_id) = l_region_id',
'    and r.region_id = rpts.region_id ),',
'    current_report as ( select * from reports where report_id = l_report_id),',
'    base_report as ( select br.* from reports br, current_report cr where br.report_id = NVL(cr.base_report_id, cr.report_id ) ),',
'    /* Obtain Base/Current Unique IDXs */',
'    current_flashbacks as ( select *  FROM current_report cr ),',
'    base_flashbacks as ( select * from base_report br ),',
'    /* Decide what to be shown */',
'    display_flashbacks as (select  flashback_mins_ago',
'    from current_flashbacks',
'    minus ',
'    select',
'    flashback_mins_ago',
'    from base_flashbacks),',
'    /* Use IDX to work out which can be removed */',
'    removable_flashbacks as (',
'    select c.* from current_flashbacks c',
'    , base_flashbacks d',
'    where ',
'    ( c.flashback_mins_ago = d.flashback_mins_ago OR c.flashback_mins_ago IS NULL AND d.flashback_mins_ago IS NULL ) AND',
'    ( c.flashback_is_enabled = d.flashback_is_enabled OR c.flashback_is_enabled IS NULL AND d.flashback_is_enabled IS NULL )',
'    ),',
'    /* Final flashbacks for JSON */',
'    final_flashbacks as (',
'    select NULL ID, NVL2(r.report_id,''Y'',''N'') del, c.flashback_is_enabled is_enabled, c.flashback_mins_ago || '' minutes ago'' label from current_flashbacks c,removable_flashbacks r',
'    where c.report_id = r.report_id(+) and c.flashback_mins_ago is not null )',
'    select * from final_flashbacks;',
'',
'    tb(tb.COUNT+1).message := ''open flashbacks'';',
'    tb(tb.COUNT).split_time := dbms_utility.get_time - t1;',
'    t1 := dbms_utility.get_time;',
'    END IF;',
'',
'    apex_json.open_object;',
'    apex_json.open_object(''settings'');',
'    IF INSTR(l_settings_string, '':F:'') > 0 THEN',
'      apex_json. write(''filter'', f);',
'      tb(tb.COUNT+1).message := ''write filter'';',
'      tb(tb.COUNT).split_time := dbms_utility.get_time - t1;',
'      t1 := dbms_utility.get_time;',
'    ELSE ',
'      apex_json.open_array(''filter'');',
'      apex_json.close_array; ',
'    END IF;',
'    IF INSTR(l_settings_string, '':C:'') > 0 THEN',
'      apex_json. write(''controlBreak'', c);',
'      tb(tb.COUNT+1).message := ''write controlbreak'';',
'      tb(tb.COUNT).split_time := dbms_utility.get_time - t1;',
'      t1 := dbms_utility.get_time;',
'    ELSE ',
'      apex_json.open_array(''controlBreak'');',
'      apex_json.close_array;',
'    END IF;',
'    IF INSTR(l_settings_string, '':A:'') > 0 THEN',
'      apex_json. write(''aggregate'', a);',
'      tb(tb.COUNT+1).message := ''write aggregate'';',
'      tb(tb.COUNT).split_time := dbms_utility.get_time - t1;',
'      t1 := dbms_utility.get_time;',
'    ELSE ',
'      apex_json.open_array(''aggregate'');',
'      apex_json.close_array;',
'    END IF;',
'    IF INSTR(l_settings_string, '':H:'') > 0 THEN',
'      apex_json. write(''highlight'', h);',
'      tb(tb.COUNT+1).message := ''write highlight'';',
'      tb(tb.COUNT).split_time := dbms_utility.get_time - t1;',
'      t1 := dbms_utility.get_time;',
'    ELSE ',
'      apex_json.open_array(''highlight'');',
'      apex_json.close_array;',
'    END IF;',
'    IF INSTR(l_settings_string, '':FB:'') > 0 THEN',
'      apex_json. write(''flashback'', fb);',
'      tb(tb.COUNT+1).message := ''write flashback'';',
'      tb(tb.COUNT).split_time := dbms_utility.get_time - t1;',
'      t1 := dbms_utility.get_time;',
'    ELSE ',
'      apex_json.open_array(''flashback'');',
'      apex_json.close_array;',
'    END IF;',
'    apex_json.close_object;',
'    apex_json.open_object(''meta'');',
'    apex_json. write(''ReportId'', l_report_id);',
'    apex_json. write(''Cost'', dbms_utility.get_time - t0 );',
'    apex_json.close_object;  ',
'    IF NVL(V(''DEBUG''),''NO'') <> ''NO''',
'    THEN',
'      apex_json.open_object(''debug'');  ',
'      FOR x in NVL(tb.FIRST,1)..NVL(tb.LAST,0)',
'      LOOP',
'        apex_json. write(x || '': '' || tb(x).message, tb(x).split_time);',
'      END LOOP;',
'      apex_json.close_object;  ',
'    END IF;',
'    apex_json.close_object;',
'',
'    RETURN l_result;',
'      ',
'  END ajax;',
'',
'-- END com_uk_explorer_ighigs;'))
,p_api_version=>1
,p_render_function=>'&G_IGHIGS_PACKAGE_NAME.render'
,p_ajax_function=>'&G_IGHIGS_PACKAGE_NAME.ajax'
,p_standard_attributes=>'REGION:REQUIRED:ONLOAD'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'Hides all saved Interactive Grid settings'
,p_version_identifier=>'19.2.0'
,p_about_url=>'https://github.com/ExplorerUK/IG-Hide-Interactive-Grid-Settings-Plugin'
,p_files_version=>198
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(4906425777580839)
,p_plugin_id=>wwv_flow_api.id(4906257124580834)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Settings to Hide'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_default_value=>'A:C:F:FB:H'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(4906830765580840)
,p_plugin_attribute_id=>wwv_flow_api.id(4906425777580839)
,p_display_sequence=>10
,p_display_value=>'Aggregations'
,p_return_value=>'A'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(4907325072580841)
,p_plugin_attribute_id=>wwv_flow_api.id(4906425777580839)
,p_display_sequence=>20
,p_display_value=>'Control Breaks'
,p_return_value=>'C'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(4907852797580841)
,p_plugin_attribute_id=>wwv_flow_api.id(4906425777580839)
,p_display_sequence=>30
,p_display_value=>'Filters'
,p_return_value=>'F'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(4908391407580842)
,p_plugin_attribute_id=>wwv_flow_api.id(4906425777580839)
,p_display_sequence=>40
,p_display_value=>'Flashback'
,p_return_value=>'FB'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(4908831679580842)
,p_plugin_attribute_id=>wwv_flow_api.id(4906425777580839)
,p_display_sequence=>50
,p_display_value=>'Highlights'
,p_return_value=>'H'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(4909364316580843)
,p_plugin_id=>wwv_flow_api.id(4906257124580834)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Apply to'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_default_value=>'primary:alternative'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(4909729229580843)
,p_plugin_attribute_id=>wwv_flow_api.id(4909364316580843)
,p_display_sequence=>10
,p_display_value=>'Primary Report'
,p_return_value=>'primary'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(4910262401580843)
,p_plugin_attribute_id=>wwv_flow_api.id(4909364316580843)
,p_display_sequence=>20
,p_display_value=>'Alternative Reports'
,p_return_value=>'alternative'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(4910648808580844)
,p_plugin_attribute_id=>wwv_flow_api.id(4909364316580843)
,p_display_sequence=>30
,p_display_value=>'Private Reports'
,p_return_value=>'private'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(4911135006580844)
,p_plugin_attribute_id=>wwv_flow_api.id(4909364316580843)
,p_display_sequence=>40
,p_display_value=>'Public Reports'
,p_return_value=>'public'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A2065736C696E742D64697361626C65206E6F2D756E757365642D76617273202A2F0D0A2F2F2065736C696E742D64697361626C652D6E6578742D6C696E65206E6F2D756E6465660D0A6578706C6F726572496748696773203D202866756E6374696F';
wwv_flow_api.g_varchar2_table(2) := '6E202829207B0D0A20202275736520737472696374223B0D0A0D0A2020766172206368616E67655265706F727453656C6563746F72203D20222E612D546F6F6C6261722D73656C6563744C6973745B646174612D616374696F6E3D5C226368616E67652D';
wwv_flow_api.g_varchar2_table(3) := '7265706F72745C225D223B0D0A2020766172206465627567507265666978203D20224578706C6F7265722049474849475320506C7567696E3A20223B0D0A0D0A2020766172206E766C203D2066756E6374696F6E206E766C2876616C7565312C2076616C';
wwv_flow_api.g_varchar2_table(4) := '75653229207B0D0A202020206966202876616C756531203D3D206E756C6C207C7C2076616C756531203D3D202222290D0A20202020202072657475726E2076616C7565323B0D0A2020202072657475726E2076616C7565313B0D0A20207D3B0D0A0D0A20';
wwv_flow_api.g_varchar2_table(5) := '2066756E6374696F6E20676574557365724D6F646528704967537461746963496429207B0D0A2020202072657475726E206E766C2873657373696F6E53746F726167652E6765744974656D28222E22202B20617065782E6974656D282270466C6F774964';
wwv_flow_api.g_varchar2_table(6) := '22292E67657456616C75652829202B20222E22202B20617065782E6974656D282270466C6F7753746570496422292E67657456616C75652829202B20222E6967486967732E22202B207049675374617469634964292C20224E22293B0D0A20207D0D0A0D';
wwv_flow_api.g_varchar2_table(7) := '0A202066756E6374696F6E20736574557365724D6F64652870496753746174696349642C207056616C756529207B0D0A2020202073657373696F6E53746F726167652E7365744974656D28222E22202B20617065782E6974656D282270466C6F77496422';
wwv_flow_api.g_varchar2_table(8) := '292E67657456616C75652829202B20222E22202B20617065782E6974656D282270466C6F7753746570496422292E67657456616C75652829202B20222E6967486967732E22202B2070496753746174696349642C207056616C7565293B0D0A20207D0D0A';
wwv_flow_api.g_varchar2_table(9) := '0D0A202066756E6374696F6E206973446576656C6F70657228704967537461746963496429207B0D0A2020202072657475726E20617065782E726567696F6E287049675374617469634964292E63616C6C28226F7074696F6E222C2022636F6E66696722';
wwv_flow_api.g_varchar2_table(10) := '292E66656174757265732E736176655265706F72742E6973446576656C6F7065723B0D0A20207D0D0A0D0A202066756E6374696F6E20616C6C53657474696E677348696464656E28704967537461746963496429207B0D0A2020202072657475726E2028';
wwv_flow_api.g_varchar2_table(11) := '2428222322202B207049675374617469634964202B2022202E612D49472D636F6E74726F6C7322292E6368696C6472656E28292E66696C7465722866756E6374696F6E20285F696E64657829207B0D0A20202020202072657475726E2024287468697329';
wwv_flow_api.g_varchar2_table(12) := '2E6373732822646973706C61792229203D3D3D2022626C6F636B223B0D0A202020207D292E6C656E677468203D3D2030293B0D0A20207D0D0A0D0A202066756E6374696F6E206170706C696573546F43757272656E745265706F7274286F7074696F6E73';
wwv_flow_api.g_varchar2_table(13) := '29207B0D0A2020202076617220726567696F6E4964203D206F7074696F6E732E64612E616374696F6E2E6166666563746564526567696F6E49643B0D0A20202020766172206170706C79546F5265706F727473203D206F7074696F6E732E64612E616374';
wwv_flow_api.g_varchar2_table(14) := '696F6E2E61747472696275746530323B0D0A202020207661722063757272656E745265706F727454797065203D2067657443757272656E745265706F72745479706528726567696F6E4964293B0D0A202020207661722072657475726E426F6F6C65616E';
wwv_flow_api.g_varchar2_table(15) := '203D2066616C73653B200D0A2020202069662028206170706C79546F5265706F72747320213D206E756C6C29207B0D0A20202020202072657475726E426F6F6C65616E203D2020286170706C79546F5265706F7274732E73706C697428223A22292E696E';
wwv_flow_api.g_varchar2_table(16) := '6465784F662863757272656E745265706F7274547970652920213D202D31293B0D0A202020207D0D0A2020202072657475726E2072657475726E426F6F6C65616E3B0D0A20207D0D0A0D0A202066756E6374696F6E2073686F756C6448696465286F7074';
wwv_flow_api.g_varchar2_table(17) := '696F6E7329207B0D0A2020202076617220726567696F6E4964203D206F7074696F6E732E64612E616374696F6E2E6166666563746564526567696F6E49643B0D0A2020202072657475726E20280D0A2020202020206170706C696573546F43757272656E';
wwv_flow_api.g_varchar2_table(18) := '745265706F7274286F7074696F6E73292026260D0A2020202020202F2F204170706C69657320746F2063757272656E74207265706F727420616E642E2E2E0D0A2020202020202F2F202E2E2E6973206120646576656C6F70657220616E64206D61737175';
wwv_flow_api.g_varchar2_table(19) := '65726164696E6720617320612075736572204F52206120757365720D0A20202020202028286973446576656C6F70657228726567696F6E49642920262620676574557365724D6F646528726567696F6E496429203D3D2022592229207C7C202821286973';
wwv_flow_api.g_varchar2_table(20) := '446576656C6F70657228726567696F6E4964292929290D0A20202020293B0D0A20207D0D0A0D0A202066756E6374696F6E2067657443757272656E745265706F72745479706528704967537461746963496429207B0D0A20202020766172207265706F72';
wwv_flow_api.g_varchar2_table(21) := '74734172726179203D20617065782E726567696F6E287049675374617469634964292E63616C6C28226765745265706F72747322293B0D0A202020207661722072496478203D2066696E645769746841747472287265706F72747341727261792C202269';
wwv_flow_api.g_varchar2_table(22) := '64222C2067657443757272656E745265706F7274496428704967537461746963496429293B0D0A20202020766172206C52657475726E203D2022223B0D0A20202020696620287249647820213D202D3129207B0D0A2020202020206C52657475726E203D';
wwv_flow_api.g_varchar2_table(23) := '207265706F72747341727261795B724964785D2E747970653B0D0A202020207D0D0A2020202072657475726E206C52657475726E3B0D0A20207D0D0A0D0A202066756E6374696F6E207573657253657474696E677356696577427574746F6E286F707469';
wwv_flow_api.g_varchar2_table(24) := '6F6E7329207B0D0A2020202076617220726567696F6E4964203D206F7074696F6E732E64612E616374696F6E2E6166666563746564526567696F6E49643B0D0A20202020696620286973446576656C6F70657228726567696F6E4964292029202F2F2626';
wwv_flow_api.g_varchar2_table(25) := '206170706C696573546F43757272656E745265706F7274286F7074696F6E73292029200D0A202020207B0D0A202020202020657874656E6447726964546F6F6C626172286F7074696F6E73293B0D0A202020207D20656C7365207B0D0A20202020202065';
wwv_flow_api.g_varchar2_table(26) := '7874656E6447726964546F6F6C626172286F7074696F6E732C7472756520293B0D0A202020207D0D0A20207D0D0A0D0A202066756E6374696F6E20726573746F72655573657256696577286F7074696F6E73297B0D0A20202020617065782E6465627567';
wwv_flow_api.g_varchar2_table(27) := '2E696E666F286465627567507265666978202B2022726573746F7265557365725669657722293B0D0A202020207661722076526567696F6E4964203D206F7074696F6E732E64612E616374696F6E2E6166666563746564526567696F6E49643B0D0A2020';
wwv_flow_api.g_varchar2_table(28) := '20202F2F2052656D6F76652043535320696E6A656374696F6E7320666F72207468652063757272656E74207265706F72740D0A202020202428222E696748696773496E6A6563745374796C65732D22202B2076526567696F6E4964202B20222D22202B20';
wwv_flow_api.g_varchar2_table(29) := '67657443757272656E745265706F727449642876526567696F6E49642920292E7265706C6163655769746828293B0D0A20202020636C65616E5570286F7074696F6E73293B0D0A20207D0D0A0D0A20207661722072656E646572203D2066756E6374696F';
wwv_flow_api.g_varchar2_table(30) := '6E2072656E646572286F7074696F6E7329207B0D0A2020202076617220726567696F6E4964203D206F7074696F6E732E64612E616374696F6E2E6166666563746564526567696F6E49643B0D0A20202020617065782E64656275672E696E666F28646562';
wwv_flow_api.g_varchar2_table(31) := '7567507265666978202B202252656E64657222293B0D0A20202020617065782E64656275672E696E666F2864656275675072656669782C206F7074696F6E73293B0D0A0D0A202020202F2F20436865636B207468697320697320616E2049470D0A202020';
wwv_flow_api.g_varchar2_table(32) := '20696620282428222322202B20726567696F6E4964202B2022202E612D494722292E6C656E677468203D3D203029207B0D0A202020202020617065782E64656275672E696E666F286465627567507265666978202B20224572726F723A20526567696F6E';
wwv_flow_api.g_varchar2_table(33) := '2022202B20726567696F6E4964202B2022206973206E6F7420616E20496E746572616374697665204772696422293B0D0A20202020202072657475726E3B0D0A202020207D0D0A202020200D0A202020207573657253657474696E677356696577427574';
wwv_flow_api.g_varchar2_table(34) := '746F6E286F7074696F6E73293B0D0A0D0A202020202F2F20416464206576656E74730D0A202020202428222322202B20726567696F6E4964292E6F6E2822696E746572616374697665677269647265706F727473657474696E67736368616E6765222C20';
wwv_flow_api.g_varchar2_table(35) := '66756E6374696F6E20285F6576656E742C205F6461746129207B0D0A202020202020617065782E64656275672E696E666F286465627567507265666978202B20224576656E74202D2053657474696E6773204368616E676522293B0D0A20202020202069';
wwv_flow_api.g_varchar2_table(36) := '66202873686F756C6448696465286F7074696F6E732929207B200D0A2020202020202020696E6A6563745374796C657328226469762322202B20726567696F6E4964202B20225F69675F7265706F72745F73657474696E67735F73756D6D6172797B6469';
wwv_flow_api.g_varchar2_table(37) := '73706C61793A6E6F6E657D222C726567696F6E4964293B0D0A2020202020207D0D0A202020202020616A617847657453657474696E6773746F48696465286F7074696F6E73293B0D0A202020207D293B0D0A0D0A202020202428222322202B2072656769';
wwv_flow_api.g_varchar2_table(38) := '6F6E4964292E6F6E2822696E74657261637469766567726964766965776368616E6765222C2066756E6374696F6E20285F6576656E742C205F6461746129207B0D0A202020202020617065782E64656275672E696E666F28646562756750726566697820';
wwv_flow_api.g_varchar2_table(39) := '2B20224576656E74202D20477269642056696577204368616E676522293B200D0A2020202020207573657253657474696E677356696577427574746F6E286F7074696F6E73293B0D0A2020202020206966202873686F756C6448696465286F7074696F6E';
wwv_flow_api.g_varchar2_table(40) := '732929207B200D0A2020202020202020696E6A6563745374796C657328226469762322202B20726567696F6E4964202B20225F69675F7265706F72745F73657474696E67735F73756D6D6172797B646973706C61793A6E6F6E657D222C726567696F6E49';
wwv_flow_api.g_varchar2_table(41) := '64293B0D0A2020202020207D0D0A202020202020616A617847657453657474696E6773746F48696465286F7074696F6E73293B0D0A202020207D293B0D0A0D0A202020202F2F205573652061206D61746368657320706F6C7966696C6C20666F72204945';
wwv_flow_api.g_varchar2_table(42) := '392B0D0A202020202F2F2068747470733A2F2F646576656C6F7065722E6D6F7A696C6C612E6F72672F656E2D55532F646F63732F5765622F4150492F456C656D656E742F6D6174636865730D0A202020206966202821456C656D656E742E70726F746F74';
wwv_flow_api.g_varchar2_table(43) := '7970652E6D61746368657329207B0D0A202020202020456C656D656E742E70726F746F747970652E6D617463686573203D20456C656D656E742E70726F746F747970652E6D734D61746368657353656C6563746F72207C7C0D0A2020202020202020456C';
wwv_flow_api.g_varchar2_table(44) := '656D656E742E70726F746F747970652E7765626B69744D61746368657353656C6563746F723B0D0A202020207D0D0A0D0A20202020766172206D75746174696F6E4F62736572766572203D206E6577204D75746174696F6E4F627365727665722866756E';
wwv_flow_api.g_varchar2_table(45) := '6374696F6E20286D75746174696F6E7329207B0D0A2020202020202F2F204C6F6F6B20666F7220706F74656E7469616C6C79206368616E67652D7265706F72742072656C61746564206D75746174696F6E7320696E204A53206173204A51756572792069';
wwv_flow_api.g_varchar2_table(46) := '7473656C66206361757365732061206D75746174696F6E0D0A202020202020766172206D75746174696F6E53656C6563746F72203D206368616E67655265706F727453656C6563746F723B0D0A202020202020696620286D75746174696F6E735B305D2E';
wwv_flow_api.g_varchar2_table(47) := '7461726765742E6D617463686573286D75746174696F6E53656C6563746F7229207C7C0D0A20202020202020206D75746174696F6E735B305D2E7461726765742E717565727953656C6563746F72416C6C286D75746174696F6E53656C6563746F72292E';
wwv_flow_api.g_varchar2_table(48) := '6C656E677468203E203029207B0D0A2020202020202020617065782E64656275672E696E666F286465627567507265666978202B20224576656E74202D206D75746174696F6E4F6273657276657222293B0D0A20202020202020206966202873686F756C';
wwv_flow_api.g_varchar2_table(49) := '6448696465286F7074696F6E732929207B0D0A20202020202020202F2F206D75746174696F6E20697320706F74656E7469616C6C79206368616E67652D7265706F72742072656C617465640D0A20202020202020202020696E6A6563745374796C657328';
wwv_flow_api.g_varchar2_table(50) := '226469762322202B20726567696F6E4964202B20225F69675F7265706F72745F73657474696E67735F73756D6D6172797B646973706C61793A6E6F6E657D222C726567696F6E4964293B0D0A20202020202020207D0D0A2020202020202020616A617847';
wwv_flow_api.g_varchar2_table(51) := '657453657474696E6773746F48696465286F7074696F6E73293B0D0A2020202020207D200D0A202020207D293B0D0A0D0A202020202F2F206D75746174696F6E206F6273657276657220636865636B696E6720746F6F6F6C62617220666F72206D757461';
wwv_flow_api.g_varchar2_table(52) := '74696F6E732E200D0A202020202F2F2077652061726520756E61626C6520746F20706C616365206F62736572766572206F6E20746865206368616E6765207265706F72742073656C656374206C69737420617320657874656E64696E672074686520746F';
wwv_flow_api.g_varchar2_table(53) := '6F6C6261722072656D6F76657320746865206F627365727665720D0A202020206D75746174696F6E4F627365727665722E6F627365727665282428222322202B20726567696F6E4964202B20225F69675F746F6F6C62617222295B305D2C207B0D0A2020';
wwv_flow_api.g_varchar2_table(54) := '20202020617474726962757465733A20747275652C0D0A202020202020636861726163746572446174613A20747275652C0D0A2020202020206368696C644C6973743A20747275652C0D0A202020202020737562747265653A20747275652C0D0A202020';
wwv_flow_api.g_varchar2_table(55) := '2020206174747269627574654F6C6456616C75653A20747275652C0D0A202020202020636861726163746572446174614F6C6456616C75653A20747275650D0A202020207D293B0D0A0D0A202020202F2F20506C7567696E20496E697469616C20537461';
wwv_flow_api.g_varchar2_table(56) := '727475700D0A20202020616A617847657453657474696E6773746F48696465286F7074696F6E73293B200D0A0D0A20207D3B0D0A0D0A20207661722067657443757272656E745265706F72744964203D2066756E6374696F6E2067657443757272656E74';
wwv_flow_api.g_varchar2_table(57) := '5265706F7274496428704967537461746963496429207B0D0A20202020766172207265745265706F727449643B0D0A20202020747279207B0D0A2020202020207661722067726964203D20617065782E726567696F6E287049675374617469634964292E';
wwv_flow_api.g_varchar2_table(58) := '63616C6C282267657443757272656E745669657722293B0D0A202020202020766172206D6F64656C203D20677269642E6D6F64656C3B0D0A202020202020696620286D6F64656C29207B0D0A20202020202020207265745265706F72744964203D206170';
wwv_flow_api.g_varchar2_table(59) := '65782E726567696F6E287049675374617469634964292E63616C6C282267657443757272656E745669657722292E6D6F64656C2E6765744F7074696F6E2822726567696F6E4461746122292E7265706F727449643B0D0A2020202020207D20656C736520';
wwv_flow_api.g_varchar2_table(60) := '7B0D0A20202020202020202F2F204D6F64656C206F6276696F75736C79206E6F74206578697374732C20706F737369626C79206120636861727420766965772C207468657265666F72652064656661756C7420746F207468652073656C656374206C6973';
wwv_flow_api.g_varchar2_table(61) := '7420696620706F737369626C650D0A20202020202020207265745265706F72744964203D202428222322202B207049675374617469634964292E66696E64286368616E67655265706F727453656C6563746F72295B305D2E76616C75653B0D0A20202020';
wwv_flow_api.g_varchar2_table(62) := '20207D0D0A202020207D0D0A202020206361746368202865727229207B0D0A2020202020207265745265706F72744964203D202428222322202B207049675374617469634964292E66696E64286368616E67655265706F727453656C6563746F72295B30';
wwv_flow_api.g_varchar2_table(63) := '5D2E76616C75653B0D0A202020207D0D0A0D0A2020202072657475726E207265745265706F727449643B0D0A20207D3B0D0A0D0A0D0A202066756E6374696F6E20616A617847657453657474696E6773746F48696465286F7074696F6E7329207B0D0A0D';
wwv_flow_api.g_varchar2_table(64) := '0A20202020766172207265717565737444617461203D207B7D3B0D0A2020202076617220726567696F6E4964203D206F7074696F6E732E64612E616374696F6E2E6166666563746564526567696F6E49643B200D0A202020207661722073657474696E67';
wwv_flow_api.g_varchar2_table(65) := '73546F48696465203D20223A22202B206F7074696F6E732E64612E616374696F6E2E6174747269627574653031202B20223A223B202020200D0A20202020766172206170706C79546F5265706F727473203D206F7074696F6E732E64612E616374696F6E';
wwv_flow_api.g_varchar2_table(66) := '2E61747472696275746530323B0D0A2020202072657175657374446174612E783031203D2067657443757272656E745265706F7274496428726567696F6E4964293B0D0A2020202072657175657374446174612E783032203D20726567696F6E49643B0D';
wwv_flow_api.g_varchar2_table(67) := '0A2020202072657175657374446174612E783033203D2073657474696E6773546F486964653B0D0A2020202072657175657374446174612E783034203D206170706C79546F5265706F7274733B0D0A0D0A202020202F2F2053746F7020676C6974636820';
wwv_flow_api.g_varchar2_table(68) := '7768656E206368616E67696E67207265706F72740D0A2020202076617220726567696F6E43757272656E745265706F72744964203D202428222322202B20726567696F6E4964292E61747472282269674869677343757272656E745265706F7274496422';
wwv_flow_api.g_varchar2_table(69) := '293B0D0A2020202076617220726567696F6E43757272656E7456696577203D202428222322202B20726567696F6E4964292E61747472282269674869677343757272656E745669657722293B0D0A202020207661722063757272656E7456696577203D20';
wwv_flow_api.g_varchar2_table(70) := '617065782E726567696F6E28726567696F6E4964292E63616C6C282267657443757272656E745669657722292E696E7465726E616C4964656E7469666965723B0D0A0D0A202020202428222322202B20726567696F6E4964292E61747472282269674869';
wwv_flow_api.g_varchar2_table(71) := '677343757272656E745265706F72744964222C2072657175657374446174612E783031293B0D0A202020202428222322202B20726567696F6E4964292E61747472282269674869677343757272656E7456696577222C2063757272656E7456696577293B';
wwv_flow_api.g_varchar2_table(72) := '0D0A0D0A20202020696620282073686F756C6448696465286F7074696F6E73292026260D0A2020202020202020202820282072657175657374446174612E78303120213D20726567696F6E43757272656E745265706F727449642029207C7C200D0A2020';
wwv_flow_api.g_varchar2_table(73) := '20202020202020282063757272656E745669657720213D20726567696F6E43757272656E7456696577202929200D0A2020202029207B0D0A202020202020617065782E64656275672E696E666F286465627567507265666978202B20225265706F727420';
wwv_flow_api.g_varchar2_table(74) := '737769746368206465746563746564222C20726567696F6E43757272656E745265706F727449642C20726567696F6E43757272656E74566965772C2072657175657374446174612E7830312C2063757272656E7456696577293B0D0A202020202020696E';
wwv_flow_api.g_varchar2_table(75) := '6A6563745374796C657328222322202B20726567696F6E4964202B20225F69675F7265706F72745F73657474696E67737B646973706C61793A6E6F6E657D222C726567696F6E4964293B0D0A202020207D0D0A0D0A202020207661722070726F6D697365';
wwv_flow_api.g_varchar2_table(76) := '203D20617065782E7365727665722E706C7567696E286F7074696F6E732E616A61784964656E7469666965722C207265717565737444617461293B0D0A0D0A2020202070726F6D6973652E646F6E652866756E6374696F6E20286461746129207B0D0A0D';
wwv_flow_api.g_varchar2_table(77) := '0A202020202020617065782E64656275672E696E666F286465627567507265666978202B2022414A415820726573756C7473222C2064617461293B0D0A0D0A2020202020206966202873657474696E6773546F486964652E696E6465784F6628223A463A';
wwv_flow_api.g_varchar2_table(78) := '222920213D202D3129207B206869646553657474696E67286F7074696F6E732C20646174612C202266696C74657222293B207D0D0A2020202020206966202873657474696E6773546F486964652E696E6465784F6628223A433A222920213D202D312920';
wwv_flow_api.g_varchar2_table(79) := '7B206869646553657474696E67286F7074696F6E732C20646174612C2022636F6E74726F6C427265616B22293B207D0D0A2020202020206966202873657474696E6773546F486964652E696E6465784F6628223A413A222920213D202D3129207B206869';
wwv_flow_api.g_varchar2_table(80) := '646553657474696E67286F7074696F6E732C20646174612C202261676772656761746522293B207D0D0A2020202020206966202873657474696E6773546F486964652E696E6465784F6628223A483A222920213D202D3129207B20686964655365747469';
wwv_flow_api.g_varchar2_table(81) := '6E67286F7074696F6E732C20646174612C2022686967686C6967687422293B207D0D0A2020202020206966202873657474696E6773546F486964652E696E6465784F6628223A46423A222920213D202D3129207B206869646553657474696E67286F7074';
wwv_flow_api.g_varchar2_table(82) := '696F6E732C20646174612C2022666C6173686261636B22293B207D0D0A0D0A202020202020636C65616E5570286F7074696F6E73293B0D0A0D0A202020202020617065782E64612E726573756D65286F7074696F6E732E64612E726573756D6543616C6C';
wwv_flow_api.g_varchar2_table(83) := '6261636B2C2066616C7365293B0D0A202020207D293B200D0A0D0A20207D0D0A0D0A202066756E6374696F6E20636C65616E5570286F7074696F6E7329207B0D0A0D0A2020202076617220726567696F6E4964203D206F7074696F6E732E64612E616374';
wwv_flow_api.g_varchar2_table(84) := '696F6E2E6166666563746564526567696F6E49643B0D0A20202020696E6A6563745374796C657328226469762322202B20726567696F6E4964202B20225F69675F7265706F72745F73657474696E67735F73756D6D6172797B646973706C61793A626C6F';
wwv_flow_api.g_varchar2_table(85) := '636B7D222C726567696F6E4964293B0D0A0D0A202020202F2F2052656D6F766520426172206966206E6573657373617279200D0A2020202069662028616C6C53657474696E677348696464656E28726567696F6E49642929207B200D0A20202020202069';
wwv_flow_api.g_varchar2_table(86) := '6E6A6563745374796C657328222322202B20726567696F6E4964202B20225F69675F7265706F72745F73657474696E67737B646973706C61793A6E6F6E657D222C726567696F6E4964293B0D0A202020207D20656C7365207B200D0A202020202020696E';
wwv_flow_api.g_varchar2_table(87) := '6A6563745374796C657328222322202B20726567696F6E4964202B20225F69675F7265706F72745F73657474696E67737B646973706C61793A626C6F636B7D222C726567696F6E4964293B0D0A202020207D0D0A20207D0D0A0D0A202066756E6374696F';
wwv_flow_api.g_varchar2_table(88) := '6E206869646553657474696E67286F7074696F6E732C206261736553657474696E67732C20656C656D656E7429207B0D0A2020202076617220726567696F6E4964203D206F7074696F6E732E64612E616374696F6E2E6166666563746564526567696F6E';
wwv_flow_api.g_varchar2_table(89) := '49643B0D0A202020207661722073756D6D617279537472696E67203D2022223B0D0A202020207661722073756D6D617279436F756E74203D20303B0D0A2020202076617220726F6F74456C656D656E74203D206261736553657474696E67732E73657474';
wwv_flow_api.g_varchar2_table(90) := '696E67735B656C656D656E745D3B20200D0A0D0A20202020666F7220287661722069203D20303B2069203C20726F6F74456C656D656E742E6C656E6774683B20692B2B29207B0D0A2020202020202F2F2047656E6572617465205A617020537472696E67';
wwv_flow_api.g_varchar2_table(91) := '0D0A2020202020207661722073657474696E674944203D2022223B0D0A20202020202069662028747970656F6620726F6F74456C656D656E745B695D2E494420213D2022756E646566696E65642229207B0D0A202020202020202073657474696E674944';
wwv_flow_api.g_varchar2_table(92) := '203D20726F6F74456C656D656E745B695D2E49443B0D0A2020202020207D2020202020200D0A202020202020766172207A6170537472696E67203D20222322202B20726567696F6E4964202B2022206C692E612D49472D636F6E74726F6C732D6974656D';
wwv_flow_api.g_varchar2_table(93) := '2D2D22202B20656C656D656E74202B20225B617269612D6C6162656C6C656462793D5C22636F6E74726F6C5F7465787422202B2073657474696E674944202B20225C225D223B0D0A0D0A20202020202069662028726F6F74456C656D656E745B695D2E44';
wwv_flow_api.g_varchar2_table(94) := '454C203D3D202259222026262073686F756C6448696465286F7074696F6E732929207B0D0A2020202020202020696E6A6563745374796C6573287A6170537472696E67202B2022207B20646973706C61793A206E6F6E653B207D222C20726567696F6E49';
wwv_flow_api.g_varchar2_table(95) := '64293B200D0A2020202020207D20656C7365207B202F2F69662028726F6F74456C656D656E745B695D2E44454C203D3D20224E2229207B0D0A2020202020202020696E6A6563745374796C6573287A6170537472696E67202B2022207B20646973706C61';
wwv_flow_api.g_varchar2_table(96) := '793A20626C6F636B3B207D222C20726567696F6E4964293B20200D0A20202020202020206966202820726F6F74456C656D656E745B695D2E49535F454E41424C4544203D3D2022596573222029207B0D0A2020202020202020202073756D6D6172795374';
wwv_flow_api.g_varchar2_table(97) := '72696E67203D2073756D6D617279537472696E67202B20726F6F74456C656D656E745B695D2E4C4142454C202B20222C20223B0D0A2020202020202020202073756D6D617279436F756E742B2B3B0D0A20202020202020207D0D0A2020202020207D0D0A';
wwv_flow_api.g_varchar2_table(98) := '202020207D0D0A0D0A202020202F2F20526577726974652053756D6D6D617279206C6162656C2F636F756E740D0A202020206966202873756D6D617279436F756E74203E203029207B0D0A2020202020202428222322202B20726567696F6E4964202B20';
wwv_flow_api.g_varchar2_table(99) := '225F69675F7265706F72745F73657474696E67735F73756D6D617279202E612D49472D7265706F727453756D6D6172792D6974656D2D2D22202B20656C656D656E74202B2022202E612D49472D7265706F727453756D6D6172792D76616C756522292E74';
wwv_flow_api.g_varchar2_table(100) := '6578742873756D6D617279537472696E672E73756273747228302C2073756D6D617279537472696E672E6C656E677468202D203229293B0D0A2020202020206966202873756D6D617279436F756E74203D3D203129207B0D0A202020202020202073756D';
wwv_flow_api.g_varchar2_table(101) := '6D617279436F756E74203D2022223B0D0A2020202020207D0D0A2020202020202428222322202B20726567696F6E4964202B20225F69675F7265706F72745F73657474696E67735F73756D6D617279202E612D49472D7265706F727453756D6D6172792D';
wwv_flow_api.g_varchar2_table(102) := '6974656D2D2D22202B20656C656D656E74202B2022202E612D49472D7265706F727453756D6D6172792D636F756E7422292E746578742873756D6D617279436F756E74293B0D0A202020202020696E6A6563745374796C657328222322202B2072656769';
wwv_flow_api.g_varchar2_table(103) := '6F6E4964202B20225F69675F7265706F72745F73657474696E67735F73756D6D617279202E612D49472D7265706F727453756D6D6172792D6974656D2D2D22202B20656C656D656E74202B2022207B646973706C61793A20626C6F636B7D222C20726567';
wwv_flow_api.g_varchar2_table(104) := '696F6E4964293B0D0A202020207D20656C7365207B200D0A202020202020696E6A6563745374796C657328222322202B20726567696F6E4964202B20225F69675F7265706F72745F73657474696E67735F73756D6D617279202E612D49472D7265706F72';
wwv_flow_api.g_varchar2_table(105) := '7453756D6D6172792D6974656D2D2D22202B20656C656D656E74202B2022207B646973706C61793A206E6F6E657D222C20726567696F6E4964293B0D0A202020207D0D0A0D0A20207D0D0A0D0A20202F2F2068747470733A2F2F6373732D747269636B73';
wwv_flow_api.g_varchar2_table(106) := '2E636F6D2F736E6970706574732F6A6176617363726970742F696E6A6563742D6E65772D6373732D72756C65732F0D0A202066756E6374696F6E20696E6A6563745374796C65732872756C652C20726567696F6E496429207B0D0A202020207661722063';
wwv_flow_api.g_varchar2_table(107) := '6F6E7461696E6572203D2022696748696773435353496E6A656374696F6E436F6E7461696E6572223B0D0A0D0A202020202F2F204372656174650D0A2020202069662028202428222322202B20636F6E7461696E6572292E6C656E677468203D3D203020';
wwv_flow_api.g_varchar2_table(108) := '29207B0D0A2020202020202428223C646976202F3E222C207B0D0A202020202020202069643A20636F6E7461696E65720D0A2020202020207D292E617070656E64546F2822626F647922293B202020200D0A202020207D0D0A2020202076617220646976';
wwv_flow_api.g_varchar2_table(109) := '203D202428223C646976202F3E222C207B0D0A20202020202068746D6C3A20223C7374796C653E22202B2072756C65202B20223C2F7374796C653E222C0D0A202020202020636C6173733A2022696748696773496E6A6563745374796C65732D22202B20';
wwv_flow_api.g_varchar2_table(110) := '726567696F6E4964202B20222D22202B2067657443757272656E745265706F7274496428726567696F6E4964290D0A202020207D292E617070656E64546F282428222322202B20636F6E7461696E657229293B202020200D0A20207D0D0A0D0A20202F2F';
wwv_flow_api.g_varchar2_table(111) := '2068747470733A2F2F737461636B6F766572666C6F772E636F6D2F612F373137383338310D0A202066756E6374696F6E2066696E6457697468417474722861727261792C20617474722C2076616C756529207B0D0A20202020666F722028766172206920';
wwv_flow_api.g_varchar2_table(112) := '3D20303B2069203C2061727261792E6C656E6774683B2069202B3D203129207B0D0A2020202020206966202861727261795B695D5B617474725D203D3D3D2076616C756529207B0D0A202020202020202072657475726E20693B0D0A2020202020207D0D';
wwv_flow_api.g_varchar2_table(113) := '0A202020207D0D0A2020202072657475726E202D313B0D0A20207D0D0A0D0A20202F2F2068747470733A2F2F6769746875622E636F6D2F6D676F7269636B692F617065782D706C7567696E2D657874656E642D69672D746F6F6C6261720D0A202066756E';
wwv_flow_api.g_varchar2_table(114) := '6374696F6E20657874656E6447726964546F6F6C626172286F7074696F6E732C207052656D6F76654F6E6C7929207B0D0A0D0A20202020766172206461203D206F7074696F6E732E64613B0D0A20202020617065782E64656275672E696E666F28646562';
wwv_flow_api.g_varchar2_table(115) := '7567507265666978202B2022657874656E6447726964546F6F6C626172222C206461293B0D0A0D0A202020202F2F2067657420706C7567696E20617474726962757465730D0A20202020766172207647726F7570203D2022616374696F6E7334223B0D0A';
wwv_flow_api.g_varchar2_table(116) := '202020207661722076506F736974696F6E203D202246223B0D0A2020202076617220764C6162656C203D2022557365722056696577223B0D0A202020207661722076486F74203D2066616C73653B0D0A20202020766172207649636F6E3B0D0A20202020';
wwv_flow_api.g_varchar2_table(117) := '766172207649636F6E4F6E6C79203D2066616C73653B0D0A20202020766172207649636F6E506F736974696F6E203D20747275653B0D0A2020202076617220765469746C65203D2022444556454C4F50455253204F4E4C593A20546F67676C6520776861';
wwv_flow_api.g_varchar2_table(118) := '7420746865207573657220776F756C64207365652028692E65207468652055736572205669657729206F6E206F72206F6666223B0D0A202020207661722076416374696F6E203D20226967486967734D6F6465223B0D0A20202020766172207644697361';
wwv_flow_api.g_varchar2_table(119) := '626C6564203D2066616C73653B0D0A20202020766172207648696464656E203D2066616C73653B0D0A2020202076617220764944203D2022696748696773557365724D6F6465427574746F6E223B0D0A0D0A202020202F2F2067657420526567696F6E0D';
wwv_flow_api.g_varchar2_table(120) := '0A202020207661722076526567696F6E4964203D2064612E6166666563746564456C656D656E74735B305D2E69643B200D0A2020202076617220757365724D6F6465203D20676574557365724D6F64652876526567696F6E4964293B0D0A0D0A20202020';
wwv_flow_api.g_varchar2_table(121) := '2F2F20636865636B2069636F6E200D0A2020202069662028757365724D6F6465203D3D2022592229207B0D0A2020202020207649636F6E203D202266612066612D636865636B2D7371756172652D6F223B0D0A202020207D20656C7365207B0D0A202020';
wwv_flow_api.g_varchar2_table(122) := '2020207649636F6E203D202266612066612D7371756172652D6F223B0D0A202020207D0D0A0D0A202020202F2F20476574205769646765740D0A20202020766172207657696467657424203D20617065782E726567696F6E2876526567696F6E4964292E';
wwv_flow_api.g_varchar2_table(123) := '77696467657428293B0D0A0D0A202020202F2F204772696420637265617465640D0A2020202076617220746F6F6C626172203D2076576964676574242E696E746572616374697665477269642822676574546F6F6C62617222293B0D0A0D0A2020202076';
wwv_flow_api.g_varchar2_table(124) := '6172207661427574746F6E203D207B0D0A202020202020747970653A2022425554544F4E222C0D0A2020202020206C6162656C3A20764C6162656C2C0D0A2020202020207469746C653A20765469746C652C0D0A2020202020206C6162656C4B65793A20';
wwv_flow_api.g_varchar2_table(125) := '764C6162656C2C202F2F206C6162656C2066726F6D2074657874206D657373616765730D0A202020202020616374696F6E3A2076416374696F6E2C0D0A20202020202069636F6E3A207649636F6E2C0D0A20202020202069636F6E4F6E6C793A20764963';
wwv_flow_api.g_varchar2_table(126) := '6F6E4F6E6C792C0D0A20202020202069636F6E4265666F72654C6162656C3A207649636F6E506F736974696F6E2C0D0A202020202020686F743A2076486F742C0D0A20202020202069643A207649440D0A202020207D3B0D0A0D0A202020207661722063';
wwv_flow_api.g_varchar2_table(127) := '6F6E666967203D20242E657874656E6428747275652C207B7D2C20746F6F6C6261722E746F6F6C62617228226F7074696F6E2229293B0D0A2020202076617220746F6F6C62617244617461203D20636F6E6669672E646174613B0D0A2020202076617220';
wwv_flow_api.g_varchar2_table(128) := '746F6F6C62617247726F7570203D20746F6F6C626172446174612E66696C7465722866756E6374696F6E202867726F757029207B0D0A20202020202072657475726E2067726F75702E6964203D3D3D207647726F75703B0D0A202020207D295B305D3B0D';
wwv_flow_api.g_varchar2_table(129) := '0A0D0A2020202076617220627574746F6E496478203D2066696E64576974684174747228746F6F6C62617247726F75702E636F6E74726F6C732C20226964222C20764944293B0D0A2020202069662028627574746F6E496478203E202D3129207B0D0A20';
wwv_flow_api.g_varchar2_table(130) := '2020202020746F6F6C62617247726F75702E636F6E74726F6C732E73706C69636528627574746F6E4964782C2031293B0D0A202020207D0D0A0D0A2020202069662028217052656D6F76654F6E6C7929207B0D0A20202020202069662028746F6F6C6261';
wwv_flow_api.g_varchar2_table(131) := '7247726F757029207B0D0A20202020202020206966202876506F736974696F6E203D3D2022462229207B0D0A20202020202020202020746F6F6C62617247726F75702E636F6E74726F6C732E756E7368696674287661427574746F6E293B0D0A20202020';
wwv_flow_api.g_varchar2_table(132) := '202020207D20656C7365207B0D0A20202020202020202020746F6F6C62617247726F75702E636F6E74726F6C732E70757368287661427574746F6E293B0D0A20202020202020207D0D0A2020202020207D0D0A0D0A202020202020746F6F6C6261722E74';
wwv_flow_api.g_varchar2_table(133) := '6F6F6C62617228226F7074696F6E222C202264617461222C20636F6E6669672E64617461293B0D0A0D0A2020202020202F2F2061646420616374696F6E730D0A2020202020207661722076416374696F6E73203D2076576964676574242E696E74657261';
wwv_flow_api.g_varchar2_table(134) := '6374697665477269642822676574416374696F6E7322293B0D0A0D0A2020202020202F2F20636865636B20696620616374696F6E206578697374732C207468656E206A7573742061737369676E2069740D0A2020202020207661722076416374696F6E24';
wwv_flow_api.g_varchar2_table(135) := '203D2076416374696F6E732E6C6F6F6B75702876416374696F6E293B0D0A202020202020696620282176416374696F6E2429207B0D0A202020202020202076416374696F6E732E616464280D0A202020202020202020207B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(136) := '20206E616D653A2076416374696F6E2C200D0A202020202020202020202020616374696F6E3A2066756E6374696F6E20285F6576656E742C205F656C656D656E7429207B0D0A20202020202020202020202020202F2F202D2D2053746172742041637469';
wwv_flow_api.g_varchar2_table(137) := '6F6E20436F6465200D0A202020202020202020202020202076617220757365724D6F6465203D20676574557365724D6F64652876526567696F6E4964293B0D0A2020202020202020202020202020766172206E6577557365724D6F64653B0D0A20202020';
wwv_flow_api.g_varchar2_table(138) := '2020202020202020202069662028757365724D6F6465203D3D2022592229207B206E6577557365724D6F6465203D20224E223B207D20656C7365207B206E6577557365724D6F6465203D202259223B207D0D0A2020202020202020202020202020736574';
wwv_flow_api.g_varchar2_table(139) := '557365724D6F64652876526567696F6E49642C206E6577557365724D6F6465293B0D0A0D0A2020202020202020202020202020696620286E6577557365724D6F6465203D3D20224E22202626206170706C696573546F43757272656E745265706F727428';
wwv_flow_api.g_varchar2_table(140) := '6F7074696F6E732929207B0D0A20202020202020202020202020202020726573746F72655573657256696577286F7074696F6E73293B0D0A20202020202020202020202020207D0D0A0D0A20202020202020202020202020202F2F205075742074686520';
wwv_flow_api.g_varchar2_table(141) := '20627574746F6E206261636B206F6E2077697468206E65772069636F6E0D0A2020202020202020202020202020657874656E6447726964546F6F6C626172286F7074696F6E73293B0D0A20202020202020202020202020202F2F202D2D20456E64204163';
wwv_flow_api.g_varchar2_table(142) := '74696F6E20636F64650D0A2020202020202020202020207D2C200D0A202020202020202020202020686964653A207648696464656E2C200D0A20202020202020202020202064697361626C65643A207644697361626C65640D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(143) := '7D293B0D0A2020202020207D20656C7365207B0D0A202020202020202076416374696F6E242E68696465203D207648696464656E3B0D0A202020202020202076416374696F6E242E64697361626C6564203D207644697361626C65643B0D0A2020202020';
wwv_flow_api.g_varchar2_table(144) := '207D0D0A202020207D20656C7365207B0D0A202020202020746F6F6C6261722E746F6F6C62617228226F7074696F6E222C202264617461222C20636F6E6669672E64617461293B0D0A202020207D0D0A0D0A202020202F2F207265667265736820677269';
wwv_flow_api.g_varchar2_table(145) := '640D0A20202020746F6F6C6261722E746F6F6C62617228227265667265736822293B0D0A20207D0D0A0D0A20202F2F205075626C69632066756E6374696F6E730D0A202072657475726E20287B0D0A2020202072656E6465723A2072656E6465720D0A20';
wwv_flow_api.g_varchar2_table(146) := '207D293B0D0A0D0A7D2829293B0D0A2F2F2320736F757263654D617070696E6755524C3D6578706C6F7265724967486967732E6A732E6D61700D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(5912014325456205)
,p_plugin_id=>wwv_flow_api.id(4906257124580834)
,p_file_name=>'js/explorerIgHigs.js'
,p_mime_type=>'application/x-javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C226E616D6573223A5B5D2C226D617070696E6773223A22222C22736F7572636573223A5B226578706C6F7265724967486967732E6A73225D2C22736F7572636573436F6E74656E74223A5B222F2A2065736C696E742D64';
wwv_flow_api.g_varchar2_table(2) := '697361626C65206E6F2D756E757365642D76617273202A2F5C725C6E2F2F2065736C696E742D64697361626C652D6E6578742D6C696E65206E6F2D756E6465665C725C6E6578706C6F726572496748696773203D202866756E6374696F6E202829207B5C';
wwv_flow_api.g_varchar2_table(3) := '725C6E20205C22757365207374726963745C223B5C725C6E5C725C6E2020766172206368616E67655265706F727453656C6563746F72203D205C222E612D546F6F6C6261722D73656C6563744C6973745B646174612D616374696F6E3D5C5C5C22636861';
wwv_flow_api.g_varchar2_table(4) := '6E67652D7265706F72745C5C5C225D5C223B5C725C6E2020766172206465627567507265666978203D205C224578706C6F7265722049474849475320506C7567696E3A205C223B5C725C6E5C725C6E2020766172206E766C203D2066756E6374696F6E20';
wwv_flow_api.g_varchar2_table(5) := '6E766C2876616C7565312C2076616C75653229207B5C725C6E202020206966202876616C756531203D3D206E756C6C207C7C2076616C756531203D3D205C225C22295C725C6E20202020202072657475726E2076616C7565323B5C725C6E202020207265';
wwv_flow_api.g_varchar2_table(6) := '7475726E2076616C7565313B5C725C6E20207D3B5C725C6E5C725C6E202066756E6374696F6E20676574557365724D6F646528704967537461746963496429207B5C725C6E2020202072657475726E206E766C2873657373696F6E53746F726167652E67';
wwv_flow_api.g_varchar2_table(7) := '65744974656D285C222E5C22202B20617065782E6974656D285C2270466C6F7749645C22292E67657456616C75652829202B205C222E5C22202B20617065782E6974656D285C2270466C6F775374657049645C22292E67657456616C75652829202B205C';
wwv_flow_api.g_varchar2_table(8) := '222E6967486967732E5C22202B207049675374617469634964292C205C224E5C22293B5C725C6E20207D5C725C6E5C725C6E202066756E6374696F6E20736574557365724D6F64652870496753746174696349642C207056616C756529207B5C725C6E20';
wwv_flow_api.g_varchar2_table(9) := '20202073657373696F6E53746F726167652E7365744974656D285C222E5C22202B20617065782E6974656D285C2270466C6F7749645C22292E67657456616C75652829202B205C222E5C22202B20617065782E6974656D285C2270466C6F775374657049';
wwv_flow_api.g_varchar2_table(10) := '645C22292E67657456616C75652829202B205C222E6967486967732E5C22202B2070496753746174696349642C207056616C7565293B5C725C6E20207D5C725C6E5C725C6E202066756E6374696F6E206973446576656C6F706572287049675374617469';
wwv_flow_api.g_varchar2_table(11) := '63496429207B5C725C6E2020202072657475726E20617065782E726567696F6E287049675374617469634964292E63616C6C285C226F7074696F6E5C222C205C22636F6E6669675C22292E66656174757265732E736176655265706F72742E6973446576';
wwv_flow_api.g_varchar2_table(12) := '656C6F7065723B5C725C6E20207D5C725C6E5C725C6E202066756E6374696F6E20616C6C53657474696E677348696464656E28704967537461746963496429207B5C725C6E2020202072657475726E202824285C22235C22202B20704967537461746963';
wwv_flow_api.g_varchar2_table(13) := '4964202B205C22202E612D49472D636F6E74726F6C735C22292E6368696C6472656E28292E66696C7465722866756E6374696F6E20285F696E64657829207B5C725C6E20202020202072657475726E20242874686973292E637373285C22646973706C61';
wwv_flow_api.g_varchar2_table(14) := '795C2229203D3D3D205C22626C6F636B5C223B5C725C6E202020207D292E6C656E677468203D3D2030293B5C725C6E20207D5C725C6E5C725C6E202066756E6374696F6E206170706C696573546F43757272656E745265706F7274286F7074696F6E7329';
wwv_flow_api.g_varchar2_table(15) := '207B5C725C6E2020202076617220726567696F6E4964203D206F7074696F6E732E64612E616374696F6E2E6166666563746564526567696F6E49643B5C725C6E20202020766172206170706C79546F5265706F727473203D206F7074696F6E732E64612E';
wwv_flow_api.g_varchar2_table(16) := '616374696F6E2E61747472696275746530323B5C725C6E202020207661722063757272656E745265706F727454797065203D2067657443757272656E745265706F72745479706528726567696F6E4964293B5C725C6E202020207661722072657475726E';
wwv_flow_api.g_varchar2_table(17) := '426F6F6C65616E203D2066616C73653B205C725C6E2020202069662028206170706C79546F5265706F72747320213D206E756C6C29207B5C725C6E20202020202072657475726E426F6F6C65616E203D2020286170706C79546F5265706F7274732E7370';
wwv_flow_api.g_varchar2_table(18) := '6C6974285C223A5C22292E696E6465784F662863757272656E745265706F7274547970652920213D202D31293B5C725C6E202020207D5C725C6E2020202072657475726E2072657475726E426F6F6C65616E3B5C725C6E20207D5C725C6E5C725C6E2020';
wwv_flow_api.g_varchar2_table(19) := '66756E6374696F6E2073686F756C6448696465286F7074696F6E7329207B5C725C6E2020202076617220726567696F6E4964203D206F7074696F6E732E64612E616374696F6E2E6166666563746564526567696F6E49643B5C725C6E2020202072657475';
wwv_flow_api.g_varchar2_table(20) := '726E20285C725C6E2020202020206170706C696573546F43757272656E745265706F7274286F7074696F6E73292026265C725C6E2020202020202F2F204170706C69657320746F2063757272656E74207265706F727420616E642E2E2E5C725C6E202020';
wwv_flow_api.g_varchar2_table(21) := '2020202F2F202E2E2E6973206120646576656C6F70657220616E64206D6173717565726164696E6720617320612075736572204F52206120757365725C725C6E20202020202028286973446576656C6F70657228726567696F6E49642920262620676574';
wwv_flow_api.g_varchar2_table(22) := '557365724D6F646528726567696F6E496429203D3D205C22595C2229207C7C202821286973446576656C6F70657228726567696F6E4964292929295C725C6E20202020293B5C725C6E20207D5C725C6E5C725C6E202066756E6374696F6E206765744375';
wwv_flow_api.g_varchar2_table(23) := '7272656E745265706F72745479706528704967537461746963496429207B5C725C6E20202020766172207265706F7274734172726179203D20617065782E726567696F6E287049675374617469634964292E63616C6C285C226765745265706F7274735C';
wwv_flow_api.g_varchar2_table(24) := '22293B5C725C6E202020207661722072496478203D2066696E645769746841747472287265706F72747341727261792C205C2269645C222C2067657443757272656E745265706F7274496428704967537461746963496429293B5C725C6E202020207661';
wwv_flow_api.g_varchar2_table(25) := '72206C52657475726E203D205C225C223B5C725C6E20202020696620287249647820213D202D3129207B5C725C6E2020202020206C52657475726E203D207265706F72747341727261795B724964785D2E747970653B5C725C6E202020207D5C725C6E20';
wwv_flow_api.g_varchar2_table(26) := '20202072657475726E206C52657475726E3B5C725C6E20207D5C725C6E5C725C6E202066756E6374696F6E207573657253657474696E677356696577427574746F6E286F7074696F6E7329207B5C725C6E2020202076617220726567696F6E4964203D20';
wwv_flow_api.g_varchar2_table(27) := '6F7074696F6E732E64612E616374696F6E2E6166666563746564526567696F6E49643B5C725C6E20202020696620286973446576656C6F70657228726567696F6E4964292029202F2F2626206170706C696573546F43757272656E745265706F7274286F';
wwv_flow_api.g_varchar2_table(28) := '7074696F6E73292029205C725C6E202020207B5C725C6E202020202020657874656E6447726964546F6F6C626172286F7074696F6E73293B5C725C6E202020207D20656C7365207B5C725C6E202020202020657874656E6447726964546F6F6C62617228';
wwv_flow_api.g_varchar2_table(29) := '6F7074696F6E732C7472756520293B5C725C6E202020207D5C725C6E20207D5C725C6E5C725C6E202066756E6374696F6E20726573746F72655573657256696577286F7074696F6E73297B5C725C6E20202020617065782E64656275672E696E666F2864';
wwv_flow_api.g_varchar2_table(30) := '65627567507265666978202B205C22726573746F726555736572566965775C22293B5C725C6E202020207661722076526567696F6E4964203D206F7074696F6E732E64612E616374696F6E2E6166666563746564526567696F6E49643B5C725C6E202020';
wwv_flow_api.g_varchar2_table(31) := '202F2F2052656D6F76652043535320696E6A656374696F6E7320666F72207468652063757272656E74207265706F72745C725C6E2020202024285C222E696748696773496E6A6563745374796C65732D5C22202B2076526567696F6E4964202B205C222D';
wwv_flow_api.g_varchar2_table(32) := '5C22202B2067657443757272656E745265706F727449642876526567696F6E49642920292E7265706C6163655769746828293B5C725C6E20202020636C65616E5570286F7074696F6E73293B5C725C6E20207D5C725C6E5C725C6E20207661722072656E';
wwv_flow_api.g_varchar2_table(33) := '646572203D2066756E6374696F6E2072656E646572286F7074696F6E7329207B5C725C6E2020202076617220726567696F6E4964203D206F7074696F6E732E64612E616374696F6E2E6166666563746564526567696F6E49643B5C725C6E202020206170';
wwv_flow_api.g_varchar2_table(34) := '65782E64656275672E696E666F286465627567507265666978202B205C2252656E6465725C22293B5C725C6E20202020617065782E64656275672E696E666F2864656275675072656669782C206F7074696F6E73293B5C725C6E5C725C6E202020202F2F';
wwv_flow_api.g_varchar2_table(35) := '20436865636B207468697320697320616E2049475C725C6E202020206966202824285C22235C22202B20726567696F6E4964202B205C22202E612D49475C22292E6C656E677468203D3D203029207B5C725C6E202020202020617065782E64656275672E';
wwv_flow_api.g_varchar2_table(36) := '696E666F286465627567507265666978202B205C224572726F723A20526567696F6E205C22202B20726567696F6E4964202B205C22206973206E6F7420616E20496E74657261637469766520477269645C22293B5C725C6E20202020202072657475726E';
wwv_flow_api.g_varchar2_table(37) := '3B5C725C6E202020207D5C725C6E202020205C725C6E202020207573657253657474696E677356696577427574746F6E286F7074696F6E73293B5C725C6E5C725C6E202020202F2F20416464206576656E74735C725C6E2020202024285C22235C22202B';
wwv_flow_api.g_varchar2_table(38) := '20726567696F6E4964292E6F6E285C22696E746572616374697665677269647265706F727473657474696E67736368616E67655C222C2066756E6374696F6E20285F6576656E742C205F6461746129207B5C725C6E202020202020617065782E64656275';
wwv_flow_api.g_varchar2_table(39) := '672E696E666F286465627567507265666978202B205C224576656E74202D2053657474696E6773204368616E67655C22293B5C725C6E2020202020206966202873686F756C6448696465286F7074696F6E732929207B205C725C6E202020202020202069';
wwv_flow_api.g_varchar2_table(40) := '6E6A6563745374796C6573285C22646976235C22202B20726567696F6E4964202B205C225F69675F7265706F72745F73657474696E67735F73756D6D6172797B646973706C61793A6E6F6E657D5C222C726567696F6E4964293B5C725C6E202020202020';
wwv_flow_api.g_varchar2_table(41) := '7D5C725C6E202020202020616A617847657453657474696E6773746F48696465286F7074696F6E73293B5C725C6E202020207D293B5C725C6E5C725C6E2020202024285C22235C22202B20726567696F6E4964292E6F6E285C22696E7465726163746976';
wwv_flow_api.g_varchar2_table(42) := '6567726964766965776368616E67655C222C2066756E6374696F6E20285F6576656E742C205F6461746129207B5C725C6E202020202020617065782E64656275672E696E666F286465627567507265666978202B205C224576656E74202D204772696420';
wwv_flow_api.g_varchar2_table(43) := '56696577204368616E67655C22293B205C725C6E2020202020207573657253657474696E677356696577427574746F6E286F7074696F6E73293B5C725C6E2020202020206966202873686F756C6448696465286F7074696F6E732929207B205C725C6E20';
wwv_flow_api.g_varchar2_table(44) := '20202020202020696E6A6563745374796C6573285C22646976235C22202B20726567696F6E4964202B205C225F69675F7265706F72745F73657474696E67735F73756D6D6172797B646973706C61793A6E6F6E657D5C222C726567696F6E4964293B5C72';
wwv_flow_api.g_varchar2_table(45) := '5C6E2020202020207D5C725C6E202020202020616A617847657453657474696E6773746F48696465286F7074696F6E73293B5C725C6E202020207D293B5C725C6E5C725C6E202020202F2F205573652061206D61746368657320706F6C7966696C6C2066';
wwv_flow_api.g_varchar2_table(46) := '6F72204945392B5C725C6E202020202F2F2068747470733A2F2F646576656C6F7065722E6D6F7A696C6C612E6F72672F656E2D55532F646F63732F5765622F4150492F456C656D656E742F6D6174636865735C725C6E202020206966202821456C656D65';
wwv_flow_api.g_varchar2_table(47) := '6E742E70726F746F747970652E6D61746368657329207B5C725C6E202020202020456C656D656E742E70726F746F747970652E6D617463686573203D20456C656D656E742E70726F746F747970652E6D734D61746368657353656C6563746F72207C7C5C';
wwv_flow_api.g_varchar2_table(48) := '725C6E2020202020202020456C656D656E742E70726F746F747970652E7765626B69744D61746368657353656C6563746F723B5C725C6E202020207D5C725C6E5C725C6E20202020766172206D75746174696F6E4F62736572766572203D206E6577204D';
wwv_flow_api.g_varchar2_table(49) := '75746174696F6E4F627365727665722866756E6374696F6E20286D75746174696F6E7329207B5C725C6E2020202020202F2F204C6F6F6B20666F7220706F74656E7469616C6C79206368616E67652D7265706F72742072656C61746564206D7574617469';
wwv_flow_api.g_varchar2_table(50) := '6F6E7320696E204A53206173204A517565727920697473656C66206361757365732061206D75746174696F6E5C725C6E202020202020766172206D75746174696F6E53656C6563746F72203D206368616E67655265706F727453656C6563746F723B5C72';
wwv_flow_api.g_varchar2_table(51) := '5C6E202020202020696620286D75746174696F6E735B305D2E7461726765742E6D617463686573286D75746174696F6E53656C6563746F7229207C7C5C725C6E20202020202020206D75746174696F6E735B305D2E7461726765742E717565727953656C';
wwv_flow_api.g_varchar2_table(52) := '6563746F72416C6C286D75746174696F6E53656C6563746F72292E6C656E677468203E203029207B5C725C6E2020202020202020617065782E64656275672E696E666F286465627567507265666978202B205C224576656E74202D206D75746174696F6E';
wwv_flow_api.g_varchar2_table(53) := '4F627365727665725C22293B5C725C6E20202020202020206966202873686F756C6448696465286F7074696F6E732929207B5C725C6E20202020202020202F2F206D75746174696F6E20697320706F74656E7469616C6C79206368616E67652D7265706F';
wwv_flow_api.g_varchar2_table(54) := '72742072656C617465645C725C6E20202020202020202020696E6A6563745374796C6573285C22646976235C22202B20726567696F6E4964202B205C225F69675F7265706F72745F73657474696E67735F73756D6D6172797B646973706C61793A6E6F6E';
wwv_flow_api.g_varchar2_table(55) := '657D5C222C726567696F6E4964293B5C725C6E20202020202020207D5C725C6E2020202020202020616A617847657453657474696E6773746F48696465286F7074696F6E73293B5C725C6E2020202020207D205C725C6E202020207D293B5C725C6E5C72';
wwv_flow_api.g_varchar2_table(56) := '5C6E202020202F2F206D75746174696F6E206F6273657276657220636865636B696E6720746F6F6F6C62617220666F72206D75746174696F6E732E205C725C6E202020202F2F2077652061726520756E61626C6520746F20706C616365206F6273657276';
wwv_flow_api.g_varchar2_table(57) := '6572206F6E20746865206368616E6765207265706F72742073656C656374206C69737420617320657874656E64696E672074686520746F6F6C6261722072656D6F76657320746865206F627365727665725C725C6E202020206D75746174696F6E4F6273';
wwv_flow_api.g_varchar2_table(58) := '65727665722E6F6273657276652824285C22235C22202B20726567696F6E4964202B205C225F69675F746F6F6C6261725C22295B305D2C207B5C725C6E202020202020617474726962757465733A20747275652C5C725C6E202020202020636861726163';
wwv_flow_api.g_varchar2_table(59) := '746572446174613A20747275652C5C725C6E2020202020206368696C644C6973743A20747275652C5C725C6E202020202020737562747265653A20747275652C5C725C6E2020202020206174747269627574654F6C6456616C75653A20747275652C5C72';
wwv_flow_api.g_varchar2_table(60) := '5C6E202020202020636861726163746572446174614F6C6456616C75653A20747275655C725C6E202020207D293B5C725C6E5C725C6E202020202F2F20506C7567696E20496E697469616C20537461727475705C725C6E20202020616A61784765745365';
wwv_flow_api.g_varchar2_table(61) := '7474696E6773746F48696465286F7074696F6E73293B205C725C6E5C725C6E20207D3B5C725C6E5C725C6E20207661722067657443757272656E745265706F72744964203D2066756E6374696F6E2067657443757272656E745265706F72744964287049';
wwv_flow_api.g_varchar2_table(62) := '67537461746963496429207B5C725C6E20202020766172207265745265706F727449643B5C725C6E20202020747279207B5C725C6E2020202020207661722067726964203D20617065782E726567696F6E287049675374617469634964292E63616C6C28';
wwv_flow_api.g_varchar2_table(63) := '5C2267657443757272656E74566965775C22293B5C725C6E202020202020766172206D6F64656C203D20677269642E6D6F64656C3B5C725C6E202020202020696620286D6F64656C29207B5C725C6E20202020202020207265745265706F72744964203D';
wwv_flow_api.g_varchar2_table(64) := '20617065782E726567696F6E287049675374617469634964292E63616C6C285C2267657443757272656E74566965775C22292E6D6F64656C2E6765744F7074696F6E285C22726567696F6E446174615C22292E7265706F727449643B5C725C6E20202020';
wwv_flow_api.g_varchar2_table(65) := '20207D20656C7365207B5C725C6E20202020202020202F2F204D6F64656C206F6276696F75736C79206E6F74206578697374732C20706F737369626C79206120636861727420766965772C207468657265666F72652064656661756C7420746F20746865';
wwv_flow_api.g_varchar2_table(66) := '2073656C656374206C69737420696620706F737369626C655C725C6E20202020202020207265745265706F72744964203D2024285C22235C22202B207049675374617469634964292E66696E64286368616E67655265706F727453656C6563746F72295B';
wwv_flow_api.g_varchar2_table(67) := '305D2E76616C75653B5C725C6E2020202020207D5C725C6E202020207D5C725C6E202020206361746368202865727229207B5C725C6E2020202020207265745265706F72744964203D2024285C22235C22202B207049675374617469634964292E66696E';
wwv_flow_api.g_varchar2_table(68) := '64286368616E67655265706F727453656C6563746F72295B305D2E76616C75653B5C725C6E202020207D5C725C6E5C725C6E2020202072657475726E207265745265706F727449643B5C725C6E20207D3B5C725C6E5C725C6E5C725C6E202066756E6374';
wwv_flow_api.g_varchar2_table(69) := '696F6E20616A617847657453657474696E6773746F48696465286F7074696F6E7329207B5C725C6E5C725C6E20202020766172207265717565737444617461203D207B7D3B5C725C6E2020202076617220726567696F6E4964203D206F7074696F6E732E';
wwv_flow_api.g_varchar2_table(70) := '64612E616374696F6E2E6166666563746564526567696F6E49643B205C725C6E202020207661722073657474696E6773546F48696465203D205C223A5C22202B206F7074696F6E732E64612E616374696F6E2E6174747269627574653031202B205C223A';
wwv_flow_api.g_varchar2_table(71) := '5C223B202020205C725C6E20202020766172206170706C79546F5265706F727473203D206F7074696F6E732E64612E616374696F6E2E61747472696275746530323B5C725C6E2020202072657175657374446174612E783031203D206765744375727265';
wwv_flow_api.g_varchar2_table(72) := '6E745265706F7274496428726567696F6E4964293B5C725C6E2020202072657175657374446174612E783032203D20726567696F6E49643B5C725C6E2020202072657175657374446174612E783033203D2073657474696E6773546F486964653B5C725C';
wwv_flow_api.g_varchar2_table(73) := '6E2020202072657175657374446174612E783034203D206170706C79546F5265706F7274733B5C725C6E5C725C6E202020202F2F2053746F7020676C69746368207768656E206368616E67696E67207265706F72745C725C6E2020202076617220726567';
wwv_flow_api.g_varchar2_table(74) := '696F6E43757272656E745265706F72744964203D2024285C22235C22202B20726567696F6E4964292E61747472285C2269674869677343757272656E745265706F727449645C22293B5C725C6E2020202076617220726567696F6E43757272656E745669';
wwv_flow_api.g_varchar2_table(75) := '6577203D2024285C22235C22202B20726567696F6E4964292E61747472285C2269674869677343757272656E74566965775C22293B5C725C6E202020207661722063757272656E7456696577203D20617065782E726567696F6E28726567696F6E496429';
wwv_flow_api.g_varchar2_table(76) := '2E63616C6C285C2267657443757272656E74566965775C22292E696E7465726E616C4964656E7469666965723B5C725C6E5C725C6E2020202024285C22235C22202B20726567696F6E4964292E61747472285C2269674869677343757272656E74526570';
wwv_flow_api.g_varchar2_table(77) := '6F727449645C222C2072657175657374446174612E783031293B5C725C6E2020202024285C22235C22202B20726567696F6E4964292E61747472285C2269674869677343757272656E74566965775C222C2063757272656E7456696577293B5C725C6E5C';
wwv_flow_api.g_varchar2_table(78) := '725C6E20202020696620282073686F756C6448696465286F7074696F6E73292026265C725C6E2020202020202020202820282072657175657374446174612E78303120213D20726567696F6E43757272656E745265706F727449642029207C7C205C725C';
wwv_flow_api.g_varchar2_table(79) := '6E202020202020202020282063757272656E745669657720213D20726567696F6E43757272656E7456696577202929205C725C6E2020202029207B5C725C6E202020202020617065782E64656275672E696E666F286465627567507265666978202B205C';
wwv_flow_api.g_varchar2_table(80) := '225265706F7274207377697463682064657465637465645C222C20726567696F6E43757272656E745265706F727449642C20726567696F6E43757272656E74566965772C2072657175657374446174612E7830312C2063757272656E7456696577293B5C';
wwv_flow_api.g_varchar2_table(81) := '725C6E202020202020696E6A6563745374796C6573285C22235C22202B20726567696F6E4964202B205C225F69675F7265706F72745F73657474696E67737B646973706C61793A6E6F6E657D5C222C726567696F6E4964293B5C725C6E202020207D5C72';
wwv_flow_api.g_varchar2_table(82) := '5C6E5C725C6E202020207661722070726F6D697365203D20617065782E7365727665722E706C7567696E286F7074696F6E732E616A61784964656E7469666965722C207265717565737444617461293B5C725C6E5C725C6E2020202070726F6D6973652E';
wwv_flow_api.g_varchar2_table(83) := '646F6E652866756E6374696F6E20286461746129207B5C725C6E5C725C6E202020202020617065782E64656275672E696E666F286465627567507265666978202B205C22414A415820726573756C74735C222C2064617461293B5C725C6E5C725C6E2020';
wwv_flow_api.g_varchar2_table(84) := '202020206966202873657474696E6773546F486964652E696E6465784F66285C223A463A5C222920213D202D3129207B206869646553657474696E67286F7074696F6E732C20646174612C205C2266696C7465725C22293B207D5C725C6E202020202020';
wwv_flow_api.g_varchar2_table(85) := '6966202873657474696E6773546F486964652E696E6465784F66285C223A433A5C222920213D202D3129207B206869646553657474696E67286F7074696F6E732C20646174612C205C22636F6E74726F6C427265616B5C22293B207D5C725C6E20202020';
wwv_flow_api.g_varchar2_table(86) := '20206966202873657474696E6773546F486964652E696E6465784F66285C223A413A5C222920213D202D3129207B206869646553657474696E67286F7074696F6E732C20646174612C205C226167677265676174655C22293B207D5C725C6E2020202020';
wwv_flow_api.g_varchar2_table(87) := '206966202873657474696E6773546F486964652E696E6465784F66285C223A483A5C222920213D202D3129207B206869646553657474696E67286F7074696F6E732C20646174612C205C22686967686C696768745C22293B207D5C725C6E202020202020';
wwv_flow_api.g_varchar2_table(88) := '6966202873657474696E6773546F486964652E696E6465784F66285C223A46423A5C222920213D202D3129207B206869646553657474696E67286F7074696F6E732C20646174612C205C22666C6173686261636B5C22293B207D5C725C6E5C725C6E2020';
wwv_flow_api.g_varchar2_table(89) := '20202020636C65616E5570286F7074696F6E73293B5C725C6E5C725C6E202020202020617065782E64612E726573756D65286F7074696F6E732E64612E726573756D6543616C6C6261636B2C2066616C7365293B5C725C6E202020207D293B205C725C6E';
wwv_flow_api.g_varchar2_table(90) := '5C725C6E20207D5C725C6E5C725C6E202066756E6374696F6E20636C65616E5570286F7074696F6E7329207B5C725C6E5C725C6E2020202076617220726567696F6E4964203D206F7074696F6E732E64612E616374696F6E2E6166666563746564526567';
wwv_flow_api.g_varchar2_table(91) := '696F6E49643B5C725C6E20202020696E6A6563745374796C6573285C22646976235C22202B20726567696F6E4964202B205C225F69675F7265706F72745F73657474696E67735F73756D6D6172797B646973706C61793A626C6F636B7D5C222C72656769';
wwv_flow_api.g_varchar2_table(92) := '6F6E4964293B5C725C6E5C725C6E202020202F2F2052656D6F766520426172206966206E6573657373617279205C725C6E2020202069662028616C6C53657474696E677348696464656E28726567696F6E49642929207B205C725C6E202020202020696E';
wwv_flow_api.g_varchar2_table(93) := '6A6563745374796C6573285C22235C22202B20726567696F6E4964202B205C225F69675F7265706F72745F73657474696E67737B646973706C61793A6E6F6E657D5C222C726567696F6E4964293B5C725C6E202020207D20656C7365207B205C725C6E20';
wwv_flow_api.g_varchar2_table(94) := '2020202020696E6A6563745374796C6573285C22235C22202B20726567696F6E4964202B205C225F69675F7265706F72745F73657474696E67737B646973706C61793A626C6F636B7D5C222C726567696F6E4964293B5C725C6E202020207D5C725C6E20';
wwv_flow_api.g_varchar2_table(95) := '207D5C725C6E5C725C6E202066756E6374696F6E206869646553657474696E67286F7074696F6E732C206261736553657474696E67732C20656C656D656E7429207B5C725C6E2020202076617220726567696F6E4964203D206F7074696F6E732E64612E';
wwv_flow_api.g_varchar2_table(96) := '616374696F6E2E6166666563746564526567696F6E49643B5C725C6E202020207661722073756D6D617279537472696E67203D205C225C223B5C725C6E202020207661722073756D6D617279436F756E74203D20303B5C725C6E2020202076617220726F';
wwv_flow_api.g_varchar2_table(97) := '6F74456C656D656E74203D206261736553657474696E67732E73657474696E67735B656C656D656E745D3B20205C725C6E5C725C6E20202020666F7220287661722069203D20303B2069203C20726F6F74456C656D656E742E6C656E6774683B20692B2B';
wwv_flow_api.g_varchar2_table(98) := '29207B5C725C6E2020202020202F2F2047656E6572617465205A617020537472696E675C725C6E2020202020207661722073657474696E674944203D205C225C223B5C725C6E20202020202069662028747970656F6620726F6F74456C656D656E745B69';
wwv_flow_api.g_varchar2_table(99) := '5D2E494420213D205C22756E646566696E65645C2229207B5C725C6E202020202020202073657474696E674944203D20726F6F74456C656D656E745B695D2E49443B5C725C6E2020202020207D2020202020205C725C6E202020202020766172207A6170';
wwv_flow_api.g_varchar2_table(100) := '537472696E67203D205C22235C22202B20726567696F6E4964202B205C22206C692E612D49472D636F6E74726F6C732D6974656D2D2D5C22202B20656C656D656E74202B205C225B617269612D6C6162656C6C656462793D5C5C5C22636F6E74726F6C5F';
wwv_flow_api.g_varchar2_table(101) := '746578745C22202B2073657474696E674944202B205C225C5C5C225D5C223B5C725C6E5C725C6E20202020202069662028726F6F74456C656D656E745B695D2E44454C203D3D205C22595C222026262073686F756C6448696465286F7074696F6E732929';
wwv_flow_api.g_varchar2_table(102) := '207B5C725C6E2020202020202020696E6A6563745374796C6573287A6170537472696E67202B205C22207B20646973706C61793A206E6F6E653B207D5C222C20726567696F6E4964293B205C725C6E2020202020207D20656C7365207B202F2F69662028';
wwv_flow_api.g_varchar2_table(103) := '726F6F74456C656D656E745B695D2E44454C203D3D205C224E5C2229207B5C725C6E2020202020202020696E6A6563745374796C6573287A6170537472696E67202B205C22207B20646973706C61793A20626C6F636B3B207D5C222C20726567696F6E49';
wwv_flow_api.g_varchar2_table(104) := '64293B20205C725C6E20202020202020206966202820726F6F74456C656D656E745B695D2E49535F454E41424C4544203D3D205C225965735C222029207B5C725C6E2020202020202020202073756D6D617279537472696E67203D2073756D6D61727953';
wwv_flow_api.g_varchar2_table(105) := '7472696E67202B20726F6F74456C656D656E745B695D2E4C4142454C202B205C222C205C223B5C725C6E2020202020202020202073756D6D617279436F756E742B2B3B5C725C6E20202020202020207D5C725C6E2020202020207D5C725C6E202020207D';
wwv_flow_api.g_varchar2_table(106) := '5C725C6E5C725C6E202020202F2F20526577726974652053756D6D6D617279206C6162656C2F636F756E745C725C6E202020206966202873756D6D617279436F756E74203E203029207B5C725C6E20202020202024285C22235C22202B20726567696F6E';
wwv_flow_api.g_varchar2_table(107) := '4964202B205C225F69675F7265706F72745F73657474696E67735F73756D6D617279202E612D49472D7265706F727453756D6D6172792D6974656D2D2D5C22202B20656C656D656E74202B205C22202E612D49472D7265706F727453756D6D6172792D76';
wwv_flow_api.g_varchar2_table(108) := '616C75655C22292E746578742873756D6D617279537472696E672E73756273747228302C2073756D6D617279537472696E672E6C656E677468202D203229293B5C725C6E2020202020206966202873756D6D617279436F756E74203D3D203129207B5C72';
wwv_flow_api.g_varchar2_table(109) := '5C6E202020202020202073756D6D617279436F756E74203D205C225C223B5C725C6E2020202020207D5C725C6E20202020202024285C22235C22202B20726567696F6E4964202B205C225F69675F7265706F72745F73657474696E67735F73756D6D6172';
wwv_flow_api.g_varchar2_table(110) := '79202E612D49472D7265706F727453756D6D6172792D6974656D2D2D5C22202B20656C656D656E74202B205C22202E612D49472D7265706F727453756D6D6172792D636F756E745C22292E746578742873756D6D617279436F756E74293B5C725C6E2020';
wwv_flow_api.g_varchar2_table(111) := '20202020696E6A6563745374796C6573285C22235C22202B20726567696F6E4964202B205C225F69675F7265706F72745F73657474696E67735F73756D6D617279202E612D49472D7265706F727453756D6D6172792D6974656D2D2D5C22202B20656C65';
wwv_flow_api.g_varchar2_table(112) := '6D656E74202B205C22207B646973706C61793A20626C6F636B7D5C222C20726567696F6E4964293B5C725C6E202020207D20656C7365207B205C725C6E202020202020696E6A6563745374796C6573285C22235C22202B20726567696F6E4964202B205C';
wwv_flow_api.g_varchar2_table(113) := '225F69675F7265706F72745F73657474696E67735F73756D6D617279202E612D49472D7265706F727453756D6D6172792D6974656D2D2D5C22202B20656C656D656E74202B205C22207B646973706C61793A206E6F6E657D5C222C20726567696F6E4964';
wwv_flow_api.g_varchar2_table(114) := '293B5C725C6E202020207D5C725C6E5C725C6E20207D5C725C6E5C725C6E20202F2F2068747470733A2F2F6373732D747269636B732E636F6D2F736E6970706574732F6A6176617363726970742F696E6A6563742D6E65772D6373732D72756C65732F5C';
wwv_flow_api.g_varchar2_table(115) := '725C6E202066756E6374696F6E20696E6A6563745374796C65732872756C652C20726567696F6E496429207B5C725C6E2020202076617220636F6E7461696E6572203D205C22696748696773435353496E6A656374696F6E436F6E7461696E65725C223B';
wwv_flow_api.g_varchar2_table(116) := '5C725C6E5C725C6E202020202F2F204372656174655C725C6E20202020696620282024285C22235C22202B20636F6E7461696E6572292E6C656E677468203D3D20302029207B5C725C6E20202020202024285C223C646976202F3E5C222C207B5C725C6E';
wwv_flow_api.g_varchar2_table(117) := '202020202020202069643A20636F6E7461696E65725C725C6E2020202020207D292E617070656E64546F285C22626F64795C22293B202020205C725C6E202020207D5C725C6E2020202076617220646976203D2024285C223C646976202F3E5C222C207B';
wwv_flow_api.g_varchar2_table(118) := '5C725C6E20202020202068746D6C3A205C223C7374796C653E5C22202B2072756C65202B205C223C2F7374796C653E5C222C5C725C6E202020202020636C6173733A205C22696748696773496E6A6563745374796C65732D5C22202B20726567696F6E49';
wwv_flow_api.g_varchar2_table(119) := '64202B205C222D5C22202B2067657443757272656E745265706F7274496428726567696F6E4964295C725C6E202020207D292E617070656E64546F2824285C22235C22202B20636F6E7461696E657229293B202020205C725C6E20207D5C725C6E5C725C';
wwv_flow_api.g_varchar2_table(120) := '6E20202F2F2068747470733A2F2F737461636B6F766572666C6F772E636F6D2F612F373137383338315C725C6E202066756E6374696F6E2066696E6457697468417474722861727261792C20617474722C2076616C756529207B5C725C6E20202020666F';
wwv_flow_api.g_varchar2_table(121) := '7220287661722069203D20303B2069203C2061727261792E6C656E6774683B2069202B3D203129207B5C725C6E2020202020206966202861727261795B695D5B617474725D203D3D3D2076616C756529207B5C725C6E202020202020202072657475726E';
wwv_flow_api.g_varchar2_table(122) := '20693B5C725C6E2020202020207D5C725C6E202020207D5C725C6E2020202072657475726E202D313B5C725C6E20207D5C725C6E5C725C6E20202F2F2068747470733A2F2F6769746875622E636F6D2F6D676F7269636B692F617065782D706C7567696E';
wwv_flow_api.g_varchar2_table(123) := '2D657874656E642D69672D746F6F6C6261725C725C6E202066756E6374696F6E20657874656E6447726964546F6F6C626172286F7074696F6E732C207052656D6F76654F6E6C7929207B5C725C6E5C725C6E20202020766172206461203D206F7074696F';
wwv_flow_api.g_varchar2_table(124) := '6E732E64613B5C725C6E20202020617065782E64656275672E696E666F286465627567507265666978202B205C22657874656E6447726964546F6F6C6261725C222C206461293B5C725C6E5C725C6E202020202F2F2067657420706C7567696E20617474';
wwv_flow_api.g_varchar2_table(125) := '726962757465735C725C6E20202020766172207647726F7570203D205C22616374696F6E73345C223B5C725C6E202020207661722076506F736974696F6E203D205C22465C223B5C725C6E2020202076617220764C6162656C203D205C22557365722056';
wwv_flow_api.g_varchar2_table(126) := '6965775C223B5C725C6E202020207661722076486F74203D2066616C73653B5C725C6E20202020766172207649636F6E3B5C725C6E20202020766172207649636F6E4F6E6C79203D2066616C73653B5C725C6E20202020766172207649636F6E506F7369';
wwv_flow_api.g_varchar2_table(127) := '74696F6E203D20747275653B5C725C6E2020202076617220765469746C65203D205C22444556454C4F50455253204F4E4C593A20546F67676C65207768617420746865207573657220776F756C64207365652028692E6520746865205573657220566965';
wwv_flow_api.g_varchar2_table(128) := '7729206F6E206F72206F66665C223B5C725C6E202020207661722076416374696F6E203D205C226967486967734D6F64655C223B5C725C6E20202020766172207644697361626C6564203D2066616C73653B5C725C6E2020202076617220764869646465';
wwv_flow_api.g_varchar2_table(129) := '6E203D2066616C73653B5C725C6E2020202076617220764944203D205C22696748696773557365724D6F6465427574746F6E5C223B5C725C6E5C725C6E202020202F2F2067657420526567696F6E5C725C6E202020207661722076526567696F6E496420';
wwv_flow_api.g_varchar2_table(130) := '3D2064612E6166666563746564456C656D656E74735B305D2E69643B205C725C6E2020202076617220757365724D6F6465203D20676574557365724D6F64652876526567696F6E4964293B5C725C6E5C725C6E202020202F2F20636865636B2069636F6E';
wwv_flow_api.g_varchar2_table(131) := '205C725C6E2020202069662028757365724D6F6465203D3D205C22595C2229207B5C725C6E2020202020207649636F6E203D205C2266612066612D636865636B2D7371756172652D6F5C223B5C725C6E202020207D20656C7365207B5C725C6E20202020';
wwv_flow_api.g_varchar2_table(132) := '20207649636F6E203D205C2266612066612D7371756172652D6F5C223B5C725C6E202020207D5C725C6E5C725C6E202020202F2F20476574205769646765745C725C6E20202020766172207657696467657424203D20617065782E726567696F6E287652';
wwv_flow_api.g_varchar2_table(133) := '6567696F6E4964292E77696467657428293B5C725C6E5C725C6E202020202F2F204772696420637265617465645C725C6E2020202076617220746F6F6C626172203D2076576964676574242E696E74657261637469766547726964285C22676574546F6F';
wwv_flow_api.g_varchar2_table(134) := '6C6261725C22293B5C725C6E5C725C6E20202020766172207661427574746F6E203D207B5C725C6E202020202020747970653A205C22425554544F4E5C222C5C725C6E2020202020206C6162656C3A20764C6162656C2C5C725C6E202020202020746974';
wwv_flow_api.g_varchar2_table(135) := '6C653A20765469746C652C5C725C6E2020202020206C6162656C4B65793A20764C6162656C2C202F2F206C6162656C2066726F6D2074657874206D657373616765735C725C6E202020202020616374696F6E3A2076416374696F6E2C5C725C6E20202020';
wwv_flow_api.g_varchar2_table(136) := '202069636F6E3A207649636F6E2C5C725C6E20202020202069636F6E4F6E6C793A207649636F6E4F6E6C792C5C725C6E20202020202069636F6E4265666F72654C6162656C3A207649636F6E506F736974696F6E2C5C725C6E202020202020686F743A20';
wwv_flow_api.g_varchar2_table(137) := '76486F742C5C725C6E20202020202069643A207649445C725C6E202020207D3B5C725C6E5C725C6E2020202076617220636F6E666967203D20242E657874656E6428747275652C207B7D2C20746F6F6C6261722E746F6F6C626172285C226F7074696F6E';
wwv_flow_api.g_varchar2_table(138) := '5C2229293B5C725C6E2020202076617220746F6F6C62617244617461203D20636F6E6669672E646174613B5C725C6E2020202076617220746F6F6C62617247726F7570203D20746F6F6C626172446174612E66696C7465722866756E6374696F6E202867';
wwv_flow_api.g_varchar2_table(139) := '726F757029207B5C725C6E20202020202072657475726E2067726F75702E6964203D3D3D207647726F75703B5C725C6E202020207D295B305D3B5C725C6E5C725C6E2020202076617220627574746F6E496478203D2066696E6457697468417474722874';
wwv_flow_api.g_varchar2_table(140) := '6F6F6C62617247726F75702E636F6E74726F6C732C205C2269645C222C20764944293B5C725C6E2020202069662028627574746F6E496478203E202D3129207B5C725C6E202020202020746F6F6C62617247726F75702E636F6E74726F6C732E73706C69';
wwv_flow_api.g_varchar2_table(141) := '636528627574746F6E4964782C2031293B5C725C6E202020207D5C725C6E5C725C6E2020202069662028217052656D6F76654F6E6C7929207B5C725C6E20202020202069662028746F6F6C62617247726F757029207B5C725C6E20202020202020206966';
wwv_flow_api.g_varchar2_table(142) := '202876506F736974696F6E203D3D205C22465C2229207B5C725C6E20202020202020202020746F6F6C62617247726F75702E636F6E74726F6C732E756E7368696674287661427574746F6E293B5C725C6E20202020202020207D20656C7365207B5C725C';
wwv_flow_api.g_varchar2_table(143) := '6E20202020202020202020746F6F6C62617247726F75702E636F6E74726F6C732E70757368287661427574746F6E293B5C725C6E20202020202020207D5C725C6E2020202020207D5C725C6E5C725C6E202020202020746F6F6C6261722E746F6F6C6261';
wwv_flow_api.g_varchar2_table(144) := '72285C226F7074696F6E5C222C205C22646174615C222C20636F6E6669672E64617461293B5C725C6E5C725C6E2020202020202F2F2061646420616374696F6E735C725C6E2020202020207661722076416374696F6E73203D2076576964676574242E69';
wwv_flow_api.g_varchar2_table(145) := '6E74657261637469766547726964285C22676574416374696F6E735C22293B5C725C6E5C725C6E2020202020202F2F20636865636B20696620616374696F6E206578697374732C207468656E206A7573742061737369676E2069745C725C6E2020202020';
wwv_flow_api.g_varchar2_table(146) := '207661722076416374696F6E24203D2076416374696F6E732E6C6F6F6B75702876416374696F6E293B5C725C6E202020202020696620282176416374696F6E2429207B5C725C6E202020202020202076416374696F6E732E616464285C725C6E20202020';
wwv_flow_api.g_varchar2_table(147) := '2020202020207B5C725C6E2020202020202020202020206E616D653A2076416374696F6E2C205C725C6E202020202020202020202020616374696F6E3A2066756E6374696F6E20285F6576656E742C205F656C656D656E7429207B5C725C6E2020202020';
wwv_flow_api.g_varchar2_table(148) := '2020202020202020202F2F202D2D20537461727420416374696F6E20436F6465205C725C6E202020202020202020202020202076617220757365724D6F6465203D20676574557365724D6F64652876526567696F6E4964293B5C725C6E20202020202020';
wwv_flow_api.g_varchar2_table(149) := '20202020202020766172206E6577557365724D6F64653B5C725C6E202020202020202020202020202069662028757365724D6F6465203D3D205C22595C2229207B206E6577557365724D6F6465203D205C224E5C223B207D20656C7365207B206E657755';
wwv_flow_api.g_varchar2_table(150) := '7365724D6F6465203D205C22595C223B207D5C725C6E2020202020202020202020202020736574557365724D6F64652876526567696F6E49642C206E6577557365724D6F6465293B5C725C6E5C725C6E2020202020202020202020202020696620286E65';
wwv_flow_api.g_varchar2_table(151) := '77557365724D6F6465203D3D205C224E5C22202626206170706C696573546F43757272656E745265706F7274286F7074696F6E732929207B5C725C6E20202020202020202020202020202020726573746F72655573657256696577286F7074696F6E7329';
wwv_flow_api.g_varchar2_table(152) := '3B5C725C6E20202020202020202020202020207D5C725C6E5C725C6E20202020202020202020202020202F2F20507574207468652020627574746F6E206261636B206F6E2077697468206E65772069636F6E5C725C6E2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(153) := '657874656E6447726964546F6F6C626172286F7074696F6E73293B5C725C6E20202020202020202020202020202F2F202D2D20456E6420416374696F6E20636F64655C725C6E2020202020202020202020207D2C205C725C6E2020202020202020202020';
wwv_flow_api.g_varchar2_table(154) := '20686964653A207648696464656E2C205C725C6E20202020202020202020202064697361626C65643A207644697361626C65645C725C6E202020202020202020207D293B5C725C6E2020202020207D20656C7365207B5C725C6E20202020202020207641';
wwv_flow_api.g_varchar2_table(155) := '6374696F6E242E68696465203D207648696464656E3B5C725C6E202020202020202076416374696F6E242E64697361626C6564203D207644697361626C65643B5C725C6E2020202020207D5C725C6E202020207D20656C7365207B5C725C6E2020202020';
wwv_flow_api.g_varchar2_table(156) := '20746F6F6C6261722E746F6F6C626172285C226F7074696F6E5C222C205C22646174615C222C20636F6E6669672E64617461293B5C725C6E202020207D5C725C6E5C725C6E202020202F2F207265667265736820677269645C725C6E20202020746F6F6C';
wwv_flow_api.g_varchar2_table(157) := '6261722E746F6F6C626172285C22726566726573685C22293B5C725C6E20207D5C725C6E5C725C6E20202F2F205075626C69632066756E6374696F6E735C725C6E202072657475726E20287B5C725C6E2020202072656E6465723A2072656E6465725C72';
wwv_flow_api.g_varchar2_table(158) := '5C6E20207D293B5C725C6E5C725C6E7D2829293B225D2C2266696C65223A226578706C6F7265724967486967732E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(5912373111456219)
,p_plugin_id=>wwv_flow_api.id(4906257124580834)
,p_file_name=>'js/explorerIgHigs.js.map'
,p_mime_type=>'application/octet-stream'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A2065736C696E742D64697361626C65206E6F2D756E757365642D76617273202A2F0A2F2F2065736C696E742D64697361626C652D6E6578742D6C696E65206E6F2D756E6465660A6578706C6F7265724967486967733D66756E6374696F6E28297B22';
wwv_flow_api.g_varchar2_table(2) := '75736520737472696374223B76617220653D272E612D546F6F6C6261722D73656C6563744C6973745B646174612D616374696F6E3D226368616E67652D7265706F7274225D272C743D224578706C6F7265722049474849475320506C7567696E3A20222C';
wwv_flow_api.g_varchar2_table(3) := '693D66756E6374696F6E28652C74297B72657475726E206E756C6C3D3D657C7C22223D3D653F743A657D3B66756E6374696F6E20722865297B72657475726E20692873657373696F6E53746F726167652E6765744974656D28222E222B617065782E6974';
wwv_flow_api.g_varchar2_table(4) := '656D282270466C6F77496422292E67657456616C756528292B222E222B617065782E6974656D282270466C6F7753746570496422292E67657456616C756528292B222E6967486967732E222B65292C224E22297D66756E6374696F6E20612865297B7265';
wwv_flow_api.g_varchar2_table(5) := '7475726E20617065782E726567696F6E2865292E63616C6C28226F7074696F6E222C22636F6E66696722292E66656174757265732E736176655265706F72742E6973446576656C6F7065727D66756E6374696F6E206E2865297B76617220743D652E6461';
wwv_flow_api.g_varchar2_table(6) := '2E616374696F6E2E6166666563746564526567696F6E49642C693D652E64612E616374696F6E2E61747472696275746530322C723D66756E6374696F6E2865297B76617220743D617065782E726567696F6E2865292E63616C6C28226765745265706F72';
wwv_flow_api.g_varchar2_table(7) := '747322292C693D7028742C226964222C64286529292C723D22223B2D31213D69262628723D745B695D2E74797065293B72657475726E20727D2874292C613D21313B72657475726E206E756C6C213D69262628613D2D31213D692E73706C697428223A22';
wwv_flow_api.g_varchar2_table(8) := '292E696E6465784F66287229292C617D66756E6374696F6E206F2865297B76617220743D652E64612E616374696F6E2E6166666563746564526567696F6E49643B72657475726E206E2865292626286128742926262259223D3D722874297C7C21612874';
wwv_flow_api.g_varchar2_table(9) := '29297D66756E6374696F6E20732865297B6128652E64612E616374696F6E2E6166666563746564526567696F6E4964293F662865293A6628652C2130297D76617220643D66756E6374696F6E2874297B76617220693B7472797B693D617065782E726567';
wwv_flow_api.g_varchar2_table(10) := '696F6E2874292E63616C6C282267657443757272656E745669657722292E6D6F64656C3F617065782E726567696F6E2874292E63616C6C282267657443757272656E745669657722292E6D6F64656C2E6765744F7074696F6E2822726567696F6E446174';
wwv_flow_api.g_varchar2_table(11) := '6122292E7265706F727449643A24282223222B74292E66696E642865295B305D2E76616C75657D63617463682872297B693D24282223222B74292E66696E642865295B305D2E76616C75657D72657475726E20697D3B66756E6374696F6E206C2865297B';
wwv_flow_api.g_varchar2_table(12) := '76617220693D7B7D2C723D652E64612E616374696F6E2E6166666563746564526567696F6E49642C613D223A222B652E64612E616374696F6E2E61747472696275746530312B223A222C6E3D652E64612E616374696F6E2E61747472696275746530323B';
wwv_flow_api.g_varchar2_table(13) := '692E7830313D642872292C692E7830323D722C692E7830333D612C692E7830343D6E3B76617220733D24282223222B72292E61747472282269674869677343757272656E745265706F7274496422292C6C3D24282223222B72292E617474722822696748';
wwv_flow_api.g_varchar2_table(14) := '69677343757272656E745669657722292C703D617065782E726567696F6E2872292E63616C6C282267657443757272656E745669657722292E696E7465726E616C4964656E7469666965723B24282223222B72292E617474722822696748696773437572';
wwv_flow_api.g_varchar2_table(15) := '72656E745265706F72744964222C692E783031292C24282223222B72292E61747472282269674869677343757272656E7456696577222C70292C216F2865297C7C692E7830313D3D732626703D3D6C7C7C28617065782E64656275672E696E666F28742B';
wwv_flow_api.g_varchar2_table(16) := '225265706F727420737769746368206465746563746564222C732C6C2C692E7830312C70292C75282223222B722B225F69675F7265706F72745F73657474696E67737B646973706C61793A6E6F6E657D222C7229292C617065782E7365727665722E706C';
wwv_flow_api.g_varchar2_table(17) := '7567696E28652E616A61784964656E7469666965722C69292E646F6E652866756E6374696F6E2869297B617065782E64656275672E696E666F28742B22414A415820726573756C7473222C69292C2D31213D612E696E6465784F6628223A463A22292626';
wwv_flow_api.g_varchar2_table(18) := '6328652C692C2266696C74657222292C2D31213D612E696E6465784F6628223A433A222926266328652C692C22636F6E74726F6C427265616B22292C2D31213D612E696E6465784F6628223A413A222926266328652C692C226167677265676174652229';
wwv_flow_api.g_varchar2_table(19) := '2C2D31213D612E696E6465784F6628223A483A222926266328652C692C22686967686C6967687422292C2D31213D612E696E6465784F6628223A46423A222926266328652C692C22666C6173686261636B22292C672865292C617065782E64612E726573';
wwv_flow_api.g_varchar2_table(20) := '756D6528652E64612E726573756D6543616C6C6261636B2C2131297D297D66756E6374696F6E20672865297B76617220743D652E64612E616374696F6E2E6166666563746564526567696F6E49643B75282264697623222B742B225F69675F7265706F72';
wwv_flow_api.g_varchar2_table(21) := '745F73657474696E67735F73756D6D6172797B646973706C61793A626C6F636B7D222C74292C303D3D24282223222B742B22202E612D49472D636F6E74726F6C7322292E6368696C6472656E28292E66696C7465722866756E6374696F6E2865297B7265';
wwv_flow_api.g_varchar2_table(22) := '7475726E22626C6F636B223D3D3D242874686973292E6373732822646973706C617922297D292E6C656E6774683F75282223222B742B225F69675F7265706F72745F73657474696E67737B646973706C61793A6E6F6E657D222C74293A75282223222B74';
wwv_flow_api.g_varchar2_table(23) := '2B225F69675F7265706F72745F73657474696E67737B646973706C61793A626C6F636B7D222C74297D66756E6374696F6E206328652C742C69297B666F722876617220723D652E64612E616374696F6E2E6166666563746564526567696F6E49642C613D';
wwv_flow_api.g_varchar2_table(24) := '22222C6E3D302C733D742E73657474696E67735B695D2C643D303B643C732E6C656E6774683B642B2B297B766172206C3D22223B766F69642030213D3D735B645D2E49442626286C3D735B645D2E4944293B76617220673D2223222B722B22206C692E61';
wwv_flow_api.g_varchar2_table(25) := '2D49472D636F6E74726F6C732D6974656D2D2D222B692B275B617269612D6C6162656C6C656462793D22636F6E74726F6C5F74657874272B6C2B27225D273B2259223D3D735B645D2E44454C26266F2865293F7528672B22207B20646973706C61793A20';
wwv_flow_api.g_varchar2_table(26) := '6E6F6E653B207D222C72293A287528672B22207B20646973706C61793A20626C6F636B3B207D222C72292C22596573223D3D735B645D2E49535F454E41424C4544262628613D612B735B645D2E4C4142454C2B222C20222C6E2B2B29297D6E3E303F2824';
wwv_flow_api.g_varchar2_table(27) := '282223222B722B225F69675F7265706F72745F73657474696E67735F73756D6D617279202E612D49472D7265706F727453756D6D6172792D6974656D2D2D222B692B22202E612D49472D7265706F727453756D6D6172792D76616C756522292E74657874';
wwv_flow_api.g_varchar2_table(28) := '28612E73756273747228302C612E6C656E6774682D3229292C313D3D6E2626286E3D2222292C24282223222B722B225F69675F7265706F72745F73657474696E67735F73756D6D617279202E612D49472D7265706F727453756D6D6172792D6974656D2D';
wwv_flow_api.g_varchar2_table(29) := '2D222B692B22202E612D49472D7265706F727453756D6D6172792D636F756E7422292E74657874286E292C75282223222B722B225F69675F7265706F72745F73657474696E67735F73756D6D617279202E612D49472D7265706F727453756D6D6172792D';
wwv_flow_api.g_varchar2_table(30) := '6974656D2D2D222B692B22207B646973706C61793A20626C6F636B7D222C7229293A75282223222B722B225F69675F7265706F72745F73657474696E67735F73756D6D617279202E612D49472D7265706F727453756D6D6172792D6974656D2D2D222B69';
wwv_flow_api.g_varchar2_table(31) := '2B22207B646973706C61793A206E6F6E657D222C72297D66756E6374696F6E207528652C74297B76617220693D22696748696773435353496E6A656374696F6E436F6E7461696E6572223B303D3D24282223222B69292E6C656E67746826262428223C64';
wwv_flow_api.g_varchar2_table(32) := '6976202F3E222C7B69643A697D292E617070656E64546F2822626F647922293B2428223C646976202F3E222C7B68746D6C3A223C7374796C653E222B652B223C2F7374796C653E222C636C6173733A22696748696773496E6A6563745374796C65732D22';
wwv_flow_api.g_varchar2_table(33) := '2B742B222D222B642874297D292E617070656E64546F2824282223222B6929297D66756E6374696F6E207028652C742C69297B666F722876617220723D303B723C652E6C656E6774683B722B3D3129696628655B725D5B745D3D3D3D692972657475726E';
wwv_flow_api.g_varchar2_table(34) := '20723B72657475726E2D317D66756E6374696F6E206628652C69297B76617220613D652E64613B617065782E64656275672E696E666F28742B22657874656E6447726964546F6F6C626172222C61293B766172206F2C733D22696748696773557365724D';
wwv_flow_api.g_varchar2_table(35) := '6F6465427574746F6E222C6C3D612E6166666563746564456C656D656E74735B305D2E69643B6F3D2259223D3D72286C293F2266612066612D636865636B2D7371756172652D6F223A2266612066612D7371756172652D6F223B76617220633D61706578';
wwv_flow_api.g_varchar2_table(36) := '2E726567696F6E286C292E77696467657428292C753D632E696E746572616374697665477269642822676574546F6F6C62617222292C6D3D7B747970653A22425554544F4E222C6C6162656C3A22557365722056696577222C7469746C653A2244455645';
wwv_flow_api.g_varchar2_table(37) := '4C4F50455253204F4E4C593A20546F67676C65207768617420746865207573657220776F756C64207365652028692E65207468652055736572205669657729206F6E206F72206F6666222C6C6162656C4B65793A22557365722056696577222C61637469';
wwv_flow_api.g_varchar2_table(38) := '6F6E3A226967486967734D6F6465222C69636F6E3A6F2C69636F6E4F6E6C793A21312C69636F6E4265666F72654C6162656C3A21302C686F743A21312C69643A737D2C763D242E657874656E642821302C7B7D2C752E746F6F6C62617228226F7074696F';
wwv_flow_api.g_varchar2_table(39) := '6E2229292C5F3D762E646174612E66696C7465722866756E6374696F6E2865297B72657475726E22616374696F6E7334223D3D3D652E69647D295B305D2C623D70285F2E636F6E74726F6C732C226964222C73293B696628623E2D3126265F2E636F6E74';
wwv_flow_api.g_varchar2_table(40) := '726F6C732E73706C69636528622C31292C6929752E746F6F6C62617228226F7074696F6E222C2264617461222C762E64617461293B656C73657B5F26265F2E636F6E74726F6C732E756E7368696674286D292C752E746F6F6C62617228226F7074696F6E';
wwv_flow_api.g_varchar2_table(41) := '222C2264617461222C762E64617461293B76617220783D632E696E746572616374697665477269642822676574416374696F6E7322292C793D782E6C6F6F6B757028226967486967734D6F646522293B793F28792E686964653D21312C792E6469736162';
wwv_flow_api.g_varchar2_table(42) := '6C65643D2131293A782E616464287B6E616D653A226967486967734D6F6465222C616374696F6E3A66756E6374696F6E28692C61297B766172206F2C732C632C753D72286C293B733D6C2C633D6F3D2259223D3D753F224E223A2259222C73657373696F';
wwv_flow_api.g_varchar2_table(43) := '6E53746F726167652E7365744974656D28222E222B617065782E6974656D282270466C6F77496422292E67657456616C756528292B222E222B617065782E6974656D282270466C6F7753746570496422292E67657456616C756528292B222E6967486967';
wwv_flow_api.g_varchar2_table(44) := '732E222B732C63292C224E223D3D6F26266E286529262666756E6374696F6E2865297B617065782E64656275672E696E666F28742B22726573746F7265557365725669657722293B76617220693D652E64612E616374696F6E2E61666665637465645265';
wwv_flow_api.g_varchar2_table(45) := '67696F6E49643B2428222E696748696773496E6A6563745374796C65732D222B692B222D222B64286929292E7265706C6163655769746828292C672865297D2865292C662865297D2C686964653A21312C64697361626C65643A21317D297D752E746F6F';
wwv_flow_api.g_varchar2_table(46) := '6C62617228227265667265736822297D72657475726E7B72656E6465723A66756E6374696F6E2869297B76617220723D692E64612E616374696F6E2E6166666563746564526567696F6E49643B617065782E64656275672E696E666F28742B2252656E64';
wwv_flow_api.g_varchar2_table(47) := '657222292C617065782E64656275672E696E666F28742C69292C30213D24282223222B722B22202E612D494722292E6C656E6774683F28732869292C24282223222B72292E6F6E2822696E746572616374697665677269647265706F727473657474696E';
wwv_flow_api.g_varchar2_table(48) := '67736368616E6765222C66756E6374696F6E28652C61297B617065782E64656275672E696E666F28742B224576656E74202D2053657474696E6773204368616E676522292C6F286929262675282264697623222B722B225F69675F7265706F72745F7365';
wwv_flow_api.g_varchar2_table(49) := '7474696E67735F73756D6D6172797B646973706C61793A6E6F6E657D222C72292C6C2869297D292C24282223222B72292E6F6E2822696E74657261637469766567726964766965776368616E6765222C66756E6374696F6E28652C61297B617065782E64';
wwv_flow_api.g_varchar2_table(50) := '656275672E696E666F28742B224576656E74202D20477269642056696577204368616E676522292C732869292C6F286929262675282264697623222B722B225F69675F7265706F72745F73657474696E67735F73756D6D6172797B646973706C61793A6E';
wwv_flow_api.g_varchar2_table(51) := '6F6E657D222C72292C6C2869297D292C456C656D656E742E70726F746F747970652E6D6174636865737C7C28456C656D656E742E70726F746F747970652E6D6174636865733D456C656D656E742E70726F746F747970652E6D734D61746368657353656C';
wwv_flow_api.g_varchar2_table(52) := '6563746F727C7C456C656D656E742E70726F746F747970652E7765626B69744D61746368657353656C6563746F72292C6E6577204D75746174696F6E4F627365727665722866756E6374696F6E2861297B766172206E3D653B28615B305D2E7461726765';
wwv_flow_api.g_varchar2_table(53) := '742E6D617463686573286E297C7C615B305D2E7461726765742E717565727953656C6563746F72416C6C286E292E6C656E6774683E3029262628617065782E64656275672E696E666F28742B224576656E74202D206D75746174696F6E4F627365727665';
wwv_flow_api.g_varchar2_table(54) := '7222292C6F286929262675282264697623222B722B225F69675F7265706F72745F73657474696E67735F73756D6D6172797B646973706C61793A6E6F6E657D222C72292C6C286929297D292E6F6273657276652824282223222B722B225F69675F746F6F';
wwv_flow_api.g_varchar2_table(55) := '6C62617222295B305D2C7B617474726962757465733A21302C636861726163746572446174613A21302C6368696C644C6973743A21302C737562747265653A21302C6174747269627574654F6C6456616C75653A21302C63686172616374657244617461';
wwv_flow_api.g_varchar2_table(56) := '4F6C6456616C75653A21307D292C6C286929293A617065782E64656275672E696E666F28742B224572726F723A20526567696F6E20222B722B22206973206E6F7420616E20496E746572616374697665204772696422297D7D7D28293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(5912785033456222)
,p_plugin_id=>wwv_flow_api.id(4906257124580834)
,p_file_name=>'js/explorerIgHigs.min.js'
,p_mime_type=>'application/x-javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
