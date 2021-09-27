#############view all files in folder INI
######### not ready yet!!!!!!!!!!!!!!
#open (BIGINI, ">config.list")|| die "Error opening file: $!";
#opendir(DIR, 'INI') || die 'ошибка открытия';
#while($line = readdir(DIR)) {print BIGINI $line . "\r\n";}
#closedir(DIR);
#
#close (BIGINI);
###########################################
$StartTime=time();
open (BIGINI, "config.list")|| die "Error opening file: $!";
while(<BIGINI>)
{
$CurrentINI=$_;
$i=0;
open (FILE, $CurrentINI)|| die "Error opening file: $!";
while(<FILE>)
	{
	if(/eof/i){last;}
	else{$config[$i++]=$_;}
	}
close(FILE);
$returncounter=0;
$FileName     = substr ($config[0], index($config[0]," "), (index($config[0],"\n")-index($config[0]," "))) ;
$FileNumber   = substr ($config[1], index($config[1]," "), (index($config[1],"\n")-index($config[1]," "))) ;
$StringNumber = substr ($config[2], index($config[2]," "), (index($config[2],"\n")-index($config[2]," "))) ;
$FieldNumber  = substr ($config[3], index($config[3]," "), (index($config[3],"\n")-index($config[3]," "))) ;

for ($i=0;$i<$FieldNumber;$i++)
{
$FLD[$i] = substr ($config[$i+4], (index($config[$i+4]," ")+1), 100); 
}

for ($FileCounter=0;$FileCounter<$FileNumber;$FileCounter++)
	{
	open(DATAOUT, ">OUT\\".$FileName."_".$FileCounter.".txt");
	for ($StringCounter=0;$StringCounter<$StringNumber;$StringCounter++)
		{
		for ($FieldCounter=0;$FieldCounter<$FieldNumber;$FieldCounter++)
			{
				
				$ToPrint=&FLDCase($FLD[$FieldCounter]);
			print DATAOUT $ToPrint."\t"; #&FLDCase($FLD[$FieldCounter])." ";
			}
		print DATAOUT "\n";
		}
	close DATAOUT;
	}
}
$EndTime=time();
print $EndTime-$StartTime."\n";
sub FLDCase
{
	my($FLD) = @_;
$FLDType=substr ($FLD, "0", index($FLD," ")) ;
$FLDLength=substr ($FLD, index($FLD," "), (index($FLD,"\n")- index($FLD," "))) ;

	if ($FLDType=~/TXT/i) 	{		$ret=&GenString($FLDLength);return $ret;}		#returning random text consist of $FLDLength letters
	if ($FLDType=~/DATE/i) 	{		$ret=&GenDate($FLDLength);return $ret;}	#returning date formatted as described in .ini file
	if ($FLDType=~/int/i) 	{		$ret=&GenInteger($FLDLength);return $ret;}	#returning random integer number consist of $FLDLength digits
	if ($FLDType=~/const/i) {		$ret=$FLDLength;return $ret;}								#returning the constant field
	if ($FLDType=~/fromfile/i) {		$ret=&FromFile($FLDLength);return $ret;}								#returning znachenie from file
	if ($FLDType=~/phone/i) {		$ret=&GenPhone($FLDLength);return $ret;}								#returning phone number
	if ($FLDType=~/counter/i) {		$ret=&Counter($FLDLength+$returncounter++);return $ret;}								#counter
	if ($FLDType=~/between/i) {		$ret=&Between($FLDLength);return $ret;}								#Between
}
sub GenPhone
{
return "7495".&GenInteger(7);
}
sub FromFile
{
	my($k) = @_;
	open (FILE, $k)|| die "Error opening file: $!";
	@massiv=<FILE>;
	close(FILE);
	$ret=$massiv[int(rand($#massiv))];
	$ret=substr($ret,0,(length($ret)-1));
return $ret;
}
sub GenDate				# Generate date of messages
{
	my($k) = @_;
#	print $k." - date format \n";
	$timemodifier=0;$Dposition=0;$Mposition=0;$Yposition=0;
	if ($k=~/f/i) 	{	$timemodifier=1}						#Generate date from the (F)uture
	if ($k=~/p/i) 	{	$timemodifier=-1}						#Generate date from the (P)ast
	if ($k=~/c/i) 	{	$timemodifier=0}						#Generate (C)urrent date
	if ($k=~/d/i) 	{	$Dposition=index($k,'d')}		#Day position
	if ($k=~/m/i) 	{	$Mposition=index($k,'m')}		#Month position
	if ($k=~/y/i) 	{	$Yposition=index($k,'y')}		#Year position
	$Ycounter = 0;	while ($k=~/y/ig){$Ycounter++;}	#Year legth, 2 or 4 simbols
	$period=1;																									#Generate default period 
	if ($k=~/1/) 		{	$period=86400   +int(rand(259200  ))}			#Generate period between 1 and 4 days    
	if ($k=~/2/) 		{	$period=345600  +int(rand(345600  ))}			#Generate period between 4 and 8 days    
	if ($k=~/3/) 		{	$period=691200  +int(rand(604800  ))}			#Generate period between 8 and 14 days   
	if ($k=~/4/) 		{	$period=1296000 +int(rand(1382400 ))}			#Generate period between 14 and 30 days  
	if ($k=~/5/) 		{	$period=2678400 +int(rand(5097600 ))}			#Generate period between 30 and 90 days  
	if ($k=~/6/) 		{	$period=7776000 +int(rand(7776000 ))}			#Generate period between 90 and 180 days 
	if ($k=~/7/) 		{	$period=15552000+int(rand(7776000 ))}			#Generate period between 180 and 270 days
	if ($k=~/8/) 		{	$period=23328000+int(rand(8208000 ))}			#Generate period between 270 and 365 days
  if ($k=~/9/) 		{	$period=31536000+int(rand(54864000))}			#Generate period between 365 and 1000 days

#	print "y numb ".$yynumb."\n";
#	print "mod   ".$timemodifier." \nddpos ".$Dposition." \nmmpos ".$Mposition." \nyypos ".$Yposition."\n";

	($sec, $min, $hour, $CD, $CM, $CY, $wday, $yday, $isdst) = localtime(time+$timemodifier*$period); 

	$CM++;				#Change Month counts from [0-11] to [1-12]

	if ($CM<10) {$CM="0".$CM};		#changing format 
	if ($CD<10) {$CD="0".$CD};
if ($Ycounter>3){	$CY=$CY+1900;}		#YYYY format
else {	if($CY>99){$CY-=100; if ($CY<10) {$CY="0".$CY};}}			#YY format and checking
if ($Dposition<$Mposition) 
{
	if ($Dposition<$Yposition) 
	{
		if ($Mposition<$Yposition) 
		{
			$ret=$CD.$CM.$CY;
		}
		else
		{
			$ret=$CD.$CY.$CM;
		}
	}
	else 
	{
		$ret=$CY.$CD.$CM;
	}
}
else 
{
	if ($Dposition<$Yposition) 
	{
		$ret=$CM.$CD.$CY;
	}
	else 
	{
		if ($Mposition<$Yposition) 
		{
			$ret=$CM.$CY.$CD;
		}
		else
		{
			$ret=$CY.$CM.$CD;
		}
	}
}
	return $ret;
}
sub GenInteger		# Returns random INTEGER of asked length
{
	my($len) = @_;
	my $ret = "";
	my($rnd, $z);
	for ($z = 0; $z < $len; $z++)
	{
		$rnd = int(rand(10));
		if ($z == 0 && $rnd == 0)
		{
			$rnd = 1;
		}		
		$ret = $ret.$rnd;
	}
	return $ret;
}
sub GenFloat			# Returns random FLOAT of asked length
{
	my($a, $b) = @_;
	return &GenInteger($a).".".&GenInteger($b);
}
sub GenString			# Returns random STRING consist of letters
{
	my($len) = @_;
	my @symbols = ("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z");
	my($rnd, $z);
	my $ret = "";
	for ($z = 0; $z < $len; $z++)
	{
		$rnd = int(rand(26));
		$ret = $ret.$symbols[$rnd];
	}	
	return $ret;
}

sub Counter   # Returns random number between two 
{
	my($start) = @_;
	$ret=$start;
	return $ret;
}

sub Between		# Returns random INTEGER of asked length
{
	my($len) = @_;
	print "in ".$len."\r\n";
	$LBound= substr ($len, 0, (index($len,"-")));
	$RBound= substr ($len, (index($len,"-")+1)) ;
	print "len ".(index($len,"-")+1)." 2 - ". ($#len- index($len,"-"))."\r\n";
	print "Left - ".$LBound." Right - ".$RBound."\r\n".$#len;
	$ret = $LBound+(int(rand($RBound-$LBound)));
	return $ret;
}

##!/usr/bin/perl
## Передача в подпрограмму параметров по значению 
#sub f{
#  my($x, $y) = @_;
#  return(++$x * --$y);
#}
#$val = f(9,11);
#print "Значение (9+1) * (11-1) равно $val\n";
#$x = 9;
#$y = 11;
#$val = f($x,$y);
#print "Значение ($x+1) * ($y-1) равно $val\n";
#print "Значение \$х остается равным $x, a \$y равным $y\n";