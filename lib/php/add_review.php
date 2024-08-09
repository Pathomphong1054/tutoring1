<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tutoring_app";

// Create connection
$con = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($con->connect_error) {
    die("Connection failed: " . $con->connect_error);
}

$data = json_decode(file_get_contents('php://input'), true);
$tutor_name = $data['tutor_name'];
$rating = $data['rating'];
$comment = $data['comment'];

$sql = "INSERT INTO reviews (tutor_name, rating, comment) VALUES ('$tutor_name', '$rating', '$comment')";

$response = array();

if ($con->query($sql) === TRUE) {
    $response['status'] = 'success';
    $response['message'] = 'Review added successfully';
} else {
    $response['status'] = 'error';
    $response['message'] = 'Error: ' . $sql . '<br>' . $con->error;
}

$con->close();

echo json_encode($response);
?>
