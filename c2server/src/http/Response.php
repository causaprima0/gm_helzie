<?php
    namespace Helzie\Http;

    class Response {
        private const STD_DEFAULT_STATE     = 200;
        private const STD_RESPONSE_FLAG     = "response";
        private const STD_ERROR_FLAG        = "error";

        private const JSON_ENCODE_BITS      = (JSON_UNESCAPED_UNICODE);

        public static function Throw(int $state = 200, mixed $body = []): mixed {
            header("Content-Type: application/json");
            http_response_code($state);

            return die(json_encode(array(
                (($state === self::STD_DEFAULT_STATE)
                    ? self::STD_RESPONSE_FLAG
                    : self::STD_ERROR_FLAG) => $body,
            ), self::JSON_ENCODE_BITS));
        }
    }
?>
