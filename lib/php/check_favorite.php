<?php
// Database connection
include 'db_connection.php';

// Check request method
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Retrieve POST data
    $student_id = $_POST['student_id'];
    $tutor_id = $_POST['tutor_id'];

    // Validate input
    if (empty($student_id) || empty($tutor_id)) {
        echo json_encode(['status' => 'error', 'message' => 'Student ID and Tutor ID are required']);
        exit();
    }

    // Prepare and execute SQL query
    $query = "SELECT COUNT(*) AS count FROM favorites WHERE student_id = ? AND tutor_id = ?";
    if ($stmt = $con->prepare($query)) {
        $stmt->bind_param('ii', $student_id, $tutor_id);
        $stmt->execute();
        $result = $stmt->get_result();
        $data = $result->fetch_assoc();
        $isFavorite = $data['count'] > 0;
        echo json_encode(['status' => 'success', 'is_favorite' => $isFavorite]);
        $stmt->close();
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to prepare statement']);
    }

    // Close connection
    $con->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}
?>
