<!DOCTYPE html>
<html>

<head>
<?php 
require "add_new_person.php";
require "get_queue.php";
?>

<title>View queue and add to queue</title>

<link rel="stylesheet" type="text/css" href="firmstep_test.css">

<script type="text/javascript">
	function add_new() 
	{document.add_new.submit();
	}
	function show() 
	{document.show_q.submit();
	}
</script>

</head>

<body>
<h1>Test interface</h1><br>

<form id = 'add_new' name = 'add_new' method = 'POST'>
<button id = "add" name = "add" onclick = "add_new()">Add to queue</button> (Please do not press F5/refresh.)<br><br>
  Type:
  <select id = "in_type_set" name = "in_type_set">
		<option value = "Citizen">Citizen</option>
		<option value = "Anonymous">Anonymous</option>
  </select><br><br>
  First name:
  <input type="text" name="firstName" value=""><br><br>
  Last name:
  <input type="text" name="lastName" value=""><br><br>
  Organization:
  <input type="text" name="organization" value=""><br><br>
  Service:
  <select id = "service" name = "service">
		<option value = ""></option>
		<option value = "Council Tax">Council Tax</option>
		<option value = "Benefits">Benefits</option>
		<option value = "Rent">Rent</option>
  </select><br><br>
  <br><br>
</form>


Below is the queue JSON string:<br>
<form id = 'show_q' name = 'show_q' method = 'GET'>
	<select id = "in_type" name = "in_type" onchange = "show()">
		<option value = ""></option>
		<option value = "Citizen">Citizen</option>
		<option value = "Anonymous">Anonymous</option>
		<option value = "">All</option>
	</select> 
<!-- <button id = "show" name = "show" onclick = "show_q()">Display queue</button> -->
</form>
<br>
<div id = "result_json"> 
<?php if(isset($_GET['in_type'])) 
{get_queue(); 
}
else echo "No type selected yet."; 
?>
</div>

</body>
</html>