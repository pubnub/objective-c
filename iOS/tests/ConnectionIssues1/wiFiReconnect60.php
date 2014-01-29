<?
echo date('l jS \of F Y h:i:s A');
echo "<br>";

$output = shell_exec( "./wiFiReconnect60.sh" );
echo date('l jS \of F Y h:i:s A');

?>