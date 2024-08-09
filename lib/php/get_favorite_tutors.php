<?php
include 'db_connection.php';

if (isset($_GET['student_id'])) {
    $student_id = $_GET['student_id'];

    // First query to get tutor IDs from favorites
    $sql = "SELECT tutor_id FROM favorites WHERE student_id = ?";
    $stmt = $con->prepare($sql);
    $stmt->bind_param("i", $student_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $tutorIds = [];
    while ($row = $result->fetch_assoc()) {
        $tutorIds[] = $row['tutor_id'];
    }

    // Check if there are any tutor IDs
    if (count($tutorIds) > 0) {
        // Convert the tutor IDs array to a comma-separated string for the SQL IN clause
        $tutorIdsStr = implode(',', array_fill(0, count($tutorIds), '?'));

        // Second query to get tutor details from tutors table
        $sql = "SELECT id, name, category, subject, profile_images FROM tutors WHERE id IN ($tutorIdsStr)";
        $stmt = $con->prepare($sql);

        // Bind the tutor IDs dynamically
        $types = str_repeat('i', count($tutorIds));
        $stmt->bind_param($types, ...$tutorIds);

        $stmt->execute();
        $result = $stmt->get_result();

        $tutorDetails = [];
        while ($row = $result->fetch_assoc()) {
            $tutorDetails[] = $row;
        }

        header('Content-Type: application/json');
        echo json_encode($tutorDetails);
    } else {
        echo json_encode([]);
    }
} else {
    echo json_encode(["error" => "student_id parameter is required"]);
}

$con->close();
?>
