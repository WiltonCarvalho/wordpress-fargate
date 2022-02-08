<?php
    require '/var/www/composer/vendor/autoload.php';
    use Aws\SecretsManager\SecretsManagerClient;
    $client = new SecretsManagerClient(['version'=>'2017-10-17','region'=>$_SERVER["AWS_REGION"]]);
    $result = $client->getSecretValue(['SecretId'=>$_SERVER["AWS_SECRETS_NAME"]]);
    $values = json_decode($result['SecretString'],true);
    $dbuser = $values["username"];
    $dbpass = $values["password"];
    //$dbuser = $_SERVER["DB_USER"];
    //$dbpass = $_SERVER["DB_PASS"];
    $dbhost = $_SERVER["DB_HOST"];
    $dbname = $_SERVER["DB_NAME"];
	$conn = mysqli_connect("$dbhost", "$dbuser", "$dbpass");
    //$sql = "show status like '%onn%'";
    $sql = "show processlist";
    if (!$conn) {
        die();
    }
    if ($conn) {
        printf("%s\n", mysqli_stat($conn));
        $query = mysqli_query($conn, $sql);
        printf("Select returned %d rows.\n", $query->num_rows);
        while ($row = mysqli_fetch_assoc($query)){
            printf("%s\t%s\t%s\n", "Id", "User", "Host");
            printf("%s\t%s\t%s\n", $row["Id"], $row["User"], $row["Host"]);
        }
        mysqli_close($conn);
    }
?>
