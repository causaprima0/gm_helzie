<?php
    foreach(new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator(__DIR__)
    ) as $file) {
        if ($file->getFilename() !== "autoload.php") {
            if ($file->getExtension() == "php") {
                require_once($file->getPath() . "/" . $file->getFilename());
            }
        }
    }
?>
