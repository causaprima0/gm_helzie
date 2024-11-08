<?php
    namespace Helzie\Http;

    class Router {
        public static function Create(
            string $method,
            string $route,
            string $path
        ) {
            if ($_SERVER["REQUEST_METHOD"] !== $method
                    && $method !== "*")
                return;

            $callback = $path;

            $path .= !is_callable($callback)
                    && !strpos($path, ".php")
                ? ".php"
                : "";

            if ($route === "/404" || $route === "std")
                die(include_once $_SERVER["DOCUMENT_ROOT"] . "/$path");

            $request_url = filter_var($_SERVER["REQUEST_URI"], FILTER_SANITIZE_URL);
            $request_url = rtrim($request_url, "/");
            $request_url = strtok($request_url, "?");

            $route_parts = explode("/", $route);
            $request_url_parts = explode("/", $request_url);

            array_shift($route_parts);
            array_shift($request_url_parts);

            if ($route_parts[0] === "" && count($request_url_parts) === 0) {
                if (is_callable($callback))
                    die(call_user_func_array($callback, []));
                die(include_once $_SERVER["DOCUMENT_ROOT"] . "/$path");
            }

            if (count($route_parts) !== count($request_url_parts))
                return;

            $parameters = [];

            for ($i = 0; $i < count($route_parts); $i++) {
                $route_part = $route_parts[$i];

                if (preg_match("/^[$]/", $route_part)) {
                    $route_part = ltrim($route_part, '$');
                    array_push($parameters, $request_url_parts[$i]);
                    $$route_part = $request_url_parts[$i];
                } elseif ($route_parts[$i] !== $request_url_parts[$i]) {
                    return;
                }
            }

            if (is_callable($callback))
                die(call_user_func_array($callback, $parameters));

            die(include_once $_SERVER["DOCUMENT_ROOT"] . "/$path");
        }
    }
?>
