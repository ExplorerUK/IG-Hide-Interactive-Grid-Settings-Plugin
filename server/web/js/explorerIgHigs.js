/* eslint-disable no-unused-vars */
// eslint-disable-next-line no-undef
explorerIgHigs = (function () {
  "use strict";

  var changeReportSelector = ".a-Toolbar-selectList[data-action=\"change-report\"]";
  var debugPrefix = "Explorer IGHIGS Plugin: ";

  var nvl = function nvl(value1, value2) {
    if (value1 == null || value1 == "")
      return value2;
    return value1;
  };

  function getUserMode(pIgStaticId) {
    return nvl(sessionStorage.getItem("." + apex.item("pFlowId").getValue() + "." + apex.item("pFlowStepId").getValue() + ".igHigs." + pIgStaticId), "N");
  }

  function setUserMode(pIgStaticId, pValue) {
    sessionStorage.setItem("." + apex.item("pFlowId").getValue() + "." + apex.item("pFlowStepId").getValue() + ".igHigs." + pIgStaticId, pValue);
  }

  function isDeveloper(pIgStaticId) {
    return apex.region(pIgStaticId).call("option", "config").features.saveReport.isDeveloper;
  }

  function allSettingsHidden(pIgStaticId) {
    return ($("#" + pIgStaticId + " .a-IG-controls").children().filter(function (_index) {
      return $(this).css("display") === "block";
    }).length == 0);
  }

  function appliesToCurrentReport(options) {
    var regionId = options.da.action.affectedRegionId;
    var applyToReports = options.da.action.attribute02;
    var currentReportType = getCurrentReportType(regionId);
    var returnBoolean = false; 
    if ( applyToReports != null) {
      returnBoolean =  (applyToReports.split(":").indexOf(currentReportType) != -1);
    }
    return returnBoolean;
  }

  function shouldHide(options) {
    var regionId = options.da.action.affectedRegionId;
    return (
      appliesToCurrentReport(options) &&
      // Applies to current report and...
      // ...is a developer and masquerading as a user OR a user
      ((isDeveloper(regionId) && getUserMode(regionId) == "Y") || (!(isDeveloper(regionId))))
    );
  }

  function getCurrentReportType(pIgStaticId) {
    var reportsArray = apex.region(pIgStaticId).call("getReports");
    var rIdx = findWithAttr(reportsArray, "id", getCurrentReportId(pIgStaticId));
    var lReturn = "";
    if (rIdx != -1) {
      lReturn = reportsArray[rIdx].type;
    }
    return lReturn;
  }

  function userSettingsViewButton(options) {
    var regionId = options.da.action.affectedRegionId;
    if (isDeveloper(regionId) ) //&& appliesToCurrentReport(options) ) 
    {
      extendGridToolbar(options);
    } else {
      extendGridToolbar(options,true );
    }
  }

  function restoreUserView(options){
    apex.debug.info(debugPrefix + "restoreUserView");
    var vRegionId = options.da.action.affectedRegionId;
    // Remove CSS injections for the current report
    $(".igHigsInjectStyles-" + vRegionId + "-" + getCurrentReportId(vRegionId) ).replaceWith();
    cleanUp(options);
  }

  var render = function render(options) {
    var regionId = options.da.action.affectedRegionId;
    apex.debug.info(debugPrefix + "Render");
    apex.debug.info(debugPrefix, options);

    // Check this is an IG
    if ($("#" + regionId + " .a-IG").length == 0) {
      apex.debug.info(debugPrefix + "Error: Region " + regionId + " is not an Interactive Grid");
      return;
    }
    
    userSettingsViewButton(options);

    // Add events
    $("#" + regionId).on("interactivegridreportsettingschange", function (_event, _data) {
      apex.debug.info(debugPrefix + "Event - Settings Change");
      if (shouldHide(options)) { 
        injectStyles("div#" + regionId + "_ig_report_settings_summary{display:none}",regionId);
      }
      ajaxGetSettingstoHide(options);
    });

    $("#" + regionId).on("interactivegridviewchange", function (_event, _data) {
      apex.debug.info(debugPrefix + "Event - Grid View Change"); 
      userSettingsViewButton(options);
      if (shouldHide(options)) { 
        injectStyles("div#" + regionId + "_ig_report_settings_summary{display:none}",regionId);
      }
      ajaxGetSettingstoHide(options);
    });

    // Use a matches polyfill for IE9+
    // https://developer.mozilla.org/en-US/docs/Web/API/Element/matches
    if (!Element.prototype.matches) {
      Element.prototype.matches = Element.prototype.msMatchesSelector ||
        Element.prototype.webkitMatchesSelector;
    }

    var mutationObserver = new MutationObserver(function (mutations) {
      // Look for potentially change-report related mutations in JS as JQuery itself causes a mutation
      var mutationSelector = changeReportSelector;
      if (mutations[0].target.matches(mutationSelector) ||
        mutations[0].target.querySelectorAll(mutationSelector).length > 0) {
        apex.debug.info(debugPrefix + "Event - mutationObserver");
        if (shouldHide(options)) {
        // mutation is potentially change-report related
          injectStyles("div#" + regionId + "_ig_report_settings_summary{display:none}",regionId);
        }
        ajaxGetSettingstoHide(options);
      } 
    });

    // mutation observer checking tooolbar for mutations. 
    // we are unable to place observer on the change report select list as extending the toolbar removes the observer
    mutationObserver.observe($("#" + regionId + "_ig_toolbar")[0], {
      attributes: true,
      characterData: true,
      childList: true,
      subtree: true,
      attributeOldValue: true,
      characterDataOldValue: true
    });

    // Plugin Initial Startup
    ajaxGetSettingstoHide(options); 

  };

  var getCurrentReportId = function getCurrentReportId(pIgStaticId) {
    var retReportId;
    try {
      var grid = apex.region(pIgStaticId).call("getCurrentView");
      var model = grid.model;
      if (model) {
        retReportId = apex.region(pIgStaticId).call("getCurrentView").model.getOption("regionData").reportId;
      } else {
        // Model obviously not exists, possibly a chart view, therefore default to the select list if possible
        retReportId = $("#" + pIgStaticId).find(changeReportSelector)[0].value;
      }
    }
    catch (err) {
      retReportId = $("#" + pIgStaticId).find(changeReportSelector)[0].value;
    }

    return retReportId;
  };


  function ajaxGetSettingstoHide(options) {

    var requestData = {};
    var regionId = options.da.action.affectedRegionId; 
    var settingsToHide = ":" + options.da.action.attribute01 + ":";    
    var applyToReports = options.da.action.attribute02;
    requestData.x01 = getCurrentReportId(regionId);
    requestData.x02 = regionId;
    requestData.x03 = settingsToHide;
    requestData.x04 = applyToReports;

    // Stop glitch when changing report
    var regionCurrentReportId = $("#" + regionId).attr("igHigsCurrentReportId");
    var regionCurrentView = $("#" + regionId).attr("igHigsCurrentView");
    var currentView = apex.region(regionId).call("getCurrentView").internalIdentifier;

    $("#" + regionId).attr("igHigsCurrentReportId", requestData.x01);
    $("#" + regionId).attr("igHigsCurrentView", currentView);

    if ( shouldHide(options) &&
         ( ( requestData.x01 != regionCurrentReportId ) || 
         ( currentView != regionCurrentView )) 
    ) {
      apex.debug.info(debugPrefix + "Report switch detected", regionCurrentReportId, regionCurrentView, requestData.x01, currentView);
      injectStyles("#" + regionId + "_ig_report_settings{display:none}",regionId);
    }

    var promise = apex.server.plugin(options.ajaxIdentifier, requestData);

    promise.done(function (data) {

      apex.debug.info(debugPrefix + "AJAX results", data);

      if (settingsToHide.indexOf(":F:") != -1) { hideSetting(options, data, "filter"); }
      if (settingsToHide.indexOf(":C:") != -1) { hideSetting(options, data, "controlBreak"); }
      if (settingsToHide.indexOf(":A:") != -1) { hideSetting(options, data, "aggregate"); }
      if (settingsToHide.indexOf(":H:") != -1) { hideSetting(options, data, "highlight"); }
      if (settingsToHide.indexOf(":FB:") != -1) { hideSetting(options, data, "flashback"); }

      cleanUp(options);

      apex.da.resume(options.da.resumeCallback, false);
    }); 

  }

  function cleanUp(options) {

    var regionId = options.da.action.affectedRegionId;
    injectStyles("div#" + regionId + "_ig_report_settings_summary{display:block}",regionId);

    // Remove Bar if nesessary 
    if (allSettingsHidden(regionId)) { 
      injectStyles("#" + regionId + "_ig_report_settings{display:none}",regionId);
    } else { 
      injectStyles("#" + regionId + "_ig_report_settings{display:block}",regionId);
    }
  }

  function hideSetting(options, baseSettings, element) {
    var regionId = options.da.action.affectedRegionId;
    var summaryString = "";
    var summaryCount = 0;
    var rootElement = baseSettings.settings[element];  

    for (var i = 0; i < rootElement.length; i++) {
      // Generate Zap String
      var settingID = "";
      if (typeof rootElement[i].ID != "undefined") {
        settingID = rootElement[i].ID;
      }      
      var zapString = "#" + regionId + " li.a-IG-controls-item--" + element + "[aria-labelledby=\"control_text" + settingID + "\"]";

      if (rootElement[i].DEL == "Y" && shouldHide(options)) {
        injectStyles(zapString + " { display: none; }", regionId); 
      } else { //if (rootElement[i].DEL == "N") {
        injectStyles(zapString + " { display: block; }", regionId);  
        if ( rootElement[i].IS_ENABLED == "Yes" ) {
          summaryString = summaryString + rootElement[i].LABEL + ", ";
          summaryCount++;
        }
      }
    }

    // Rewrite Summmary label/count
    if (summaryCount > 0) {
      $("#" + regionId + "_ig_report_settings_summary .a-IG-reportSummary-item--" + element + " .a-IG-reportSummary-value").text(summaryString.substr(0, summaryString.length - 2));
      if (summaryCount == 1) {
        summaryCount = "";
      }
      $("#" + regionId + "_ig_report_settings_summary .a-IG-reportSummary-item--" + element + " .a-IG-reportSummary-count").text(summaryCount);
      injectStyles("#" + regionId + "_ig_report_settings_summary .a-IG-reportSummary-item--" + element + " {display: block}", regionId);
    } else { 
      injectStyles("#" + regionId + "_ig_report_settings_summary .a-IG-reportSummary-item--" + element + " {display: none}", regionId);
    }

  }

  // https://css-tricks.com/snippets/javascript/inject-new-css-rules/
  function injectStyles(rule, regionId) {
    var container = "igHigsCSSInjectionContainer";

    // Create
    if ( $("#" + container).length == 0 ) {
      $("<div />", {
        id: container
      }).appendTo("body");    
    }
    var div = $("<div />", {
      html: "<style>" + rule + "</style>",
      class: "igHigsInjectStyles-" + regionId + "-" + getCurrentReportId(regionId)
    }).appendTo($("#" + container));    
  }

  // https://stackoverflow.com/a/7178381
  function findWithAttr(array, attr, value) {
    for (var i = 0; i < array.length; i += 1) {
      if (array[i][attr] === value) {
        return i;
      }
    }
    return -1;
  }

  // https://github.com/mgoricki/apex-plugin-extend-ig-toolbar
  function extendGridToolbar(options, pRemoveOnly) {

    var da = options.da;
    apex.debug.info(debugPrefix + "extendGridToolbar", da);

    // get plugin attributes
    var vGroup = "actions4";
    var vPosition = "F";
    var vLabel = "User View";
    var vHot = false;
    var vIcon;
    var vIconOnly = false;
    var vIconPosition = true;
    var vTitle = "DEVELOPERS ONLY: Toggle what the user would see (i.e the User View) on or off";
    var vAction = "igHigsMode";
    var vDisabled = false;
    var vHidden = false;
    var vID = "igHigsUserModeButton";

    // get Region
    var vRegionId = da.affectedElements[0].id; 
    var userMode = getUserMode(vRegionId);

    // check icon 
    if (userMode == "Y") {
      vIcon = "fa fa-check-square-o";
    } else {
      vIcon = "fa fa-square-o";
    }

    // Get Widget
    var vWidget$ = apex.region(vRegionId).widget();

    // Grid created
    var toolbar = vWidget$.interactiveGrid("getToolbar");

    var vaButton = {
      type: "BUTTON",
      label: vLabel,
      title: vTitle,
      labelKey: vLabel, // label from text messages
      action: vAction,
      icon: vIcon,
      iconOnly: vIconOnly,
      iconBeforeLabel: vIconPosition,
      hot: vHot,
      id: vID
    };

    var config = $.extend(true, {}, toolbar.toolbar("option"));
    var toolbarData = config.data;
    var toolbarGroup = toolbarData.filter(function (group) {
      return group.id === vGroup;
    })[0];

    var buttonIdx = findWithAttr(toolbarGroup.controls, "id", vID);
    if (buttonIdx > -1) {
      toolbarGroup.controls.splice(buttonIdx, 1);
    }

    if (!pRemoveOnly) {
      if (toolbarGroup) {
        if (vPosition == "F") {
          toolbarGroup.controls.unshift(vaButton);
        } else {
          toolbarGroup.controls.push(vaButton);
        }
      }

      toolbar.toolbar("option", "data", config.data);

      // add actions
      var vActions = vWidget$.interactiveGrid("getActions");

      // check if action exists, then just assign it
      var vAction$ = vActions.lookup(vAction);
      if (!vAction$) {
        vActions.add(
          {
            name: vAction, 
            action: function (_event, _element) {
              // -- Start Action Code 
              var userMode = getUserMode(vRegionId);
              var newUserMode;
              if (userMode == "Y") { newUserMode = "N"; } else { newUserMode = "Y"; }
              setUserMode(vRegionId, newUserMode);

              if (newUserMode == "N" && appliesToCurrentReport(options)) {
                restoreUserView(options);
              }

              // Put the  button back on with new icon
              extendGridToolbar(options);
              // -- End Action code
            }, 
            hide: vHidden, 
            disabled: vDisabled
          });
      } else {
        vAction$.hide = vHidden;
        vAction$.disabled = vDisabled;
      }
    } else {
      toolbar.toolbar("option", "data", config.data);
    }

    // refresh grid
    toolbar.toolbar("refresh");
  }

  // Public functions
  return ({
    render: render
  });

}());