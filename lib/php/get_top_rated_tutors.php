<?php
require 'db_connection.php';

if ($con->connect_error) {
    die("Connection failed: " . $con->connect_error);
  }
  
  $sql = "
SELECT tutors.*, COALESCE(AVG(reviews.rating), 0) as average_rating
FROM tutors
LEFT JOIN reviews ON tutors.name = reviews.tutor_name
GROUP BY tutors.id
ORDER BY average_rating DESC";

$result = $con->query($sql);

$tutors = array();
if ($result->num_rows > 0) {
    // Output data of each row
    while($row = $result->fetch_assoc()) {
        $tutors[] = $row;
    }
} else {
    echo json_encode(array('status' => 'error', 'message' => 'No tutors found'));
    exit();
}

$con->close();

echo json_encode(array('status' => 'success', 'tutors' => $tutors));
?>
