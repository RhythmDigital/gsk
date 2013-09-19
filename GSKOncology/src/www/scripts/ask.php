<?php
	include "config.php";

	$to = "jamie@wehaverhythm.com";
	$name = urldecode($_POST['name']);
	$from = urldecode($_POST['email']);
	$product = urldecode($_POST['product']);
	$subject = "GSK Oncology Question Regarding: ".$product;
	$message = urldecode($_POST['message']);
	$sessionID = urldecode($_POST['sessionID']);
	$gskNoReply = "GSK ESMO 2013 <downloads-noreply@gsk-downloads.com>";
	

	$con=mysql_connect($host, $user, $pass);

	if (!$con) {
		echo "result=db_connect_error";
		die();
	}

	mysql_select_db($db) or die(mysql_error());

	// WRITE TO DB.
	mysql_query("INSERT INTO questions (name,email,message,brand,session_id,time) VALUES ('".$name."','".$from."','".$message."','".$product."',".$sessionID.",NOW())");
	mysql_close($con);
	
	$headers = "From: ".$gskNoReply."\r\n";
	$headers .= "Reply-To: ".$gskNoReply."\r\n";
	$headers .= "MIME-Version: 1.0\r\n";
	$headers .= "Content-Type: text/html; charset=ISO-8859-1\r\n";

	$emailMessage = "<b>Name: </b>".$name."<br/>";
	$emailMessage .= "<b>Email: </b>".$from."<br/><br/><br/>";
	$emailMessage .= "<b>Message: </b><br/><br/>".$message;

	$result = mail($to, $subject, $emailMessage, $headers);
	if($result) {
		echo "result=mail_ok";
	} else {
		echo "result=mail_error";
	}
?>