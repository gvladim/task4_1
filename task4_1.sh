#!/bin/bash
workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
exec 1> $workdir/task4_1.out

echo "--- Hardware ---"
#Motherboard
man=$(dmidecode -t 1 | grep 'Manufacturer' | awk -F: '{print $2}')
pro=$(dmidecode -t 1 | grep 'Product Name' | awk -F: '{print $2}')
echo "Motherboard:"  ${man} ${pro:-Unknown}
#System Serial Number
ser=$(dmidecode -s system-serial-number | awk '{print $0}')
echo "System Serial Number:" ${ser:-Unknown}
#CPU info
cat /proc/cpuinfo | grep 'model name' | awk -F: 'NR==1{print "CPU:" $2}'
#RAM info
cat /proc/meminfo | grep MemTotal | awk '{print "RAM: " $2 " KB"}'

echo  "--- System ---"
#OS Distribution
cat /etc/*release* | grep DISTRIB_DESCRIPTION | awk -F= '{print "OS Distribution: " $2}' | sed 's/"//g'
# ver Unix
uname -a | awk '{print "Ver Unix: " $0}'
#Kernel version
uname -r | awk '{print "Kernel version: " $0}'
#sys install date
awk 'NR==1{print "Installation date: " $1}' /var/log/dpkg.log
#Hostname
echo "Hostname:" $(hostname -f)
#Uptime
uptime | awk -F'( |,|:)+' '{if ($7=="min") m=$6; else {if ($7~/^day/) {d=$6;h=$8;m=$9} else {h=$6;m=$7}}} {print "Uptime: " d+0,"days,",h+0,"hours,",m+0,"minutes."}'
#Processes running:
ps aux --no-heading | wc -l | awk '{print "Processes running: " $0}'
#User logged in
who --count | grep users | awk -F= '{print "User logged in: " $2}'

echo "--- Network info---"
for iface in $(ifconfig | cut -d ' ' -f1| tr "\n" ' ')
do
  addr=$(ip -o -4 addr list $iface | awk '{print $4}')
  [ -z "$addr" ] && printf "$iface: -\n" || printf "$iface: $addr\n"
done

exit 0