<?php
	include "config.php";

	$cart_str = urldecode($_POST['cart']);
	$cart_json = json_decode($cart_str, true);
	$dl_path = $cart_json['path']."/";
	$name = urldecode($_POST['theirName']);
	$to = urldecode($_POST['theirEmail']);
	$from = "GSK <noreply@gsk-downloads.com>";
	$subject = "Your requested GSK information from ECCO ESMO ESTRO 2013";
	$headers = "From: " .$from. "\r\n";
	$headers .= "Reply-To: ".$from. "\r\n";
	$headers .= "MIME-Version: 1.0\r\n";
	$headers .= "Content-Type: text/html; charset=ISO-8859-1\r\n";
	
	$contents = "
<p>Dear ".$name.",<br/><br/>
".htmlentities("Please find below links to the documents that you requested through the electronic resource centre at the GlaxoSmithKline Oncology stand. These materials were prepared by GlaxoSmithKline Oncology for Health Care Professionals and made available at ESMO 27 Sept - 1 Oct , 2013 in Amsterdam.")."<br/><br/>
	
".htmlentities("Please note that those documents were developed based on the indication licensed by the European Medicines Agency (EMA). The licensed indication may be different in your country. Please always refer to the local Prescribing Information.")."<br/><br/>

We look forward to welcoming you to our stand at future congresses.<br/><br/>

If you have any questions, please contact a GlaxoSmithKline affiliate in your country.<br/><br/></p>
";

	$con=mysql_connect($host, $user, $pass);
	if($con) {
		mysql_select_db($db);
		// or die(mysql_error());
	}

	foreach ($cart_json['cart'] as $brand) {
		foreach ($brand['items'] as $item) {
			$contents.="<a style='line-height:23px;' href=".$dl_path.$brand['brand']."/".$item['file'].">".$item['title']."</a><br/>";
			
			if($con) {
				mysql_query("INSERT INTO cart (file,brand,session_id,time) VALUES ('".$item['file']."','".$brand['brand']."','".$_POST['sessionID']."',NOW())");
			}
		}
	}

	$contents .= "<br/>The links within this email will be active for 60 days from receipt of this email.<br/><br/><p>
Best regards,<br/>
GlaxoSmithKline Oncology<br/>
<a href='http://www.gsk.com'>www.gsk.com</a><br/><br/></p>
	";

	
	
	if($con) {
		mysql_close($con);
	}

	$result = mail ($to, $subject, $contents, $headers);
	echo "result=ok";

?>