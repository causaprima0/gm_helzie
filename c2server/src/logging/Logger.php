<?php
    namespace Helzie\Logging;

    class Logger {
        public static function Log(string $str, string $suffix = null): void {
            $suffix = ($suffix ? ("." . $suffix) : "");
            $fn = sprintf("%s/logs/%s%s.log",
                $_SERVER["DOCUMENT_ROOT"],
                date("Y-m-d"),
                $suffix);

            @mkdir(dirname($fn), 0755, true);
            @file_put_contents($fn, sprintf("%s: %s\n",
                date("Y-m-d H:i:s"), $str), FILE_APPEND);
        }
    }
?>
