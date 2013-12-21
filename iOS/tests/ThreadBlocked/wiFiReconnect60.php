<?
	$command = " device=\"$(networksetup -listallhardwareports | grep -E '(Wi-Fi|AirPort)' -A 1 | grep -o \"en.\")\" \n ";
	$command .= " val=off \n";
	$command .= " networksetup -setairportpower \$device \$val \n";

	$command .= " sleep 60 \n";

	$command .= " val=on \n";
	$command .= " networksetup -setairportpower \$device \$val \n";

	$output = shell_exec( $command );
	echo "$command";
?>