CREATE OR REPLACE PACKAGE BODY com_uk_explorer_ighigs
AS

  /*-------------------------------------
  * IG Hide IG Settings
  * Version: 19.2.0
  * Author:  Matt Mulvaney
  *-------------------------------------
  */
  FUNCTION render(p_dynamic_action IN apex_plugin.t_dynamic_action,
                  p_plugin         IN apex_plugin.t_plugin)
  RETURN apex_plugin.t_dynamic_action_render_result 
  IS
    -- plugin attributes
    l_result                   apex_plugin.t_dynamic_action_render_result;
    l_include_private          p_dynamic_action.attribute_01%TYPE := p_dynamic_action.attribute_01;
    l_hide_ig_cr_sl            p_dynamic_action.attribute_02%TYPE := p_dynamic_action.attribute_02;
    
  BEGIN

    -- Debug
    IF apex_application.g_debug 
    THEN
      apex_plugin_util.debug_dynamic_action(p_plugin         => p_plugin,
                                            p_dynamic_action => p_dynamic_action);
    END IF;
    
      l_result.javascript_function := 
      q'[function() {
        explorerIgHigs.render({
          da: this,
          ajaxIdentifier: "#AJAX_IDENTIFIER#"
        });
      }]';
      
    l_result.javascript_function := replace(l_result.javascript_function,'#AJAX_IDENTIFIER#', apex_plugin.get_ajax_identifier);

    l_result.attribute_01        := l_include_private;
    l_result.attribute_02        := l_hide_ig_cr_sl;

    RETURN l_result;

  END render;

  ------------------------------------------------------------------------------
  FUNCTION ajax(p_dynamic_action in apex_plugin.t_dynamic_action
              ,p_plugin         in apex_plugin.t_plugin) 
  RETURN apex_plugin.t_dynamic_action_ajax_result
  IS

    l_report_id           varchar2(32767) default apex_application.g_x01;
    l_region_id           varchar2(32767) default apex_application.g_x02;
    l_settings_string     varchar2(32767) default apex_application.g_x03;
    l_applyToReports      varchar2(32767) default UPPER(apex_application.g_x04);
    
    l_app_id              NUMBER DEFAULT nv('APP_ID');
    l_app_page_id         NUMBER DEFAULT nv('APP_PAGE_ID');

    l_result              apex_plugin.t_dynamic_action_ajax_result;
    f sys_refcursor;
    c sys_refcursor;
    a sys_refcursor;
    h sys_refcursor;
    fb sys_refcursor;
    t0 pls_integer; 
    t1 pls_integer;
    
    TYPE timing_rec IS RECORD ( MESSAGE VARCHAR2(32767), SPLIT_TIME NUMBER);
    TYPE tt IS TABLE OF timing_rec INDEX BY BINARY_INTEGER;
    tb tt;

  BEGIN
    apex_debug.message('>Interactive Grid - Hide IG Settings: AJAX Callback');
    apex_debug.message('Report ID: ' ||  l_report_id);
    apex_debug.message('Region ID: ' ||  l_region_id);
    apex_debug.message('App ID: ' ||  l_app_id);
    apex_debug.message('App Page ID: ' ||  l_app_page_id);
    apex_debug.message('Settings String: ' || l_settings_string);
    apex_debug.message('Apply to Reports: ' || l_applyToReports);
    
    t0 := dbms_utility.get_time;   
    t1 := t0;
    
    --# Filters
    IF INSTR(l_settings_string, ':F:') > 0 THEN
      open f for 
    with reports as (
    select rpts.* from 
    APEX_APPLICATION_PAGE_REGIONS r, 
    APEX_APPL_PAGE_IG_RPTS rpts
    where r.application_id = l_app_id
    and r.page_id = l_app_page_id
    and NVL(r.static_id, 'R' || r.region_id) = l_region_id
    and r.region_id = rpts.region_id ),
    current_report as ( select * from reports where report_id = l_report_id),
    base_report as ( select br.* from reports br, current_report cr where br.report_id = NVL(cr.base_report_id, cr.report_id ) ),
    /* Obtain Base/Current Unique IDXs */
    current_filters as ( select row_number() over (partition by f.type_code, f.name, f.column_id, f.comp_column_id, f.operator, f.is_case_sensitive, f.expression, f.is_enabled order by f.filter_id) idx, f.*,
    NVL((select heading from APEX_APPL_PAGE_IG_COLUMNS ic where ic.column_id = f.column_id), '''' || f.expression || '''' ) label
    from APEX_APPL_PAGE_IG_RPT_FILTERS f, current_report cr where f.report_id = cr.report_id ),
    base_filters as ( select row_number() over (partition by f.type_code, f.name, f.column_id, f.comp_column_id, f.operator, f.is_case_sensitive, f.expression, f.is_enabled order by f.filter_id) idx, f.*,
    NVL((select heading from APEX_APPL_PAGE_IG_COLUMNS ic where ic.column_id = f.column_id), '''' || f.expression || '''' ) label
    from APEX_APPL_PAGE_IG_RPT_FILTERS f, base_report br where f.report_id = br.report_id ),
    /* Decide what to be shown */
    display_filters as (select 
    idx, type_code, name, column_id, comp_column_id, operator, is_case_sensitive, expression, is_enabled
    from current_filters
    minus 
    select
    idx, type_code, name, column_id, comp_column_id, operator, is_case_sensitive, expression, is_enabled
    from base_filters),
    /* Use IDX to work out which can be removed */
    removable_filters as (
    select c.* from current_filters c
    , base_filters d
    where 
    c.idx = d.idx
    and ( c.type_code = d.type_code OR c.type_code IS NULL AND d.type_code IS NULL )
    and ( c.name = d.name OR c.name IS NULL AND d.name IS NULL )
    and ( c.column_id = d.column_id OR c.column_id IS NULL AND d.column_id IS NULL )
    and ( c.comp_column_id = d.comp_column_id OR c.comp_column_id IS NULL AND d.comp_column_id IS NULL )
    and ( c.operator = d.operator OR c.operator IS NULL AND d.operator IS NULL )
    and ( c.is_case_sensitive = d.is_case_sensitive OR c.is_case_sensitive IS NULL AND d.is_case_sensitive IS NULL )
    and ( c.expression = d.expression OR c.expression IS NULL AND d.expression IS NULL )
    and ( c.is_enabled = d.is_enabled OR c.is_enabled IS NULL AND d.is_enabled IS NULL )
    ),
    /* Final Filters for JSON */
    final_filters as (
    select TO_CHAR(c.filter_id) ID, NVL2(r.filter_id,'Y','N') del, c.is_enabled, c.label from current_filters c,removable_filters r
    where c.filter_id = r.filter_id(+) )
    select * from final_filters;

    tb(tb.COUNT+1).message := 'open filters';
    tb(tb.COUNT).split_time := dbms_utility.get_time - t1;
    t1 := dbms_utility.get_time;
    END IF;

    --# Control Breaks
    IF INSTR(l_settings_string, ':C:') > 0 THEN
      open c for 
    with reports as (
    select rpts.* from 
    APEX_APPLICATION_PAGE_REGIONS r, 
    APEX_APPL_PAGE_IG_RPTS rpts
    where r.application_id = l_app_id
    and r.page_id = l_app_page_id
    and NVL(r.static_id, 'R' || r.region_id) = l_region_id
    and r.region_id = rpts.region_id ),
    current_report as ( select * from reports where report_id = l_report_id),
    base_report as ( select br.* from reports br, current_report cr where br.report_id = NVL(cr.base_report_id, cr.report_id ) ),
    control_breaks_removable AS (
    select rc.column_id, 'Y' DEL, break_is_enabled IS_ENABLED, c.heading from APEX_APPL_PAGE_IG_COLUMNS c, APEX_APPL_PAGE_IG_RPT_COLUMNS rc, current_report cr where c.column_id = rc.column_id and rc.report_id = cr.report_id and break_order IS NOT NULL
    INTERSECT
    select rc.column_id, 'Y' DEL, break_is_enabled IS_ENABLED, c.heading from APEX_APPL_PAGE_IG_COLUMNS c, APEX_APPL_PAGE_IG_RPT_COLUMNS rc, base_report cr where c.column_id = rc.column_id and rc.report_id = cr.report_id and break_order IS NOT NULL
    ),
    control_breaks_non_removable AS (
    select rc.column_id ID, 'N' DEL, break_is_enabled IS_ENABLED, c.heading from APEX_APPL_PAGE_IG_COLUMNS c, APEX_APPL_PAGE_IG_RPT_COLUMNS rc, current_report cr where c.column_id = rc.column_id and rc.report_id = cr.report_id and break_order IS NOT NULL
    and not exists ( select 1 from control_breaks_removable cbr where cbr.column_id = rc.column_id ) ),
    final_control_breaks as (
    select * from control_breaks_removable
    union all
    select * from control_breaks_non_removable
    )
    select to_char(column_id) ID, DEL, IS_ENABLED, HEADING LABEL from final_control_breaks;

    tb(tb.COUNT+1).message := 'open control breaks';
    tb(tb.COUNT).split_time := dbms_utility.get_time - t1;
    t1 := dbms_utility.get_time;
    END IF;

    IF INSTR(l_settings_string, ':A:') > 0 THEN
    open a FOR
    with reports as (
    select rpts.* from 
    APEX_APPLICATION_PAGE_REGIONS r, 
    APEX_APPL_PAGE_IG_RPTS rpts
    where r.application_id = l_app_id
    and r.page_id = l_app_page_id
    and NVL(r.static_id, 'R' || r.region_id) = l_region_id
    and r.region_id = rpts.region_id ),
    current_report as ( select * from reports where report_id = l_report_id),
    base_report as ( select br.* from reports br, current_report cr where br.report_id = NVL(cr.base_report_id, cr.report_id ) ),
    aggregates_removable AS (
    select  'Y' DEL, rc.is_enabled, rc.TOOLTIP, rc.FUNCTION, rc.COLUMN_ID, rc.COMP_COLUMN_ID, rc.SHOW_GRAND_TOTAL, c.heading from APEX_APPL_PAGE_IG_COLUMNS c, APEX_APPL_PAGE_IG_RPT_AGGS rc, current_report cr where c.column_id = rc.column_id and rc.report_id = cr.report_id
    INTERSECT
    select 'Y' DEL, rc.is_enabled, rc.TOOLTIP, rc.FUNCTION, rc.COLUMN_ID, rc.COMP_COLUMN_ID, rc.SHOW_GRAND_TOTAL, c.heading from APEX_APPL_PAGE_IG_COLUMNS c, APEX_APPL_PAGE_IG_RPT_AGGS rc, base_report cr where c.column_id = rc.column_id and rc.report_id = cr.report_id
    ),
    aggregates_non_removable AS (
    select 'N' DEL, rc.is_enabled, rc.TOOLTIP, rc.FUNCTION, rc.COLUMN_ID, rc.COMP_COLUMN_ID, rc.SHOW_GRAND_TOTAL, c.heading from APEX_APPL_PAGE_IG_COLUMNS c, APEX_APPL_PAGE_IG_RPT_AGGS rc, current_report cr where c.column_id = rc.column_id and rc.report_id = cr.report_id
    and ( rc.TOOLTIP, rc.is_enabled, rc.FUNCTION, rc.COLUMN_ID, rc.COMP_COLUMN_ID, rc.SHOW_GRAND_TOTAL) not in 
    ( 
    select a.TOOLTIP, a.is_enabled,a.FUNCTION, a.COLUMN_ID, a.COMP_COLUMN_ID, a.SHOW_GRAND_TOTAL from aggregates_removable a )
    ),
    final_aggregates as (
    select * from aggregates_removable
    union all
    select * from aggregates_non_removable
    )
    select to_char(rc.aggregate_id) ID, fa.DEL, rc.IS_ENABLED, fa.heading LABEL from final_aggregates fa, 
    ( select rc.* FROM APEX_APPL_PAGE_IG_RPT_AGGS rc, current_report cr where rc.report_id = cr.report_id ) rc
    where  
    ( fa.TOOLTIP = rc.TOOLTIP OR fa.TOOLTIP IS NULL AND rc.TOOLTIP IS NULL )
    and ( fa.FUNCTION = rc.FUNCTION OR fa.FUNCTION IS NULL AND rc.FUNCTION IS NULL )
    and ( fa.COLUMN_ID = rc.COLUMN_ID OR fa.COLUMN_ID IS NULL AND rc.COLUMN_ID IS NULL )
    and ( fa.COMP_COLUMN_ID = rc.COMP_COLUMN_ID OR fa.COMP_COLUMN_ID IS NULL AND rc.COMP_COLUMN_ID IS NULL )
    and ( fa.SHOW_GRAND_TOTAL = rc.SHOW_GRAND_TOTAL OR fa.SHOW_GRAND_TOTAL IS NULL AND rc.SHOW_GRAND_TOTAL IS NULL )
    and ( fa.IS_ENABLED = rc.IS_ENABLED OR fa.IS_ENABLED IS NULL AND rc.IS_ENABLED IS NULL );

    tb(tb.COUNT+1).message := 'open aggregates';
    tb(tb.COUNT).split_time := dbms_utility.get_time - t1;
    t1 := dbms_utility.get_time;
    END IF;

    -- Highlights
    IF INSTR(l_settings_string, ':H:') > 0 THEN
    open h FOR
    with reports as (
    select rpts.* from 
    APEX_APPLICATION_PAGE_REGIONS r, 
    APEX_APPL_PAGE_IG_RPTS rpts
    where r.application_id = l_app_id
    and r.page_id = l_app_page_id
    and NVL(r.static_id, 'R' || r.region_id) = l_region_id
    and r.region_id = rpts.region_id ),
    current_report as ( select * from reports where report_id = l_report_id),
    base_report as ( select br.* from reports br, current_report cr where br.report_id = NVL(cr.base_report_id, cr.report_id ) ),
    /* Obtain Base/Current Unique IDXs */
    current_highlights as ( select row_number() over (partition by f.NAME, f.COLUMN_ID, f.COMP_COLUMN_ID, f.BACKGROUND_COLOR, f.TEXT_COLOR, f.CONDITION_TYPE, f.CONDITION_TYPE_CODE, f.CONDITION_COLUMN_ID, f.CONDITION_COMP_COLUMN_ID, f.CONDITION_OPERATOR, f.CONDITION_IS_CASE_SENSITIVE, CONDITION_EXPRESSION, f.is_enabled order by null) idx, f.*
    from APEX_APPL_PAGE_IG_RPT_HIGHLTS f, current_report cr where f.report_id = cr.report_id ),
    base_highlights as ( select row_number() over (partition by f.NAME, f.COLUMN_ID, f.COMP_COLUMN_ID, f.BACKGROUND_COLOR, f.TEXT_COLOR, f.CONDITION_TYPE, f.CONDITION_TYPE_CODE, f.CONDITION_COLUMN_ID, f.CONDITION_COMP_COLUMN_ID, f.CONDITION_OPERATOR, f.CONDITION_IS_CASE_SENSITIVE, CONDITION_EXPRESSION, f.is_enabled order by null) idx, f.*
    from APEX_APPL_PAGE_IG_RPT_HIGHLTS f, base_report br where f.report_id = br.report_id ),
    /* Decide what to be shown */
    display_highlights as (select 
    idx, NAME, COLUMN_ID, COMP_COLUMN_ID, BACKGROUND_COLOR, TEXT_COLOR, CONDITION_TYPE, CONDITION_TYPE_CODE, CONDITION_COLUMN_ID, CONDITION_COMP_COLUMN_ID, CONDITION_OPERATOR, CONDITION_IS_CASE_SENSITIVE, CONDITION_EXPRESSION, is_enabled
    from current_highlights
    minus 
    select
    idx, NAME, COLUMN_ID, COMP_COLUMN_ID, BACKGROUND_COLOR, TEXT_COLOR, CONDITION_TYPE, CONDITION_TYPE_CODE, CONDITION_COLUMN_ID, CONDITION_COMP_COLUMN_ID, CONDITION_OPERATOR, CONDITION_IS_CASE_SENSITIVE, CONDITION_EXPRESSION, is_enabled
    from base_highlights),
    /* Use IDX to work out which can be removed */
    removable_highlights as (
    select c.* from current_highlights c
    , base_highlights d
    where 
    c.idx = d.idx
    and ( c.name = d.name OR c.name IS NULL AND d.name IS NULL )
    and ( c.column_id = d.column_id OR c.column_id IS NULL AND d.column_id IS NULL )
    and ( c.comp_column_id = d.comp_column_id OR c.comp_column_id IS NULL AND d.comp_column_id IS NULL )
    and ( c.BACKGROUND_COLOR = d.BACKGROUND_COLOR OR c.BACKGROUND_COLOR IS NULL AND d.BACKGROUND_COLOR IS NULL )
    and ( c.TEXT_COLOR = d.TEXT_COLOR OR c.TEXT_COLOR IS NULL AND d.TEXT_COLOR IS NULL )
    and ( c.CONDITION_TYPE = d.CONDITION_TYPE OR c.CONDITION_TYPE IS NULL AND d.CONDITION_TYPE IS NULL )
    and ( c.CONDITION_TYPE_CODE = d.CONDITION_TYPE_CODE OR c.CONDITION_TYPE_CODE IS NULL AND d.CONDITION_TYPE_CODE IS NULL )
    and ( c.CONDITION_COLUMN_ID = d.CONDITION_COLUMN_ID OR c.CONDITION_COLUMN_ID IS NULL AND d.CONDITION_COLUMN_ID IS NULL )
    and ( c.CONDITION_COMP_COLUMN_ID = d.CONDITION_COMP_COLUMN_ID OR c.CONDITION_COMP_COLUMN_ID IS NULL AND d.CONDITION_COMP_COLUMN_ID IS NULL )
    and ( c.CONDITION_OPERATOR = d.CONDITION_OPERATOR OR c.CONDITION_OPERATOR IS NULL AND d.CONDITION_OPERATOR IS NULL )
    and ( c.CONDITION_IS_CASE_SENSITIVE = d.CONDITION_IS_CASE_SENSITIVE OR c.CONDITION_IS_CASE_SENSITIVE IS NULL AND d.CONDITION_IS_CASE_SENSITIVE IS NULL )
    and ( c.CONDITION_EXPRESSION = d.CONDITION_EXPRESSION OR c.CONDITION_EXPRESSION IS NULL AND d.CONDITION_EXPRESSION IS NULL )
    and ( c.IS_ENABLED = d.IS_ENABLED OR c.IS_ENABLED IS NULL AND d.IS_ENABLED IS NULL )
    ),
    /* Final highlights for JSON */
    final_highlights as (
    select to_char(c.highlight_id) ID, NVL2(r.highlight_id,'Y','N') del, c.is_enabled, c.name label from current_highlights c,removable_highlights r
    where c.highlight_id = r.highlight_id(+) )
    select * from final_highlights;

    tb(tb.COUNT+1).message := 'open highlights';
    tb(tb.COUNT).split_time := dbms_utility.get_time - t1;
    t1 := dbms_utility.get_time;
    END IF;

    -- Flashbacks
    IF INSTR(l_settings_string, ':FB:') > 0 THEN
    open fb FOR
    with reports as (
    select rpts.* from 
    APEX_APPLICATION_PAGE_REGIONS r, 
    APEX_APPL_PAGE_IG_RPTS rpts
    where r.application_id = l_app_id
    and r.page_id = l_app_page_id
    and NVL(r.static_id, 'R' || r.region_id) = l_region_id
    and r.region_id = rpts.region_id ),
    current_report as ( select * from reports where report_id = l_report_id),
    base_report as ( select br.* from reports br, current_report cr where br.report_id = NVL(cr.base_report_id, cr.report_id ) ),
    /* Obtain Base/Current Unique IDXs */
    current_flashbacks as ( select *  FROM current_report cr ),
    base_flashbacks as ( select * from base_report br ),
    /* Decide what to be shown */
    display_flashbacks as (select  flashback_mins_ago
    from current_flashbacks
    minus 
    select
    flashback_mins_ago
    from base_flashbacks),
    /* Use IDX to work out which can be removed */
    removable_flashbacks as (
    select c.* from current_flashbacks c
    , base_flashbacks d
    where 
    ( c.flashback_mins_ago = d.flashback_mins_ago OR c.flashback_mins_ago IS NULL AND d.flashback_mins_ago IS NULL ) AND
    ( c.flashback_is_enabled = d.flashback_is_enabled OR c.flashback_is_enabled IS NULL AND d.flashback_is_enabled IS NULL )
    ),
    /* Final flashbacks for JSON */
    final_flashbacks as (
    select NULL ID, NVL2(r.report_id,'Y','N') del, c.flashback_is_enabled is_enabled, c.flashback_mins_ago || ' minutes ago' label from current_flashbacks c,removable_flashbacks r
    where c.report_id = r.report_id(+) and c.flashback_mins_ago is not null )
    select * from final_flashbacks;

    tb(tb.COUNT+1).message := 'open flashbacks';
    tb(tb.COUNT).split_time := dbms_utility.get_time - t1;
    t1 := dbms_utility.get_time;
    END IF;

    apex_json.open_object;
    apex_json.open_object('settings');
    IF INSTR(l_settings_string, ':F:') > 0 THEN
      apex_json. write('filter', f);
      tb(tb.COUNT+1).message := 'write filter';
      tb(tb.COUNT).split_time := dbms_utility.get_time - t1;
      t1 := dbms_utility.get_time;
    ELSE 
      apex_json.open_array('filter');
      apex_json.close_array; 
    END IF;
    IF INSTR(l_settings_string, ':C:') > 0 THEN
      apex_json. write('controlBreak', c);
      tb(tb.COUNT+1).message := 'write controlbreak';
      tb(tb.COUNT).split_time := dbms_utility.get_time - t1;
      t1 := dbms_utility.get_time;
    ELSE 
      apex_json.open_array('controlBreak');
      apex_json.close_array;
    END IF;
    IF INSTR(l_settings_string, ':A:') > 0 THEN
      apex_json. write('aggregate', a);
      tb(tb.COUNT+1).message := 'write aggregate';
      tb(tb.COUNT).split_time := dbms_utility.get_time - t1;
      t1 := dbms_utility.get_time;
    ELSE 
      apex_json.open_array('aggregate');
      apex_json.close_array;
    END IF;
    IF INSTR(l_settings_string, ':H:') > 0 THEN
      apex_json. write('highlight', h);
      tb(tb.COUNT+1).message := 'write highlight';
      tb(tb.COUNT).split_time := dbms_utility.get_time - t1;
      t1 := dbms_utility.get_time;
    ELSE 
      apex_json.open_array('highlight');
      apex_json.close_array;
    END IF;
    IF INSTR(l_settings_string, ':FB:') > 0 THEN
      apex_json. write('flashback', fb);
      tb(tb.COUNT+1).message := 'write flashback';
      tb(tb.COUNT).split_time := dbms_utility.get_time - t1;
      t1 := dbms_utility.get_time;
    ELSE 
      apex_json.open_array('flashback');
      apex_json.close_array;
    END IF;
    apex_json.close_object;
    apex_json.open_object('meta');
    apex_json. write('ReportId', l_report_id);
    apex_json. write('Cost', dbms_utility.get_time - t0 );
    apex_json.close_object;  
    IF NVL(V('DEBUG'),'NO') <> 'NO'
    THEN
      apex_json.open_object('debug');  
      FOR x in NVL(tb.FIRST,1)..NVL(tb.LAST,0)
      LOOP
        apex_json. write(x || ': ' || tb(x).message, tb(x).split_time);
      END LOOP;
      apex_json.close_object;  
    END IF;
    apex_json.close_object;

    RETURN l_result;
      
  END ajax;

END com_uk_explorer_ighigs;
/

show errors
