<?php
// // get the data from the POST message
$postData = file_get_contents('php://input');
$data = json_decode($postData, true); // Decode JSON to array

// Debugging: Inspect the structure of received data
echo '<pre>';
print_r($data);
echo '</pre>';

$filename = basename($data['filename']);

// Specify the file path using the sanitized filename
$filePath = "data/{$filename}";

// Convert the array (excluding the filename part) back to JSON before saving
unset($data['filename']); // Remove the filename from data to be saved
$jsonData = json_encode($data, JSON_PRETTY_PRINT);

// Write the JSON data to file
$result = file_put_contents($filePath, $jsonData);

if ($result === false) {
    echo "Error writing file";
} else {
    echo "File written successfully, filename: {$filename}";
}

?>