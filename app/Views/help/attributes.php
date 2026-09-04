<?php
# Copyright © 2023 FirstWave. All Rights Reserved.
# SPDX-License-Identifier: AGPL-3.0-or-later

$intro = '<p>'. __('The Attributes endpoint allows you to add customized values to different attributes in ' . APP_DISPLAY_NAME . ', at the moment this feature works on the Class, Environment, Status and Type attributes on Devices, the Type attribute for both Locations and Orgs as well as the Menu Category for Queries. If you view an item of one of the previous types (say view a Location) you will notice the Type attribute must be selected from a drop-down box. This is where those values are stored. Hence, if you would like to add a new Type to be chosen for a Location, add it using the Attributes feature.') . '</p>
    <br>
    <h2>' . __('How Does it Work?') . '</h2>
    <p>' . __('Attributes are stored for ' . APP_DISPLAY_NAME . ' to use for particular fields, at present all fields are based on the devices, locations, orgs and queries tables. The attributes you can edit are associated with the following columns: Class, Environment, Status & Type.') . '</p>';

$body = '<h2>' . __('Notes') . '</h2>
<br>
' . __('If you add a device type, to display the associated icon you will have to manually copy the .svg formatted file to the directory') . ':<br>
<pre>
    Linux: /usr/local/' . APP_WEB_ALIAS . '/public/device_images
    Windows: c:\\xampp\\htdocs\\' . APP_WEB_ALIAS . '\\device_images
</pre>
<br>
' . __('If you add a Location Type, add those icons to') . ':<br>
<pre>
    Linux: /usr/local/' . APP_WEB_ALIAS . '/public/images/map_icons
    Windows: c:\\xampp\\htdocs\\' . APP_WEB_ALIAS . '\\images\\map_icons
</pre>
<br>';
