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

// Presets
$name         = 'Inbound SMS';
$email        = '';
$phone_number = '18585551001';
$messageIn = 'Test Successful!';

	
 
$query = $phone_number;
$contact = search_contact($account_id, $query);
	
  if(count($contact->payload) > 0) {

    $contact_id = $contact->payload[0]->id;
    $source_id = $contact->payload[0]->contact_inboxes[0]->source_id;
	
    } else {

    $name = $phone_number;
    $contact_payload = create_contact($inbox_id, $account_id, $email, $name, $phone_number);
    $source_id = $contact_payload->payload[0]->contact_inboxes[0]->source_id;

    }


$sql = "SELECT * FROM conversations WHERE account_id = {$account_id} AND inbox_id = {$inbox_id} AND status != 1 AND contact_inbox_id = (SELECT id FROM contact_inboxes WHERE source_id = '{$source_id}')";
echo "\n\n\nSQL: ".$sql."\n\n\n";
$dbquery = $db->query($sql);
$result = $dbquery->fetchAll(PDO::FETCH_ASSOC);

$conversation_id = $result[0]['id'];
	
  if(count($result) > 0 ){
  
    // using $conversation_id above from sql query
    
    } else {

    $conversation_payload = create_conversation($account_id, $source_id);
    $conversation_id = $conversation_payload->id;

    }
	
// Create message
$create_message_payload = create_message($account_id, $conversation_id, $messageIn);



/**
 * Search Contact
 * 
 * @param
 * account_id   int     id of account // will be 2
 * query         string  query you want to search
 */
function search_contact($account_id, $query) {
    global $chatwoot_token, $chatwoot_url;
    $url = "{$chatwoot_url}/api/v1/accounts/{$account_id}/contacts/search?q={$query}";

    $options = array(
    'http' => array(
        'method'  => 'GET',
        // 'content' => json_encode( $data ),
        'header'=>  "Content-Type: application/json\r\n" .
                    "Accept: application/json\r\n" .
                    "api_access_token: {$chatwoot_token}"
        ),
    'ssl'=>array(
            "verify_peer"=>false,
            "verify_peer_name"=>false,
        ),
    );

    $context  = stream_context_create( $options );
    $result = file_get_contents( $url, false, $context );
    error_log("Contact: {$result}",0);
    $response = json_decode($result);
    print_r($response);
    return $response;
}

/**
 * Create a Contact
 * 
 * @param
 * inbox_id     int     inbox's id
 * account_id   int     account's id
 * name         string  name of contact you wanna create
 * email        string  email of contact you wanna create
 * phone_number string  phone number of contact you wanna create
 */
function create_contact($inbox_id, $account_id, $email, $name, $phone_number) {
    global $chatwoot_token, $chatwoot_url;
    $url = "{$chatwoot_url}/api/v1/accounts/{$account_id}/contacts";
    $data = array('inbox_id'        => $inbox_id,
                  'email'           => $email,
                  'name'            => $name,
                  'phone_number'    => $phone_number);

    $options = array(
    'http' => array(
        'method'  => 'POST',
        'content' => json_encode( $data ),
        'header'=>  "Content-Type: application/json\r\n" .
                    "Accept: application/json\r\n" .
                    "api_access_token: {$chatwoot_token}"
        ),
    'ssl'=>array(
            "verify_peer"=>false,
            "verify_peer_name"=>false,
        ),
    );

    $context  = stream_context_create( $options );
    $result = file_get_contents( $url, false, $context );
    error_log("Contact created: {$result}",0);
    $response = json_decode($result);
	print_r($response);
    return $response;
}

/**
 * Get a Contact
 * 
 * @param
 * account_id   int     account's id
 * contact_id   int     id of contact get from checking contact
 */
function get_contact($account_id, $contact_id) {
    global $chatwoot_token, $chatwoot_url;
    $url = "{$chatwoot_url}/api/v1/accounts/{$account_id}/contacts/{$contact_id}";

    $options = array(
    'http' => array(
        'method'  => 'GET',
        'header'=>  "Content-Type: application/json\r\n" .
                    "Accept: application/json\r\n" .
                    "api_access_token: {$chatwoot_token}"
        ),
    'ssl'=>array(
            "verify_peer"=>false,
            "verify_peer_name"=>false,
        ),
    );

    $context  = stream_context_create( $options );
    $result = file_get_contents( $url, false, $context );
    error_log("Contact: {$result}",0);
    $response = json_decode($result);
    print_r($response);
    return $response;
}

/**
 * Create Conversation
 * 
 * @param
 * account_id   int     account's id
 * source_id    string  Source's id you received from create_contact API
 */
function create_conversation($account_id, $source_id) {
    global $chatwoot_token, $chatwoot_url;
    $url = "{$chatwoot_url}/api/v1/accounts/{$account_id}/conversations";
    $data = array('source_id' => $source_id);

    $options = array(
    'http' => array(
        'method'  => 'POST',
        'content' => json_encode( $data ),
        'header'=>  "Content-Type: application/json\r\n" .
                    "Accept: application/json\r\n" .
                    "api_access_token: {$chatwoot_token}"
        ),
    'ssl'=>array(
            "verify_peer"=>false,
            "verify_peer_name"=>false,
        ),
    );

    $context  = stream_context_create( $options );
    $result = file_get_contents( $url, false, $context );
    error_log("Created Conversation: {$result}",0);
    $response = json_decode($result);
    print_r($response);
    return $response;
}

/**
 * Get Conversation
 * 
 * @param
 * account_id       int     account's id
 * conversation_id   int     id of conversation
 */
function get_conversation($account_id, $conversation_id) {
    global $chatwoot_token, $chatwoot_url;
    $url = "{$chatwoot_url}/api/v1/accounts/{$account_id}/conversations/{$conversation_id}";

    $options = array(
    'http' => array(
        'method'  => 'GET',
        'header'=>  "Content-Type: application/json\r\n" .
                    "Accept: application/json\r\n" .
                    "api_access_token: {$chatwoot_token}"
        ),
    'ssl'=>array(
            "verify_peer"=>false,
            "verify_peer_name"=>false,
        ),
    );

    $context  = stream_context_create( $options );
    $result = file_get_contents( $url, false, $context );
    error_log("Conversation: {$result}",0);
    $response = json_decode($result);
	print_r($response);
    return $response;
}

/**
 * Create Message
 */
function create_message($account_id, $conversation_id, $messageIn){
    global $chatwoot_url, $chatwoot_token; 
    $url = "{$chatwoot_url}/api/v1/accounts/{$account_id}/conversations/{$conversation_id}/messages";
    $data = array("content" => $messageIn, "message_type" => "incoming", "private" => false, "content_type" => "text",);
  
    $options = array(
    'http' => array(
        'method'  => 'POST',
        'content' => json_encode( $data ),
        'header'=>  "Content-Type: application/json\r\n" .
                    "Accept: application/json\r\n" .
                    "api_access_token: {$chatwoot_token}"
        ),
    'ssl'=>array(
          "verify_peer"=>false,
          "verify_peer_name"=>false,
      ),
    );
  
    $context  = stream_context_create( $options );
    $result = file_get_contents( $url, false, $context );
    error_log("chatwoot response: {$result}",0);
    $response = json_decode($result);
	print_r($response);
    return $result;
  }
	

?>