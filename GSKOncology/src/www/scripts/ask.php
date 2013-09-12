<?php
	//$to = "jamie@wehaverhythm.com";
	$name = urldecode($_POST['name']);
	$from = urldecode($_POST['email']);
	$product = urldecode($_POST['product']);
	$subject = "GSK Oncology Question Regarding: ".$product;
	$message = urldecode($_POST['message']);
	
	$headers = "From: ".$name."<".$from.">\r\n";
	$headers .= "Reply-To: ".$from."\r\n";
	$headers .= "MIME-Version: 1.0\r\n";
	$headers .= "Content-Type: text/html; charset=ISO-8859-1\r\n";

	//$result = mail ("hello@jamie-white.com", $subject, $message, $headers);
	

	$con=mysqli_connect("localhost","root","root","gsk");
	// Check connection
	if (mysqli_connect_errno())
	{
	  echo "result=db_connect_error";
	  die();
	}

	// WRITE TO DB.
	writeQuestionTODB("VOTRIENT", "Jamie", "hello@jamie-white.com", "Hello there.");

	mysqli_close($con);

	if($result) {
		echo "result=mail_ok";
	} else {
		echo "result=mail_error";
	}



	die();

	function writeQuestionTODB($product, $name, $email, $message) {

		$product_id = -1;
		$product_id = findProductID($product);

		if($product_id == -1) {
			echo "couln't find product.";
			mysqli_query($con,"INSERT INTO products (name) VALUES ('".$product."')");
			echo "inserted!";
			$product_id = findProductID($product);
			echo "new product id for ".$product." = ".$product_id;
		}


		echo "found product ".$product." with id ".$product_id;
	}

	function findProductID($product) {
		$query="SELECT id from products where name='".$product."' LIMIT 1";
		$product_search = mysqli_query($con,$query);
		$found = false;
		$product_id = null;

		if(mysql_fetch_array($product_search) == false) {
			echo "No product for ".$product;
			return -1;
		} else {
			while($row = mysqli_fetch_array($product_search)) {
				$product_id = $row['id'];
				$found = true;
				echo $product_id;
				echo "Found ".$product." with id: ".$product_id;
				return $product_id;
			}
		}

		
	}
?>