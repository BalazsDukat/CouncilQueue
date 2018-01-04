<?php
function get_queue()
{ $connectdb = new mysqli("localhost","root","usbw","councilqueue"); //I used USB Webserver, change these credentials as needed.
	if($connectdb -> connect_error)
	{die($connectdb -> connect_error);
	} //checking connection
	
	if(isset($_GET["in_type"])) 
	{$in = $_GET["in_type"];
	//echo $_GET["in_type"];
	}
	else 
	{$in = NULL;
	//echo "not set";
	}
	
	$statement = $connectdb -> prepare("CALL get_queue_entries(?,@outparam)");
	$statement -> bind_param("s",$in);
	
	
	if(!$statement -> execute()) echo "<br>Execute failed: (" . $statement -> errno . ") " . $statement -> error; 
	//else echo "<br>success ";
	
	//echo "<br>output: ";
	
	$select_out = mysqli_query($connectdb, 'SELECT @outparam');
	$result =  mysqli_fetch_assoc($select_out);
	$out = $result['@outparam'];
	echo $out;
	
	$statement -> close();
	
  $connectdb -> close();
}

//get_queue();
?>