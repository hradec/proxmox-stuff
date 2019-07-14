#!/bin/bash
/root/mdcmd status | strings | grep "mdState=STOPPED" >/dev/null 2>&1
if [ $? != 0 ]
then
	echo "Array found STARTED, stop array before proceeding"
	exit
fi
echo -e "\n"
echo "List information about all adapters found"
echo -e "\n"
read -p "Press Enter key to start, or CTRL-C to quit."
echo -e "\n"
echo "Proceeding to find LSI Controllers"
echo "Log will be AdaptersCurrentFW-Bios.txt in the current directory"
echo -e "\n"
sasflash -l AdaptersCurrentFW-Bios.txt -listall
