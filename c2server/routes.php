<?php
    require_once __DIR__."/src/autoload.php";

    use Helzie\Http\Router;

    Router::Create("POST", "/v1/forwarder.forward", "public/forwarder/forward.php");
    Router::Create("*", "/404", "public/index.php");
?>
