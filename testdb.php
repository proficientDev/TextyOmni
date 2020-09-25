<?php

$dbhost = 'localhost';
$dbport = '5432';
$dbname = 'chatwoot_dev';
$dbuser = 'chatwoot';
$dbpass = 'NUsD1ntZhTlubgM';

$chatwoot_token = 'echCJhSwLGKVxESpnEgPwBqr';
$chatwoot_url = 'https://chat.textymedia.com';

$inbox_id     = 3;      
$account_id   = 1;      

try{
    $db = new PDO('pgsql:host='.$dbhost.';port='.$dbport.';dbname='.$dbname, $dbuser, $dbpass);  
}
catch (PDOException $e) {
    error_log($e->getMessage(), 0);
    print_r($e->getMessage());
}

?>
