<?php
	
	$con=mysqli_connect("localhost","root","root","gsk");

	if (mysqli_connect_errno())
	{
	  echo "result=db_connect_error";
	  echo "result=failed";
	  die();
	}

	mysqli_query($con,"INSERT INTO stats (session_id,page,action,time) VALUES ('".$_GET['session_id']."','".$_GET['page']."','".$_GET['action']."',NOW())");
	mysqli_close($con);
 	echo "result=ok";
?>