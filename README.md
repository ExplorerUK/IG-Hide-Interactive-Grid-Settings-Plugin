# IG-Hide-Interactive-Grid-Settings-Plugin

IG Hide Interactive Grid Settings APEX Plugin

<img src="https://raw.githubusercontent.com/ExplorerUK/IG-Hide-Interactive-Grid-Settings-Plugin/master/preview.gif" width="700px">

## Demo
https://apex.oracle.com/pls/apex/f?p=25679

## Release History
19.2 Initial Version

## How to install
Download this repository and import the plug-in into your application from this location:

`src/dynamic_action_plugin_com_uk_explorer_ighigs.sql`

It is strongly advised to put the JavaScript on your web server & compile the PLSQL on your Database for better performance.

## Features
* Hides all settings (Aggregates, Control Breaks, Filters, Flashbacks and Highlight) from saved reports
* When a report is modified, APEX spawns a session report with all settings cloned from the base report. All cloned settings on the session reports are hidden by this plugin leaving only user configured settings displayed. i.e All settings which are a 'delta' away from the base report are shown.
* Developers have a button to view the IG as the user would, meaning they can switch between the User View and Design mode.
* Ability to select which settings to hide
* Ability to select which report types to apply to (e.g Primary, Alternative, Private and Public)
* Supports multiple Hide Interactive Grid Settings Plugins on Multiple Interactive Grids on the same Page
* This plugin uses many techniques to hide/show settings to ensure the user experience is as smooth and gltich-free as possible
* Supports Chart/Icon/Detail/Grid/All Views
* Supports Firefox, IE, Edge & Chrome

## How to use
Create a Page Load Dynamic Action.
Select IG Hide Interactive Grid Settings APEX Plugin as the true action
Set affected elements to a Interactive Grid Region

## Settings
You can find a detailed explanation in the help section of the plugin.

## Issues

## Future developments
* Please let me know any of your wishes

