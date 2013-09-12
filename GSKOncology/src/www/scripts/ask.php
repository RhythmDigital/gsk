<?php
	//$to = "jamie@wehaverhythm.com";
	$name = urldecode($_POST['name']);
	$from = urldecode($_POST['email']);
	$subject = "GSK Oncology Question Regarding: ".urldecode($_POST['product']);
	$message = urldecode($_POST['message']);
	
	$headers = "From: ".$name."<".$from.">\r\n";
	$headers .= "Reply-To: ".$from."\r\n";
	$headers .= "MIME-Version: 1.0\r\n";
	$headers .= "Content-Type: text/html; charset=ISO-8859-1\r\n";

	$result = mail ("hello@jamie-white.com", $subject, $message, $headers);
	

	// WRITE TO DB.


	if($result) {
		echo "result=ok";
	} else {
		echo "result=error";
	}


	function writeQuestionTODB($product, $name, $email, $message) {
		$con=mysqli_connect("localhost","peter","abc123","my_db");
		// Check connection
		if (mysqli_connect_errno())
		  {
		  echo "Failed to connect to MySQL: " . mysqli_connect_error();
		  }

		mysqli_query($con,"INSERT INTO Persons (FirstName, LastName, Age)
		VALUES ('Peter', 'Griffin',35)");

		mysqli_query($con,"INSERT INTO Persons (FirstName, LastName, Age) 
		VALUES ('Glenn', 'Quagmire',33)");

		mysqli_close($con);
	}
?>