<?php

# Structure on the server (bradylab.ucsd.edu):
#
#  This file:
#    psyc241.ucsd.edu/Turk/save.php
#  Data gets saved in:
#    psyc241.ucsd.edu/Turk/data/{experimenter}/{experimentName}
#  Each subject gets saved using their id:
#	 psyc241.ucsd.edu/Turk/data/{experimenter}/{experimentName}/{id}.txt
#
# Warning:
# Note that this means that anybody can POST to this file directly and
# create files on your server. E.g., if somebody sends data to the URL
# psyc241.ucsd.edu/Turk/save.py?id=hello&experimentName=tim&curData=you+da+bomb,
# that will create a file on the server in the directory "data". So it isn't the
# safest thing in the world. It won't work if they load this directly in their
# browser because it needs to be POSTed and browsers use GET, but otherwise
# could be problematic.

# How to make this file work:
# Make sure php is enabled on your server. That's it.
# You might have to make your "data" folder writeable to the world:
# in terminal:
# sudo chmod -R 777 data 
# or via connecting to your server in some scpy client (like Transmit for app)
#

# You *should not* create the experimenter or experiment folders in advance.
# If you do, it might fail because the web server script won't have write
# access to those directories unless you set their permissions to 777.
#																  
	// get posted data
	$id = $_POST['id'];
	$experimenter = $_POST['experimenter'];
	$experimentName = $_POST['experimentName'];
	$curData = $_POST['curData'];
	
	// allow anyone to run this script from any server!
	// (could change to just mturk but for class debugging we'll leave it this way!)
	header('Access-Control-Allow-Origin: *'); 
	
	// setup directories:
	$dataDir="data/" . $experimenter . "/" . $experimentName . "/";

	// if experimenter isn't provided, get rid of extra "/":
	$dataDir=str_replace ("//", "/", $dataDir); 	

	// create directory if needed:
	if (!file_exists($dataDir)) {
    $didSucceed = mkdir($dataDir, 0777, true);
		if (!$didSucceed) {							
			header("HTTP/1.1 400 Bad Request");
		    exit();
		}
	}
	
	// check whether data file exists, if so, make unique name using uniqueid, which
	// gets a prefixed unique identifier based on the current time in microseconds.
	$fileName=$dataDir . "$id.txt";
	while (file_exists($fileName)) $fileName = $dataDir . "$id" . "_" . uniqid() . ".txt";
	
	// save file:
	if (file_put_contents($fileName,$curData)) {
		chmod($fileName, 0666);
		print_r("Success saving data!\n");
		print_r("fileName: $fileName \n");
		error_log('Error saving file: ' . error_get_last());
	} else {
		header("HTTP/1.1 400 Bad Request");
	}
	exit();
?>

