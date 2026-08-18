<?php
# Copyright © 2023 FirstWave. All Rights Reserved.
# SPDX-License-Identifier: AGPL-3.0-or-later
include 'shared/collection_functions.php';
?>
        <main class="container-fluid">
            <div class="card">
                <div class="card-header">
                    <div class="row">
                        <div class="col-4 clearfix">
                                <h5 class="mt-2" style="padding-top:10px;"><span class="icon-layers-2 oa-icon"></span><?= __('Resources') ?></h5>
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <div class="row">
                    <?php
                    $i = 0;
                    foreach ($included['collections'] as $name => $collection) {
                        if ($name === 'collectors' and $collection->count === 0) {
                            continue;
                        }
                        if ($collection->edition !== 'Community') {
                            continue;
                        }
                        $i++;
                        $color = 'darkgrey';
                        $link = '#';
                        $pill = 'background:dimgrey';
                        $badge = 'color: RGBA(108, 117, 125, var(--bs-bg-opacity, 1)) !important;';
                        $toast = 'toast' . $collection->edition;
                        if ($collection->edition === 'Community') {
                            $link = url_to($name . 'Collection');
                            $color = 'dimgrey';
                            $pill = 'background:#3bafda';
                            $badge = 'color:#3bafda;';
                            $toast = '';
                        }
                        if ($collection->edition === 'Professional' and $config->product === 'professional' or $config->product === 'enterprise') {
                            $link = url_to($name . 'Collection');
                            $color = 'dimgrey';
                            $pill = 'background:#3bafda';
                            $badge = 'color:#3bafda;';
                            $toast = '';
                        }
                        if ($collection->edition === 'Enterprise' and $config->product === 'enterprise') {
                            $link = url_to($name . 'Collection');
                            $color = 'dimgrey';
                            $pill = 'background:#3bafda';
                            $badge = 'color:#3bafda;';
                            $toast = '';
                        }
                        if ($collection->name === 'Discovery Log') {
                            $link = 'discoveries';
                        }
                        if ($collection->name === 'Baselines Policies') {
                            $collection->name = 'Base Policies';
                        }
                        if ($collection->name === 'Baselines Results') {
                            $collection->name = 'Base Results';
                        }
                        if ($collection->name === 'Discovery Scan Options') {
                            $collection->name = 'Scan Options';
                        }
                        ?>
                        <div class="col-lg-1 text-center">
                            <div>
                                <a href="<?= $link ?>" class="position-relative <?= $toast ?>">
                                    <img style="width:4rem;" class="img-responsive center-block" src="<?= $meta->baseurl ?>icons/<?= $name ?>.svg" alt="<?= $name ?>">
                                    <br><?= __($collection->name) ?>
                                    <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill" style="<?= $pill ?>"><?= $collection->count ?></span>
                                </a>
                            </div>
                        </div>
                        <?php
                        if ($i === 12 or $i === 24 or $i === 36) {
                            echo "</div><br><div class=\"row\">";
                        }
                    }
                    ?>
                    </div>
                </div>
            </div>
            <br>


            <div class="card">
                <div class="card-header">
                    <div class="row">
                        <div class="col-4 clearfix">
                                <h5 class="mt-2" style="padding-top:10px;"><span class="icon-layers-2 oa-icon"></span><?= __('Admin Resources') ?></h5>
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <div class="row">
                    <?php
                    $i = 0;
                    foreach ($included['admin_collections'] as $name => $collection) {
                        if ($name === 'collectors' and $collection->count === 0) {
                            continue;
                        }
                        if ($collection->edition !== 'Community') {
                            continue;
                        }
                        $i++;
                        $color = 'darkgrey';
                        $link = '#';
                        $pill = 'background:dimgrey';
                        $badge = 'color: RGBA(108, 117, 125, var(--bs-bg-opacity, 1)) !important;';
                        $toast = 'toast' . $collection->edition;
                        if ($collection->edition === 'Community') {
                            $link = url_to($name . 'Collection');
                            $color = 'dimgrey';
                            $pill = 'background:#3bafda';
                            $badge = 'color:#3bafda;';
                            $toast = '';
                        }
                        if ($collection->edition === 'Professional' and $config->product === 'professional' or $config->product === 'enterprise') {
                            $link = url_to($name . 'Collection');
                            $color = 'dimgrey';
                            $pill = 'background:#3bafda';
                            $badge = 'color:#3bafda;';
                            $toast = '';
                        }
                        if ($collection->edition === 'Enterprise' and $config->product === 'enterprise') {
                            $link = url_to($name . 'Collection');
                            $color = 'dimgrey';
                            $pill = 'background:#3bafda';
                            $badge = 'color:#3bafda;';
                            $toast = '';
                        }
                        if ($collection->name === 'Discovery Log') {
                            $link = 'discoveries';
                        }
                        if ($collection->name === 'Baselines Policies') {
                            $collection->name = 'Base Policies';
                        }
                        if ($collection->name === 'Baselines Results') {
                            $collection->name = 'Base Results';
                        }
                        if ($collection->name === 'Discovery Scan Options') {
                            $collection->name = 'Scan Options';
                        }
                        ?>
                        <div class="col-lg-1 text-center">
                            <div>
                                <a href="<?= $link ?>" class="position-relative <?= $toast ?>">
                                    <img style="width:4rem;" class="img-responsive center-block" src="<?= $meta->baseurl ?>icons/<?= $name ?>.svg" alt="<?= $name ?>">
                                    <br><?= __($collection->name) ?>
                                    <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill" style="<?= $pill ?>"><?= $collection->count ?></span>
                                </a>
                            </div>
                        </div>
                        <?php
                        if ($i === 12 or $i === 24 or $i === 36) {
                            echo "</div><br><div class=\"row\">";
                        }
                    }
                    ?>
                    </div>
                </div>
            </div>
        </main>
