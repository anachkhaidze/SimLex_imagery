<?php
// Report all PHP errors (see changelog)
error_reporting(E_ALL);
ini_set('display_errors', '1');

// get the data from the POST message
$postData = file_get_contents('php://input');
$data = json_decode($postData, true); // Decode JSON to array

// Check if the decode was successful
if (json_last_error() !== JSON_ERROR_NONE) {
    die("JSON decoding error: " . json_last_error_msg());
}

// Check if data is an array and not empty
if (!is_array($data) || empty($data)) {
    die("No data received or data is not an array.");
}

// Check if filename is set
if (!isset($data['filename'])) {
    die("Filename is not set.");
}

$filename = basename($data['filename']);

// Specify the directory where files should be saved
$dirPath = __DIR__ . '/data';

// Check if directory exists
if (!file_exists($dirPath)) {
    die("The directory does not exist.");
}

// Check if directory is writable
if (!is_writable($dirPath)) {
    die("The directory is not writable.");
}

// Specify the file path
$filePath = $dirPath . '/' . $filename;

// Unset the filename to prevent it from being saved inside the file data
unset($data['filename']);

// Convert the array back to JSON
$reshapedData = json_encode($data, JSON_PRETTY_PRINT);

// Attempt to write the JSON data to the file
$result = file_put_contents($filePath, $reshapedData);

// Check if the write was successful
if ($result === false) {
    die("Failed to write data to file. Error: " . error_get_last()['message']);
}

echo "Data written to file successfully.";
?>
