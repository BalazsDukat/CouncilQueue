<?php
function add_entry()
{ $connectdb = new mysqli("localhost","root","usbw","councilqueue"); //I used USB Webserver, change these credentials as needed.
	if($connectdb -> connect_error)
	{die($connectdb -> connect_error);
	} //checking connection
	
	$type = NULL;
	$fname = NULL;
	$lname = NULL;
	$org = NULL;
	$serv = NULL;
	
	if(isset($_POST["in_type_set"])) $type = $_POST["in_type_set"];
	if(isset($_POST["firstName"])) $fname = $_POST["firstName"];
	if(isset($_POST["lastName"])) $lname = $_POST["lastName"];
	if(isset($_POST["organization"])) $org = $_POST["organization"];
	if(isset($_POST["service"])) $serv = $_POST["service"];

	$statement = $connectdb -> prepare("CALL add_new_person(?,?,?,?,?,@ern,@ers)");
	$statement -> bind_param("sssss",$type,$fname,$lname,$org,$serv);
	
	
	if(!$statement -> execute()) echo "<br>Execute failed: (" . $statement -> errno . ") " . $statement -> error; 
	//else echo "<br>success ";
	
	//echo "<br>output: ";
	
	$select_out = mysqli_query($connectdb, 'SELECT @ern,@ers');
	$result =  mysqli_fetch_assoc($select_out);
	$ern = $result['@ern'];
	$ers = $result['@ers'];
	echo $ern . " " . $ers;
	
	$statement -> close();
	
  $connectdb -> close();
}

if(isset($_POST["in_type_set"]) AND isset($_POST["service"])) add_entry();
//add_entry('Citizen', 'Jack', 'Sparrow', 'Pirates', 'Benefits', @e, @es);
?>