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

$tutor_name = $_GET['tutor_name'];

$sql = "SELECT * FROM reviews WHERE tutor_name = '$tutor_name'";
$result = $con->query($sql);

$response = array();
$response['status'] = 'success';
$response['reviews'] = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $review = array();
        $review['rating'] = $row['rating'];
        $review['comment'] = $row['comment'];
        $response['reviews'][] = $review;
    }
} else {
    $response['message'] = "No reviews found";
}

$con->close();

echo json_encode($response);
?>
