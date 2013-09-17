<?php
	include "config.php";

	$to = "jamie@wehaverhythm.com";
	$name = urldecode($_POST['name']);
	$from = urldecode($_POST['email']);
	$product = urldecode($_POST['product']);
	$subject = "GSK Oncology Question Regarding: ".$product;
	$message = urldecode($_POST['message']);
	
	$headers = "From: GSK Oncology ESMO2013 <noreply@gsk-downloads.com>\r\n";
	$headers .= "Reply-To: ".$from."\r\n";
	$headers .= "MIME-Version: 1.0\r\n";
	$headers .= "Content-Type: text/html; charset=ISO-8859-1\r\n";

	$result = mail ($to, $subject, $message, $headers);

	

	// WRITE TO DB.
	writeQuestionToDB($product, $name, $from, $message);

	if($result) {
		echo "result=mail_ok";
	} else {
		echo "result=mail_error";
	}

	die();


	function writeQuestionToDB($con, $product, $name, $email, $message) {

		$con=mysqli_connect($host, $db, $user $pass);

		if (mysqli_connect_errno())
		{
		  echo "result=db_connect_error";
		  die();
		}

		$product_id;
		$product_id = findProductID($con, $product);

		if(!isset($product_id)) {
			mysqli_query($con,"INSERT INTO products (name) VALUES ('".$product."')");
			$product_id = findProductID($con, $product);
		}

		mysqli_query($con,"INSERT INTO questions (name,email,message,product_id,date) VALUES ('".$name."','".$email."','".$message."',".$product_id.",NOW())");
		mysqli_close($con);
	}

	function findProductID($con, $product) {
		$query="SELECT id FROM products WHERE name='".$product."'";
		$product_search = mysqli_query($con,$query);
		$id;

		while($row = mysqli_fetch_array($product_search)) {
			if($row == false) return $id;
			$id = $row['id'];
			return $id;
		}
	}
?>