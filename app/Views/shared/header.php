<?php
# Copyright © 2023 FirstWave. All Rights Reserved.
# SPDX-License-Identifier: AGPL-3.0-or-later

$news = new \stdClass();
if (!empty($config->feature_news) and $config->feature_news === 'y') {
    if ($meta->collection !== 'news') {
        $news = getNews();
    }
}

$title = APP_DISPLAY_NAME . ' ' . $config->display_version;

// sort our queries, summaries and reports
$reports = array();
$categories = array();
if (!empty($queries)) {
    foreach ($queries as $item) {
        if ($item->{'attributes'}->{'menu_display'} === 'y') {
            $item->name = $item->{'attributes'}->{'name'};
            $reports[] = $item;
            $categories[] = $item->{'attributes'}->{'menu_category'};
        }
    }
}
$GLOBALS['table'] = !empty($GLOBALS['table']) ? $GLOBALS['table'] : '';
function my_comparison($asort, $bsort)
{
    return strcmp($asort->name, $bsort->name);
}
usort($reports, 'my_comparison');
asort($categories);
$categories = array_unique($categories);
$homepage = url_to('summariesCollection');
if ($config->product !== 'community') {
    $dashboard = (!empty($user->dashboard_id)) ? $user->dashboard_id : 1;
    $homepage = url_to('dashboardsExecute', $dashboard);
}
if (!empty($config->servers)) {
    $homepage = url_to('dashboardCollector');
}
?>
<!DOCTYPE html>
<html lang="en" class="h-100">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="description" content="<?= esc(APP_DISPLAY_NAME) ?>">
        <meta name="author" content="Mark Unwin">
        <link rel="shortcut icon" href="<?= base_url('favicon.png') ?>" type="image/x-icon">
        <title><?= esc(APP_DISPLAY_NAME) ?></title>

        <!-- JS -->
        <script {csp-script-nonce} src="<?= base_url('js/jquery.min.js') ?>"></script>
        <script {csp-script-nonce} defer src="<?= base_url('js/popper.min.js') ?>"></script>
        <script {csp-script-nonce} defer src="<?= base_url('js/bootstrap.bundle.min.js') ?>"></script>
        <script {csp-script-nonce} defer src="<?= base_url('js/datatables.min.js') ?>"></script>
        <script {csp-script-nonce} defer src="<?= base_url('js/datatables.extra.js') ?>"></script>
        <script {csp-script-nonce} defer src="<?= base_url('js/apexcharts.js') ?>"></script>
        <script {csp-script-nonce} defer src="<?= base_url('js/echarts.min.js') ?>"></script>
        <script {csp-script-nonce} defer src="<?= base_url('js/select2.full.min.js') ?>"></script>
        <script {csp-script-nonce} defer src="<?= base_url('js/open-audit.js') ?>"></script>

        <!-- CSS -->
        <link href="<?= base_url('css/inter.css') ?>" rel="stylesheet">
        <link href="<?= base_url('css/bootstrap.css') ?>" rel="stylesheet">
        <link href="<?= base_url('css/datatables.min.css') ?>" rel="stylesheet">
        <link href="<?= base_url('css/datatables.extra.css') ?>" rel="stylesheet">
        <link href="<?= base_url('css/select2.min.css') ?>" rel="stylesheet">
        <link href="<?= base_url('css/select2-bootstrap-5-theme.min.css') ?>" rel="stylesheet">
        <link href="<?= base_url('css/lucide.css') ?>" rel="stylesheet">
        <link href="<?= base_url('css/open-audit.css') ?>" rel="stylesheet">

        <!-- Open-AudIT specific items -->
        <script {csp-script-nonce}><?php
        echo "\n";
        if (isset($meta->id) and !is_null($meta->id)) {
                echo "            var id = '" . $meta->id . "';\n";
        }
        if (!empty($meta->collection)) {
            echo "            var collection = '" . $meta->collection . "';\n";
        }
        if (!empty($meta->baseurl)) {
            echo "            var baseurl = '" . $meta->baseurl . "index.php';\n";
        } else {
            echo "            var baseurl = '';\n";
        } ?>
            var web_folder = '<?= base_url() ?>';
            var device_auto_delete = '<?= @$config->device_auto_delete; ?>';

            let prefers = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
            let html = document.querySelector('html');
            html.classList.add(prefers);
            html.setAttribute('data-bs-theme', prefers);
            var license_string_id = <?= isset($config->license_string_id) ? $config->license_string_id : '' ?>;
            var oae_prompt_id = <?= $config->oae_prompt_id ?>;
        </script>
    </head>
    <!-- Need d-flex flex-column h-100 to hold footer in place -->
    <body class="d-flex flex-column h-100">
        <!-- Menu -->
        <nav class="navbar navbar-expand-md">
            <div class="container-fluid">
                <a class="navbar-brand" style="color: white;" href="<?= $homepage ?>">
                    <img class="border border-white border-0" style="width:25px; height: 25px; margin-right:6px;" src="<?= base_url('images/app-logo.png') ?>" alt="<?= esc(APP_DISPLAY_NAME) ?>">
                    <?= $title . "\n" ?>
                </a>
                <div class="collapse navbar-collapse" id="navbarNavDropdown">
                    <ul class="navbar-nav">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="navbarDiscover" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false" style="color: white;"><?= __('Discover') ?></a>
                            <ul class="dropdown-menu" aria-labelledby="navbarDiscover">
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('credentialsCollection') ?>"><?= __('Credentials') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('credentials', 'r', $user, 'credentialsCollection', __('List') . ' ' . __('Credentials')) ?>
                                        <?= menuItem('credentials', 'c', $user, 'credentialsCreateForm', __('Create') . ' ' . __('Credentials')) ?>
                                        <?= menuItem('credentials', 'c', $user, 'credentialsImportForm', __('Import') . ' ' . __('Credentials')) ?>
                                        <?= menuItem('credentials', '', $user, 'credentialsHelp', __('Learn About') . ' ' . __('Credentials')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('discoveriesCollection') ?>"><?= __('Discoveries') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('discoveries', 'r', $user, 'discoveriesCollection', __('List') . ' ' . __('Discoveries')) ?>
                                        <?= menuItem('discoveries', 'c', $user, 'discoveriesCreateForm', __('Create') . ' ' . __('Discoveries')) ?>
                                        <?= menuItem('discoveries', 'c', $user, 'discoveriesImportForm', __('Import') . ' ' . __('Discoveries')) ?>
                                        <?= menuItem('discoveries', '', $user, 'discoveriesHelp', __('Learn About') . ' ' . __('Discoveries')) ?>
                                        <li><hr class="dropdown-divider"></li>
                                        <?= menuItem('configuration', 'r', $user, 'configurationCollection', __('Global Discovery Options'), '?configuration.name=likediscovery_') ?>
                                        <?= menuItem('configuration', 'r', $user, 'configurationCollection', __('Discovery Match Options'), '?configuration.name=likematch_') ?>
                                        <?= menuItem('configuration', 'r', $user, 'configurationCollection', __('Discovery Change Logs'), '?configuration.name=likecreate_change_log') ?>
                                        <?= menuItem('configuration', 'r', $user, 'configurationCollection', __('Discovery Data Retention'), '?configuration.name=likedelete_noncurrent') ?>
                                        <li><a class="dropdown-item dropdown-toggle second-level-dropdown-toggle" href="#"><?= __('Discovery Scan Options') ?></a>
                                            <ul class="dropdown-menu">
                                                <?= menuItem('discovery_scan_options', 'r', $user, 'discovery_scan_optionsCollection', __('List') . ' ' . __('Discovery Scan Options')) ?>
                                                <?= menuItem('discovery_scan_options', 'c', $user, 'discovery_scan_optionsCreateForm', __('Create') . ' ' . __('Discovery Scan Options')) ?>
                                                <li><a class="dropdown-item" href="<?= url_to('discovery_scan_optionsHelp') ?>"><?= __('Learn About') . ' ' . __('Discovery Scan Options') ?></a></li>
                                            </ul>
                                        </li>
                                        <li><hr class="dropdown-divider"></li>
                                        <?= menuItem('tasks', 'c', $user, 'tasksCreateForm', __('Schedule') . ' ' . __('Discoveries'), '?type=discoveries') ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('scriptsCollection') ?>"><?= __('Scripts') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('scripts', 'r', $user, 'scriptsCollection', __('List') . ' ' . __('Scripts')) ?>
                                        <?= menuItem('scripts', 'c', $user, 'scriptsCreateForm', __('Create') . ' ' . __('Scripts')) ?>
                                        <?= menuItem('scripts', '', $user, 'scriptsHelp', __('Learn About') . ' ' . __('Scripts')) ?>
                                    </ul>
                                </li>
                            </ul>
                        </li>

                        <!-- The Report menu -->
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="navbarReport" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false" style="color: white;"><?= __('Report') ?></a>
                            <ul class="dropdown-menu" aria-labelledby="navbarReport">
                            <?php
                            foreach ($categories as $category) {
                                if ($category === 'Discovery') {
                                    continue;
                                }
                                echo "
                            <li><a class=\"dropdown-item dropdown-toggle first-level-dropdown-toggle\" href=\"#\">" . __($category) . "</a>\n                            <ul class=\"dropdown-menu\">\n";
                                foreach ($reports as $report) {
                                    if ($report->{'attributes'}->{'menu_category'} === $category) {
                                        if (!empty($report->{'attributes'}->{'commercial'}) and $report->{'attributes'}->{'commercial'} === 'y' and (empty($config->product) or $config->product === 'community')) {
                                            // Omit commercial reports from community UI (no upgrade toast)
                                        } else {
                                            echo "                                <li><a class=\"dropdown-item\" href=\"" . url_to($report->type . 'Execute', $report->id) . "\">" . $report->{'attributes'}->{'name'} . "</a></li>\n";
                                        }
                                    }
                                }
                                echo "                            </ul>\n";
                            } ?>
                                <?= menuItem('tasks', 'r', $user, 'tasksCollection', __('Schedule') . ' ' . __('Reports')) ?>
                            </ul>
                        </li>

                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="navbarManage" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false" style="color: white;"><?= __('Manage') ?></a>
                            <ul class="dropdown-menu" aria-labelledby="navbarManage">
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('attributesCollection') ?>"><?= __('Attributes') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('attributes', 'r', $user, 'attributesCollection', __('List') . ' ' . __('Attributes')) ?>
                                        <?= menuItem('attributes', 'c', $user, 'attributesCreateForm', __('Create') . ' ' . __('Attributes')) ?>
                                        <?= menuItem('attributes', 'c', $user, 'attributesImportForm', __('Import') . ' ' . __('Attributes')) ?>
                                        <?= menuItem('attributes', '', $user, 'attributesDefaults', __('Default') . ' ' . __('Attributes')) ?>
                                        <?= menuItem('attributes', '', $user, 'attributesHelp', __('Learn About') . ' ' . __('Attributes')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('connectionsCollection') ?>"><?= __('Connections') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('connections', 'r', $user, 'connectionsCollection', __('List') . ' ' . __('Connections')) ?>
                                        <?= menuItem('connections', 'c', $user, 'connectionsCreateForm', __('Create') . ' ' . __('Connections')) ?>
                                        <?= menuItem('connections', '', $user, 'connectionsHelp', __('Learn About') . ' ' . __('Connections')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('devicesCollection') ?>"><?= __('Devices') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('devices', 'r', $user, 'devicesCollection', __('List') . ' ' . __('Devices')) ?>
                                        <?= menuItem('devices', 'c', $user, 'devicesCreateForm', __('Import') . ' ' . __('Devices') . ' ' . __('from Audit Script Result')) ?>
                                        <?= menuItem('devices', 'c', $user, 'devicesImportNMISForm', __('Import') . ' ' . __('Devices') . ' ' . __('from NMIS')) ?>
                                        <?= menuItem('devices', '', $user, 'devicesHelp', __('Learn About') . ' ' . __('Devices')) ?>
                                        <li><hr class="dropdown-divider"></li>
                                        <?= menuItem('devices', 'c', $user, 'devicesExampleForm', __('Import') . ' ' . __('Example Devices')) ?>
                                        <?= menuItem('devices', 'c', $user, 'devicesDeleteForm', __('Delete') . ' ' . __('Example Devices')) ?>
                                        <li><hr class="dropdown-divider"></li>
                                        <?= menuItem('configuration', 'u', $user, 'configurationCollection', __('Configure') . ' ' . __('Change Logs'), '?configuration.name=likecreate_change_log') ?>
                                        <?= menuItem('configuration', 'u', $user, 'configurationCollection', __('Configure') . ' ' . __('Data Retention'), '?configuration.name=likedelete_non_current') ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('fieldsCollection') ?>"><?= __('Fields') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('fields', 'r', $user, 'fieldsCollection', __('List') . ' ' . __('Fields')) ?>
                                        <?= menuItem('fields', 'c', $user, 'fieldsCreateForm', __('Create') . ' ' . __('Fields')) ?>
                                        <?= menuItem('fields', 'c', $user, 'fieldsImportForm', __('Import') . ' ' . __('Fields')) ?>
                                        <?= menuItem('fields', '', $user, 'fieldsDefaults', __('Default') . ' ' . __('Fields')) ?>
                                        <?= menuItem('fields', '', $user, 'fieldsHelp', __('Learn About') . ' ' . __('Fields')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('groupsCollection') ?>"><?= __('Groups') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('groups', 'r', $user, 'groupsCollection', __('List') . ' ' . __('Groups')) ?>
                                        <?= menuItem('groups', 'c', $user, 'groupsCreateForm', __('Create') . ' ' . __('Groups')) ?>
                                        <?= menuItem('groups', 'c', $user, 'groupsImportForm', __('Import') . ' ' . __('Groups')) ?>
                                        <?= menuItem('groups', '', $user, 'groupsDefaults', __('Default') . ' ' . __('Groups')) ?>
                                        <?= menuItem('groups', '', $user, 'groupsHelp', __('Learn About') . ' ' . __('Groups')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('licensesCollection') ?>"><?= __('Licenses') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('licenses', 'r', $user, 'licensesCollection', __('List') . ' ' . __('Licenses')) ?>
                                        <?= menuItem('licenses', 'c', $user, 'licensesCreateForm', __('Create') . ' ' . __('Licenses')) ?>
                                        <?= menuItem('licenses', 'c', $user, 'licensesImportForm', __('Import') . ' ' . __('Licenses')) ?>
                                        <?= menuItem('licenses', '', $user, 'licensesHelp', __('Learn About') . ' ' . __('Licenses')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('locationsCollection') ?>"><?= __('Locations') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('locations', 'r', $user, 'locationsCollection', __('List') . ' ' . __('Locations')) ?>
                                        <?= menuItem('locations', 'c', $user, 'locationsCreateForm', __('Create') . ' ' . __('Locations')) ?>
                                        <?= menuItem('locations', 'c', $user, 'locationsImportForm', __('Import') . ' ' . __('Locations')) ?>
                                        <?= menuItem('locations', '', $user, 'locationsDefaults', __('Default') . ' ' . __('Locations')) ?>
                                        <?= menuItem('locations', '', $user, 'locationsHelp', __('Learn About') . ' ' . __('Locations')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('networksCollection') ?>"><?= __('Networks') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('networks', 'r', $user, 'networksCollection', __('List') . ' ' . __('Networks')) ?>
                                        <?= menuItem('networks', 'c', $user, 'networksCreateForm', __('Create') . ' ' . __('Networks')) ?>
                                        <?= menuItem('networks', 'c', $user, 'networksImportForm', __('Import') . ' ' . __('Networks')) ?>
                                        <?= menuItem('networks', '', $user, 'networksHelp', __('Learn About') . ' ' . __('Networks')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('orgsCollection') ?>"><?= __('Orgs') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('orgs', 'r', $user, 'orgsCollection', __('List') . ' ' . __('Orgs')) ?>
                                        <?= menuItem('orgs', 'c', $user, 'orgsCreateForm', __('Create') . ' ' . __('Orgs')) ?>
                                        <?= menuItem('orgs', 'c', $user, 'orgsImportForm', __('Import') . ' ' . __('Orgs')) ?>
                                        <?= menuItem('orgs', '', $user, 'orgsDefaults', __('Default') . ' ' . __('Orgs')) ?>
                                        <?= menuItem('orgs', '', $user, 'orgsHelp', __('Learn About') . ' ' . __('Orgs')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('packagesCollection') ?>"><?= __('Packages') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('packages', 'r', $user, 'packagesCollection', __('List') . ' ' . __('AntiVirus Packages'), '?packages.type=antivirus') ?>
                                        <?= menuItem('packages', 'r', $user, 'packagesCollection', __('List') . ' ' . __('Firewall Packages'), '?packages.type=firewall') ?>
                                        <?= menuItem('packages', 'r', $user, 'packagesCollection', __('List') . ' ' . __('Approved Packages'), '?packages.type=approved') ?>
                                        <?= menuItem('packages', 'r', $user, 'packagesCollection', __('List') . ' ' . __('Banned Packages'), '?packages.type=banned') ?>
                                        <?= menuItem('packages', 'c', $user, 'packagesCreateForm', __('Create') . ' ' . __('Linux Packages'), '?os=Linux&range=a') ?>
                                        <?= menuItem('packages', 'c', $user, 'packagesCreateForm', __('Create') . ' ' . __('MacOS Packages'), '?os=Apple&range=a') ?>
                                        <?= menuItem('packages', 'c', $user, 'packagesCreateForm', __('Create') . ' ' . __('Windows Packages'), '?os=Windows&range=a') ?>
                                        <?= menuItem('packages', 'c', $user, 'packagesImportForm', __('Import') . ' ' . __('Packages')) ?>
                                        <?= menuItem('packages', '', $user, 'packagesDefaults', __('Default') . ' ' . __('Packages')) ?>
                                        <?= menuItem('packages', '', $user, 'packagesHelp', __('Learn About') . ' ' . __('Packages')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('queriesCollection') ?>"><?= __('Queries') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('queries', 'r', $user, 'queriesCollection', __('List') . ' ' . __('Queries')) ?>
                                        <?= menuItem('queries', 'c', $user, 'queriesCreateForm', __('Create') . ' ' . __('Queries')) ?>
                                        <?= menuItem('queries', 'c', $user, 'queriesImportForm', __('Import') . ' ' . __('Queries')) ?>
                                        <?= menuItem('queries', '', $user, 'queriesDefaults', __('Default') . ' ' . __('Queries')) ?>
                                        <?= menuItem('queries', '', $user, 'queriesHelp', __('Learn About') . ' ' . __('Queries')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('rulesCollection') ?>"><?= __('Rules') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('rules', 'r', $user, 'rulesCollection', __('List') . ' ' . __('Rules')) ?>
                                        <?= menuItem('rules', 'c', $user, 'rulesCreateForm', __('Create') . ' ' . __('Rules')) ?>
                                        <?= menuItem('rules', 'c', $user, 'rulesImportForm', __('Import') . ' ' . __('Rules')) ?>
                                        <?= menuItem('rules', '', $user, 'rulesDefaults', __('Default') . ' ' . __('Rules')) ?>
                                        <?= menuItem('rules', '', $user, 'rulesHelp', __('Learn About') . ' ' . __('Rules')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('summariesCollection') ?>"><?= __('Summaries') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('summaries', 'r', $user, 'summariesCollection', __('List') . ' ' . __('Summaries')) ?>
                                        <?= menuItem('summaries', 'c', $user, 'summariesCreateForm', __('Create') . ' ' . __('Summaries')) ?>
                                        <?= menuItem('summaries', 'c', $user, 'summariesImportForm', __('Import') . ' ' . __('Summaries')) ?>
                                        <?= menuItem('summaries', '', $user, 'summariesDefaults', __('Default') . ' ' . __('Summaries')) ?>
                                        <?= menuItem('summaries', '', $user, 'summariesHelp', __('Learn About') . ' ' . __('Summaries')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('widgetsCollection') ?>"><?= __('Widgets') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('widgets', 'r', $user, 'widgetsCollection', __('List') . ' ' . __('Widgets')) ?>
                                        <?= menuItem('widgets', 'c', $user, 'widgetsCreateForm', __('Create') . ' ' . __('Widgets')) ?>
                                        <?= menuItem('widgets', 'c', $user, 'widgetsImportForm', __('Import') . ' ' . __('Widgets')) ?>
                                        <?= menuItem('widgets', '', $user, 'widgetsDefaults', __('Default') . ' ' . __('Widgets')) ?>
                                        <?= menuItem('widgets', '', $user, 'widgetsHelp', __('Learn About') . ' ' . __('Widgets')) ?>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                    </ul>

                    <ul class="navbar-nav ms-auto">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle " href="#" id="navbarAdmin" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false" style="color: white;"><?= __('Admin') ?></a>
                            <ul class="dropdown-menu" aria-labelledby="navbarAdmin">
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('authCollection') ?>"><?= __('Auth') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('auth', 'r', $user, 'authCollection', __('List') . ' ' . __('Auth Methods')) ?>
                                        <?= menuItem('auth', 'c', $user, 'authCreateForm', __('Create') . ' ' . __('Auth Methods')) ?>
                                        <?= menuItem('auth', '', $user, 'authHelp', __('Learn About') . ' ' . __('Auth Methods')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('configurationCollection') ?>"><?= __('Configuration') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('configuration', 'r', $user, 'configurationCollection', __('List') . ' ' . __('Configuration')) ?>
                                        <?= menuItem('configuration', 'r', $user, 'configurationCollection', __('Email Configuration'), '?configuration.name=likemail') ?>
                                        <?= menuItem('configuration', 'd', $user, 'configurationDefaults', 'Default Configuration') ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('databaseCollection') ?>"><?= __('Database') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('database', 'r', $user, 'databaseCollection', __('List') . ' ' . __('Database Tables')) ?>
                                        <?= menuItem('database', 'r', $user, 'databaseCompare', 'Compare Database Schema') ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('rolesCollection') ?>"><?= __('Roles') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('roles', 'r', $user, 'rolesCollection', __('List') . ' ' . __('Roles')) ?>
                                        <?= menuItem('roles', 'c', $user, 'rolesCreateForm', __('Create') . ' ' . __('Roles')) ?>
                                        <?= menuItem('roles', 'c', $user, 'rolesImportForm', __('Import') . ' ' . __('Roles')) ?>
                                        <?= menuItem('roles', '', $user, 'rolesDefaults', __('Default') . ' ' . __('Roles')) ?>
                                        <?= menuItem('roles', '', $user, 'rolesHelp', __('Learn About') . ' ' . __('Roles')) ?>
                                    </ul>
                                </li>
                                <li><a class="dropdown-item dropdown-toggle first-level-dropdown-toggle" href="<?= url_to('usersCollection') ?>"><?= __('Users') ?></a>
                                    <ul class="dropdown-menu">
                                        <?= menuItem('users', 'r', $user, 'usersCollection', __('List') . ' ' . __('Users')) ?>
                                        <?= menuItem('users', 'c', $user, 'usersCreateForm', __('Create') . ' ' . __('Users')) ?>
                                        <?= menuItem('users', 'c', $user, 'usersImportForm', __('Import') . ' ' . __('Users')) ?>
                                        <?= menuItem('users', '', $user, 'usersDefaults', __('Default') . ' ' . __('Users')) ?>
                                        <?= menuItem('users', '', $user, 'usersHelp', __('Learn About') . ' ' . __('Users')) ?>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="navbarHelp" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false" style="color: white;"><?= __('Help') ?></a>
                            <!-- Community -->
                            <ul class="dropdown-menu" aria-labelledby="navbarHelp">
                                <li><a class="dropdown-item" href="<?= url_to('api') ?>"><?= __('API Documentation') ?></a></li>
                                <li><a class="dropdown-item" href="<?= url_to('audit_my_pc') ?>"><?= __('Audit My PC') ?></a></li>
                                <li><a class="dropdown-item" href="<?= url_to('welcome') ?>"><?= __('Getting Started') ?></a></li>
                                <li><a class="dropdown-item" href="<?= url_to('supportCollection') ?>"><?= __('Support') ?></a></li>
                                <li><a class="dropdown-item" href="<?= url_to('util/test_windows_client') ?>"><?= __('Windows Test Script') ?></a></li>
                            </ul>

                        <!-- User -->
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="navbarUser" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false" style="color: white;"><?= __('User') ?>: <?= htmlentities($user->name) ?></a>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" href="<?= url_to('usersRead', $user->id) ?>"><?= __('Preferences'); ?></a></li>
                                <li><a class="dropdown-item" href="<?= url_to('logoff') ?>" role="button"><?= __('Logout'); ?></a></li>
                            </ul>
                        </li>

                        <?php if ($GLOBALS['browser_lang'] !== $user->lang) { ?>
                            <li class="nav-item">
                                <a style="padding-top:10px;" role="button" tabindex="0" class="btn btn-clear btn-sm" data-bs-html="true" data-bs-toggle="popover" data-bs-placement="left" data-bs-trigger="focus" data-bs-content="<?= __(codeToCountry($GLOBALS['browser_lang'])) . __(' is now supported with a language file. To change your user to use this language, click ') . ' <a href=\'' . url_to('usersRead', $user->id) . '\'>' . __('here') . '</a>.' ?>">
                                    <i class="icon-earth" style="color: #ffc107;"></i>
                                </a>
                            </li>
                        <?php } ?>

                        <?php if (!empty($config->servers)) { ?>
                        <li class="nav-item">
                            <a href="<?= url_to('dashboardCollector') ?>" role="button" class="btn btn-primary"><?= $config->servers->type ?></a>
                        </li>
                        <?php } ?>
                    </ul>
                </div>
            </div>
        </nav>

        <!-- Breadcrumbs -->

        <div class="container-fluid" style="margin-bottom: -10px;">
                <div class="row second-nav">
                    <div class="col-6" style="padding-bottom: 0px; padding-top: 16px;">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb">
                                <li class="breadcrumb-item"><a href="<?= $homepage ?>" class="link-secondary"><?= __('Home') ?></a></li>
                                <?php if (empty($meta->breadcrumbs)) {
                                    $breadcrumb_collection = $meta->collection;
                                    if ($meta->collection === 'rack_devices') {
                                        $breadcrumb_collection = 'racks';
                                    }
                                    echo '<li class="breadcrumb-item"><a href="' . url_to($breadcrumb_collection . 'Collection') . '" class="link-secondary">' .__(@ucwords(str_replace('_', ' ', $breadcrumb_collection))) . "</a></li>\n";
                                    if (($meta->action === 'read' or $meta->action === 'execute') and !empty($name)) {
                                        echo '<li class="breadcrumb-item"><a href="' . url_to($breadcrumb_collection . 'Read', $meta->id) . '" class="link-secondary">' . htmlentities($name) . "</a></li>\n";
                                    }
                                } else {
                                    foreach ($meta->breadcrumbs as $breadcrumb) { ?>
                                        <li class="breadcrumb-item"><a href="<?= $breadcrumb->url ?>" class="link-secondary"><?= $breadcrumb->name ?></a></li>
                                    <?php }
                                } ?>
                            </ol>
                        </nav>
                    </div>

                    <div class="col-6 clearfix text-end" style="padding-bottom: 2px; padding-top: 10px;">
                        <form class="float-end row row-cols-lg-auto g-3 align-items-center" method="post" action="<?= url_to('searchCreate') ?>" role="search">
                            <input type="hidden" name="data[access_token]" value="<?= $meta->access_token; ?>">
                            <input type="hidden" name="data[attributes][tables]"  value='["devices"]'>
                            <input type="hidden" name="data[attributes][columns]" value='["name","ip","hostname","domain","dns_hostname","dns_domain","sysName"]'>
                            <?php if (!empty($user->permissions['devices']) and str_contains($user->permissions['devices'], 'r')) { ?>
                                 <div class="col-12">
                                    <label class="visually-hidden" for="data[attributes][value]"><?= __('Search') ?></label>
                                    <div class="input-group input-group-sm">
                                        <input type="text" style="margin-right:2px;" class="form-control" name="data[attributes][value]" placeholder="<?= __('Device Name') ?> <?= __('or') ?> IP">
                                        <button type="submit" style="margin-left:2px;" class="btn btn-sm btn-primary rounded" title="<?= __('Search') . ' ' . __('Devices') ?>"><?= __('Search') ?></button>
                                    </div>
                                </div>
                                <?php if ($meta->collection === 'dashboards' and $meta->action === 'execute') { ?>
                                    <div class="col-12">
                                <?php } ?>
                                <?php if ($meta->collection === 'dashboards' and $meta->action === 'execute' and $meta->id != $user->dashboard_id) { ?>
                                        <button class="btn btn-sm btn-outline-secondary" id="make_my_dashboard_button" title="<?= __('Make My Default Dashboard') ?>" type="button" aria-expanded="false"><span class="icon-house"></span></button>
                                <?php } ?>

                                <?php if ($meta->collection === 'dashboards' and $meta->action === 'execute' and str_contains($user->permissions['devices'], 'u') and $meta->id !== 7) { ?>
                                        <a href="<?= url_to('dashboardsRead', $meta->id) ?>" class="btn btn-sm btn-outline-secondary" title="<?= __('Edit') ?>" type="button" aria-expanded="false"><span class="icon-pencil"></span></a>
                                <?php } ?>
                                <?php if ($meta->collection === 'dashboards' and $meta->action === 'execute') { ?>
                                    </div>
                                <?php } ?>
                            <?php } ?>
                        </form>
                    </div>
                </div>
            <br>
        </div>

        <?php if (!empty($config->server_os) and $config->server_os === 'Windows NT' and !stripos($config->server_platform, 'server')) { ?>
        <div class="container-fluid">
            <div class="alert alert-danger alert-dismissable fade show" role="alert">
                Warning - Running <?= esc(APP_DISPLAY_NAME) ?> on Windows on a non-server OS will cause discoveries to fail. Please install on Windows Server. More information <a href="<?= url_to('helpFAQ') ?>?name=Windows Server">here</a>.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </div>
        <?php } ?>


        <?php
        if (!empty($news->id)) {
            $alert = !empty($news->alert_style) ? $news->alert_style : 'info';

            if (!empty($news->name) and !empty($news->short)) {
                $title = $news->name . ' :: ' . $news->short;
            } else if (!empty($news->name)) {
                $title = $news->name;
            } else if (!empty($news->short)) {
                $title = $news->short;
            }
            ?>
            <div class="container-fluid">
                <div class="alert alert-<?= $alert ?> alert-dismissable fade show" role="alert">
                    <?= $title ?><?= $news->link ?>
                </div>
            </div>
        <?php } ?>




        <?php if (!empty($_SESSION['error'])) {
            try {
                $json = json_decode($_SESSION['error'], false, 512, JSON_THROW_ON_ERROR);
            } catch (\JsonException $e) {
                $_SESSION['error'] = (string)$_SESSION['error'];
            } ?>
        <div class="container-fluid">
            <div class="alert alert-danger alert-dismissable fade show" role="alert">
                <?php if (!empty($json)) {?>
                    <?= 'Message: ' . $json->message . '<br>SQL: ' . $json->sql ?>
                <?php } else { ?>
                    <?= $_SESSION['error'] ?>
                <?php } ?>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </div>
            <?php unset($_SESSION['error']); ?>
        <?php } ?>
        <?php if (!empty($_SESSION['warning'])) { ?>
        <div class="container-fluid">
            <div class="alert alert-warning alert-dismissible fade show" role="alert">
                <?= $_SESSION['warning'] ?>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </div>
            <?php unset($_SESSION['warning']); ?>
        <?php } ?>
        <?php if (!empty($_SESSION['success'])) { ?>
        <div class="container-fluid">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <?= $_SESSION['success'] ?>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </div>
            <?php unset($_SESSION['success']); ?>
        <?php } ?>

        <!-- Toasts -->
        <?php
        $extra = 'Please download ' . APP_DISPLAY_NAME . ' from <a target="_blank" href="' . APP_VENDOR_URL . '">' . APP_VENDOR_NAME . '</a> to access a free license and additional functionality.';
        $license = (!empty($config->license)) ? strtolower($config->license) : 'none';
        if ($license !== 'commercial' and (is_file(ROOTPATH . 'other/enterprise.bin') or is_file(ROOTPATH . 'other/enterprise.exe'))) {
            $extra = 'For a free license, click <a href="#" data-bs-toggle="modal" data-bs-target="#modalCompareLicense">here</a>.';
        }
        ?>
        <div aria-live="polite" aria-atomic="true" class="position-relative">
            <div class="toast-container top-0 end-0 p-3">
                <div class="toast toast-ent" role="alert" aria-live="assertive" aria-atomic="true" id="liveToastEnterprise">
                    <div class="toast-header">
                        <strong class="me-auto">Enterprise Feature</strong>
                        <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close" style="padding-top:34px; padding-right:50px;"></button>
                    </div>
                    <div class="toast-body">
                        This feature is limited to Enterprise licenses only. <?= $extra ?>
                    </div>
                </div>
                <div class="toast toast-pro" role="alert" aria-live="assertive" aria-atomic="true" id="liveToastProfessional">
                    <div class="toast-header">
                        <strong class="me-auto">Professional Feature</strong>
                        <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close" style="padding-top:34px; padding-right:50px;"></button>
                    </div>
                    <div class="toast-body">
                        This feature is limited to Professional licenses only. <?= $extra ?>
                    </div>
                </div>
                <div class="toast toast-perm" role="alert" aria-live="assertive" aria-atomic="true" id="liveToastPermission">
                    <div class="toast-header">
                        <strong class="me-auto">Not Authorized</strong>
                        <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close" style="padding-top:34px; padding-right:50px;"></button>
                    </div>
                    <div class="toast-body">
                        Your user account does not have permission to perform this function.
                    </div>
                </div>
                <div class="toast toast-success" role="alert" aria-live="assertive" aria-atomic="true" id="liveToastSuccess">
                    <div class="toast-header">
                        <strong id="liveToastSuccess-header" class="me-auto"></strong>
                        <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close" style="padding-top:34px; padding-right:50px;"></button>
                    </div>
                    <div class="toast-body" id="liveToastSuccess-body">
                    </div>
                </div>
                <div class="toast toast-failure" role="alert" aria-live="assertive" aria-atomic="true" id="liveToastFailure">
                    <div class="toast-header">
                        <strong id="liveToastFailure-header" class="me-auto"></strong>
                        <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close" style="padding-top:34px; padding-right:50px;"></button>
                    </div>
                    <div class="toast-body" id="liveToastFailure-body">
                    </div>
                </div>
            </div>
        </div>

<?php
function menuItem($collection = '', $permission = '', $user = null, $route = '', $title = '', $routeExtra = '')
{
    if (empty($permission)) {
        $instance = & get_instance();
        if (!empty($instance->collections->{$collection}) && empty($instance->collections->{$collection}->actions->{$instance->config->product})) {
            return '';
        }
        return "<li><a class=\"dropdown-item\" href=\"" . url_to($route) . "{$routeExtra}\">" . $title . "</a></li>\n";
        log_message('error', "menuItem, nothing in permission.");
    }
    $instance = & get_instance();
    // Default to no access
    $return = "<li><a class=\"dropdown-item greyout toastPermission\" href=\"#\">" . $title . "</a></li>\n";
    if (empty($instance->collections->{$collection})) {
        log_message('error', "menuItem, nothing in instance->collections->{$collection}.");
        return '';
    }
    if (!isset($instance->collections->{$collection}->actions->{$instance->config->product})) {
        log_message('error', "menuItem, nothing in instance->collections->{$collection}->actions->{$instance->config->product}.");
        return '';
    }
    $productActions = $instance->collections->{$collection}->actions->{$instance->config->product};
    if (!str_contains($productActions, $permission)) {
        return '';
    }
    if (empty($instance->resp->meta->permission_requested)) {
        // log_message('error', "menuItem, no permission requested for " . $collection);
        return $return;
    }
    // Check if feature matches license
    if (!str_contains($instance->collections->{$collection}->actions->{$instance->config->product}, $instance->resp->meta->permission_requested[$instance->resp->meta->action])) {
        $return = "<li><a class=\"dropdown-item greyout toast" . $instance->collections->{$collection}->edition . "\" href=\"#\">" . $title . "</a></li>\n";
    }
    // Check if user has permission and a license
    if (str_contains($instance->collections->{$collection}->actions->{$instance->config->product}, $instance->resp->meta->permission_requested[$instance->resp->meta->action])) {
        if (get_user_permission($collection, $permission, $user)) {
            $return = "<li><a class=\"dropdown-item\" href=\"" . url_to($route) . "{$routeExtra}\">" . $title . "</a></li>\n";
        }
    }
    return $return;
}

function get_user_permission($collection, $action, $user)
{
    if (!empty($user->permissions[$collection]) and str_contains($user->permissions[$collection], $action)) {
        return true;
    }
    return false;
}
