<?php
	include "config.php";

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

	mysql_close($con);
	
 	echo "result=db_tracking_ok";

 	function findSessionID($session_id) {
		$session_id_query = mysql_query("SELECT * FROM sessions WHERE session_id='".$session_id."'");
		$id;

		while($row = mysql_fetch_array($session_id_query)) {
			$id = $row['session_id'];
			return $id;
		}

		return $id;
	}
?>