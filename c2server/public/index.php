<?php
    use Helzie\Http\Response;
    
    return Response::Throw(state: 404, body: [
        "why"   => "Unknown Method",
    ]);
?>
