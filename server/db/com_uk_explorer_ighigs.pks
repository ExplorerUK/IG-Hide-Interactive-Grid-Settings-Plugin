CREATE OR REPLACE PACKAGE com_uk_explorer_ighigs AS

/*-------------------------------------
 * IG Hide IG Settings
 * Version: 19.2.0
 * Author:  Matt Mulvaney
 *-------------------------------------
*/
    FUNCTION render (
        p_dynamic_action   IN apex_plugin.t_dynamic_action,
        p_plugin           IN apex_plugin.t_plugin
    ) RETURN apex_plugin.t_dynamic_action_render_result;

    FUNCTION ajax (
        p_dynamic_action   IN apex_plugin.t_dynamic_action,
        p_plugin           IN apex_plugin.t_plugin
    ) RETURN apex_plugin.t_dynamic_action_ajax_result;

END com_uk_explorer_ighigs;
/