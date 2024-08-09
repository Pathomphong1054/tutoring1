<?php
require 'db_connection.php';

header('Content-Type: application/json');

$recipient = $_GET['recipient'] ?? '';

if (empty($recipient)) {
    echo json_encode(['status' => 'error', 'message' => 'Recipient parameter is missing']);
    exit();
}

$roleQuery = "SELECT role FROM students WHERE name='$recipient'";
$roleResult = mysqli_query($con, $roleQuery);
$roleRow = mysqli_fetch_assoc($roleResult);
$role = $roleRow['role'];

if ($role == 'tutor') {
    $query = "
    SELECT requests.id, requests.sender, requests.recipient, requests.message, requests.created_at, students.profile_images as profile_image, requests.is_accepted 
    FROM requests 
    JOIN students ON requests.sender = students.name 
    WHERE recipient='$recipient'";
} else {
    $query = "
    SELECT requests.id, requests.sender, requests.recipient, requests.message, requests.created_at, tutors.profile_images as profile_image, requests.is_accepted 
    FROM requests 
    JOIN tutors ON requests.sender = tutors.name 
    WHERE recipient='$recipient'";
}

$result = mysqli_query($con, $query);

if (!$result) {
    echo json_encode(['status' => 'error', 'message' => mysqli_error($con)]);
    exit();
}

$requests = array();
while ($row = mysqli_fetch_assoc($result)) {
    $requests[] = [
        'id' => $row['id'],
        'sender' => $row['sender'],
        'recipient' => $row['recipient'],
        'message' => $row['message'],
        'profileImage' => $row['profile_image'],
        'created_at' => $row['created_at'],
        'is_accepted' => $row['is_accepted'],
    ];
}

echo json_encode(['status' => 'success', 'requests' => $requests]);
?>
