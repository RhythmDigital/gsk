<?php
$con=mysql_connect($host, $user, $pass);
	mysql_select_db($db) or die(mysql_error());

	if (!$con) {
		echo "result=db_connect_error";
   		die();
	}

	$session_id = findSessionID($_GET['session_id']);

	if(!isset($session_id)) {
		mysql_query("INSERT INTO sessions (session_id) VALUES ('".$_GET['session_id']."')");
	}
	
	mysql_query("INSERT INTO stats (session_id, page, action, time) VALUES ('".$_GET['session_id']."','".$_GET['page']."','".$_GET['action']."',NOW())");


	if($_GET['action'] == "end") {
		mysql_query("UPDATE sessions SET session_length='".$_GET['sessionDuration']."'' WHERE session_id='".$_GET['session_id']."'");
	}

	mysql_close($con);
?>