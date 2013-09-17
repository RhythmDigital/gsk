<?php
	include "config.php";

	$to = urldecode($_POST['theirEmail']);
	$from = "noreply@gsk-downloads.com";
	$subject = "GSK Oncology Cart Email";
	$message = urldecode($_POST['theirMessage']);
	
	$headers = "From: " .$from. "\r\n";
	$headers .= "Reply-To: ".$from. "\r\n";
	$headers .= "MIME-Version: 1.0\r\n";
	$headers .= "Content-Type: text/html; charset=ISO-8859-1\r\n";
	$result = mail ($to, $subject, $message, $headers);
	
	if($result) {
		echo "result=ok";
	} else {
		echo "result=error";
	}
?>