<?php

$lng     = $_GET['lng'];
$msg     = $_GET['msg'];

$filewav = "tts.wav";
$filemp3 = "tts.mp3";

require 'vendor/autoload.php';

use Lame\Lame;
use Lame\Settings;

// perform TTS using pico2wave
try {
    exec('/usr/bin/pico2wave -l=' . $lng . ' -w=' . $filewav . ' "' . $msg . '"');
} catch(\RuntimeException $e) {
    var_dump($e->getMessage());
}

// encoding type
$encoding = new Settings\Encoding\Preset();
$encoding->setType(Settings\Encoding\Preset::TYPE_STANDARD);

// lame settings
$settings = new Settings\Settings($encoding);

// lame wrapper
$lame = new Lame('/usr/bin/lame', $settings);

// convert wav - mp3 using lame
try {
    $lame->encode($filewav, $filemp3);
} catch(\RuntimeException $e) {
    var_dump($e->getMessage());
}

// send the converted mp3 back to the client
if(file_exists($filemp3)) {
    header('Content-Transfer-Encoding: binary');
    header('Content-Type: audio/mpeg');
    header('Content-length: ' . filesize($filemp3));
    header('Content-Disposition: filename=' . $filemp3);
    header('Cache-Control: no-cache');
    header('icy-br: 64');
    header('icy-name: TTS Announcement');
    readfile($filemp3);
} else {
    header("HTTP/1.0 404 Not Found");
}

?>
