<?php
// Database connection
include 'db_connection.php';

// Check request method
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Retrieve POST data
    $student_id = $_POST['student_id'];
    $tutor_id = $_POST['tutor_id'];
    $action = $_POST['action'];

    // Validate input
    if (empty($student_id) || empty($tutor_id) || empty($action)) {
        echo json_encode(['status' => 'error', 'message' => 'Student ID, Tutor ID, and action are required']);
        exit();
    }

    // Check if the action is to add or remove favorite
    if ($action == 'add') {
        // Prepare and execute SQL query to add favorite
        $query = "INSERT INTO favorites (student_id, tutor_id) VALUES (?, ?)";
        if ($stmt = $con->prepare($query)) {
            $stmt->bind_param('ii', $student_id, $tutor_id);
            if ($stmt->execute()) {
                echo json_encode(['status' => 'success']);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Failed to add favorite']);
            }
            $stmt->close();
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Failed to prepare statement']);
        }
    } elseif ($action == 'remove') {
        // Prepare and execute SQL query to remove favorite
        $query = "DELETE FROM favorites WHERE student_id = ? AND tutor_id = ?";
        if ($stmt = $con->prepare($query)) {
            $stmt->bind_param('ii', $student_id, $tutor_id);
            if ($stmt->execute()) {
                echo json_encode(['status' => 'success']);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Failed to remove favorite']);
            }
            $stmt->close();
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Failed to prepare statement']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
    }

    // Close connection
    $con->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}
exit();
?>
