threads=`cat /proc/cpuinfo | grep "model name" | wc -l`
cpuModel=`lscpu | grep "Model name"  | sed 's/   Model name:\|//'`
memoryInfo=`dmidecode -t 17 | awk 'BEGIN { FS=":"; OFS="\t" } /Size|Locator|Speed|Manufacturer|Serial Number|Part Number/ { gsub(/^[ \t]+/,"",$2); line = (line ? line OFS : "") $2 } /^$/ { print line; line="" }' | grep -iv "no module"`
mainboardBrand=`dmidecode -t 1 | grep "Manufacturer" | sed 's/Manufacturer\|//'`
mainboardName=`dmidecode -t 1 | grep "Product Name" | sed 's/Product Name\|//'`
installDate=`fs=$(df / | tail -1 | cut -f1 -d' ') && tune2fs -l $fs | grep created`
installDateParsed=`echo $installDate | sed 's/Filesystem created\|//'`

echo "
   _____ _    _  ______          ___    _          _____  _______          __     _____  ______ 
  / ____| |  | |/ __ \ \        / / |  | |   /\   |  __ \|  __ \ \        / /\   |  __ \|  ____|
 | (___ | |__| | |  | \ \  /\  / /| |__| |  /  \  | |__) | |  | \ \  /\  / /  \  | |__) | |__   
  \___ \|  __  | |  | |\ \/  \/ / |  __  | / /\ \ |  _  /| |  | |\ \/  \/ / /\ \ |  _  /|  __|  
  ____) | |  | | |__| | \  /\  /  | |  | |/ ____ \| | \ \| |__| | \  /\  / ____ \| | \ \| |____ 
 |_____/|_|  |_|\____/   \/  \/   |_|  |_/_/    \_\_|  \_\_____/   \/  \/_/    \_\_|  \_\______|
                                                                                                
                                                                                                
";

echo "v1 by Alexander Fiedler"

echo "";
echo "";

echo "System install date $installDateParsed"

echo "";
echo "";

echo "---------------------------------------"
echo "CPU: $cpuModel"
echo "---------------------------------------"


echo "";
echo "";
echo "Memory Info:"
echo "---------------------------------------------------------------------------------------------------------------"



echo "Size    Speed           Manufacturer                    Serial          Part Number"
dmidecode -t 17 | awk 'BEGIN { FS=":"; OFS="\t" } /Size|Speed|Manufacturer|Serial Number|Part Number/ { if ($2 ~ /MB$|MHz$/) { gsub(/[ \t]+/,"",$2) } gsub(/^[ \t]+/,"",$2); line = (line ? line OFS : "") $2 } /^$/ { print line; line="" }' | grep -iv "no module"

echo "---------------------------------------------------------------------------------------------------------------"

echo "";

echo "";

echo "Motherboard Information"

echo "------------------------------------------------"


echo "$mainboardBrand" | sed 's/[[:space:]]//g'
echo "$mainboardName"  | sed 's/[[:space:]]//g'

echo "------------------------------------------------"

echo "Disk Information"

echo "------------------------------------------------"

lsblk -io TYPE,SIZE,MODEL,KNAME | grep -v '^part' | grep -v '^loop' | grep -v '^raid'

echo "------------------------------------------------"

echo "";

echo "";

echo "Network Interface(NIC) Info"
echo "---------------------------------------"

lspci | egrep -i 'network|ethernet|wireless|wi-fi'  

echo "---------------------------------------"

echo "";
echo "";

echo "GPU Information"

echo "-------------------------------------------------------------------"

GPU=$(lspci | grep VGA | cut -d ":" -f3);GPURAM=$(cardid=$(lspci | grep VGA |cut -d " " -f1);lspci -v -s $cardid | grep " prefetchable"| cut -d "=" -f2);echo $GPU $GPURAM
calc(){ awk "BEGIN { print "$*" }"; }

echo "-------------------------------------------------------------------"

echo "";
echo "";

echo "Probing IPMI device...."

sleep 2

installed() {
    return $(dpkg-query -W -f '${Status}\n' "${1}" 2>&1|awk '/ok installed/{print 0;exit}{print 1}')
}


if installed ipmitool; then
    ipmitool sensor
else
   echo  "Advanced IPMI probing failed. Either the ipmitool package is not installed or this is a virtual machine."
fi
