<?php
    namespace Helzie\Http;

    use Helzie\Http\Response;

    class Request {
        public static function Parse(string $option, bool $bRequired = false): mixed {
            $haystack = ($_SERVER["REQUEST_METHOD"] === "POST" ? $_POST : $_GET);
            $needle = @$haystack[$option];

            if (!$needle && $bRequired)
                return Response::Throw(state: 400, body: [
                    "why"   => "Bad Request",
                ]);

            return $needle;
        }
    }
?>
