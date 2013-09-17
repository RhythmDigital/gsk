<?php
	
	$host = "localhost";//:3306";
	$db = "gsk_downloads";
	$user = "gsk_downloads";
	$pass = "gOoFu1(97Ny8rd8";

	$con=mysqli_connect($host, $db, $user $pass);

	/*
	if (mysqli_connect_errno())
	{
	  echo "result=db_connect_error";
	  echo "result=failed";
	  die();
	}*/
	
	/*
	mysqli_query($con,"INSERT INTO stats (session_id,page,action,time) VALUES ('".$_GET['session_id']."','".$_GET['page']."','".$_GET['action']."',NOW())");
	mysqli_close($con);
	*/

 	echo "result=ok";
?>