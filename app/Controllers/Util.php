<?php

# Copyright © 2023 FirstWave. All Rights Reserved.
# SPDX-License-Identifier: AGPL-3.0-or-later

declare(strict_types=1);

namespace App\Controllers;

use CodeIgniter\API\ResponseTrait;
use CodeIgniter\Controller;

/**
 * PHP version 7.4
 *
 * @category  Controller
 * @package   Open-AudIT\Controller
 * @author    Mark Unwin <mark.unwin@firstwave.com>
 * @copyright 2023 FirstWave
 * @license   http://www.gnu.org/licenses/agpl-3.0.html aGPL v3
 * @version   GIT: Open-AudIT_6.0.4
 * @link      http://www.open-audit.org
 */

/**
 * Base Object Util
 *
 * @access   public
 * @category Object
 * @package  Open-AudIT\Controller\Util
 * @author   Mark Unwin <mark.unwin@firstwave.com>
 * @license  http://www.gnu.org/licenses/agpl-3.0.html aGPL v3
 * @link     http://www.open-audit.org
 */
class Util extends Controller
{
    use ResponseTrait;

    public function cloudServices($type)
    {
        $services = array();
        if ($type !== 'aws' and $type !== 'azure') {
            echo json_encode($services);
            return;
        }
        helper('utility');
        if ($type === 'aws') {
            $dir = '/usr/local/open-audit/public/aws_icons';
        }
        if ($type === 'azure') {
            $dir = '/usr/local/open-audit/public/azure_icons';
        }
        $services = getSVG($dir);
        return $this->setResponseFormat('json')->respond($services);
    }

    public function feeds()
    {
        helper('utility');
        $data = createNewsData();
        $data->devices = json_encode($data->devices);
        $data->issues = json_encode($data->issues);
        $data->features = json_encode($data->features);
        $data->products = json_encode($data->products);
        $data->stats = json_encode($data->stats);
        echo json_encode($data) . "\n";
        exit;
    }

    public function subnetSize()
    {
        // NOTE #1 - We cannot restrict the source (like the Google function below) because it is called from the client browser.
        // NOTE #2 - it would be nice do run the below, but unsure that Windows would handle 2>/dev/null
        // nmap -n -sL $subnet 2>/dev/null | grep "^Nmap done" | awk '{print $3}'
        $subnet = (!empty($_POST['subnet'])) ? $_POST['subnet'] : '';
        if (empty($subnet)) {
            return;
        }
        # filter out all characters not in the $chars list
        $chars = "0123456789-./";
        $pattern = "/[^" . preg_quote($chars, "/") . "]/";
        $subnet = preg_replace($pattern, '', $subnet);
        # now run the command
        $command = "nmap -n -sL " . $subnet;
        exec($command, $output, $return_var);
        $count = 0;
        if ($return_var === 0) {
            foreach ($output as $line) {
                if (stripos($line, 'Nmap scan report for') === 0) {
                    $count = $count + 1;
                }
            }
        }
        echo $count;
        return;
    }

    public function testWindowsClient()
    {
        $filename = ROOTPATH . 'other/test_windows_client.vbs';
        $file = file_get_contents($filename);
        // Set headers
        header('Cache-Control: public');
        header('Content-Description: File Transfer');
        header('Content-Disposition: attachment; filename=test_windows_client.vbs');
        header('Content-Type: text/plain');
        header('Content-Transfer-Encoding: binary');
        // echo our file contents
        echo $file;
    }
}
