<?php
	include "config.php";

	$password = urldecode("gskESMO2013");
	$tables = array("questions", "sessions", "stats", "cart");
	

	if (isset($_REQUEST['password']) && $_REQUEST['password'] == $password) {

		$con=mysql_connect($host, $user, $pass);

		if (!$con) {
			echo "result=db_connect_error";
			die();
		}

		mysql_select_db($db) or die(mysql_error());

		foreach ($tables as $table) {
			mysql_query('TRUNCATE TABLE '.$table.';');
		}

		mysql_close($con);
		?>
			<h3>done.</h3>
		<?php
		die();

	} else {
		?>
			<p>Entering the password will empty the following tables :</p>
			<ul>
			<?php
				foreach ($tables as $table) {
					echo "<li>".$table."</li>";
				}
			?>
			</ul>
			<form method='post' action='?'>
			  Password: <input name='password' type='password'>
			  <input type='submit'>
			</form>
		<?php
	}
	
?>