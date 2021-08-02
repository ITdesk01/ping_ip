#!/bin/sh
#
#by:ITdesk
#
#set -x
#获取当前脚本目录copy脚本之家
Source="$0"
while [ -h "$Source"  ]; do
    dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"
    Source="$(readlink "$Source")"
    [[ $Source != /*  ]] && Source="$dir_file/$Source"
done
dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"

red="\033[31m"
green="\033[32m"
yellow="\033[33m"
white="\033[0m" 

ip() {
if [ ! -d $dir_file/result ];then
	mkdir $dir_file/result
else
	rm -rf $dir_file/result/*
fi
clear
echo -e "$green开始进行批量ping$white"
	echo "##能够正常ping通的IP如下" >$dir_file/result/ip_ok.txt
	echo "##这里的IP无法ping通" >$dir_file/result/ip_no.txt
	for ip in `cat $dir_file/ip.txt | grep -v "##" | awk '{print $1}'`
	do
	{
		for i in `seq 1 254`
		do
		{
			ping -c 2 ${ip}.${i} >/dev/null
			if [ $? -eq 0 ]; then
				echo "${ip}.${i} 正常ping通"
				echo "${ip}.${i}" >>$dir_file/result/ip_ok.txt
			else
				echo "${ip}.${i}" >>$dir_file/result/ip_no.txt
			fi
		} &
		done
		wait
		
	}&
	done
	wait
echo -e "$green批量ping完成，具体结果查看${yellow}ip_ok.txt${white}和${red}ip_no.txt$white"
echo ""
ip_port
}

ip_port() {
echo -e "$green开始进行批量测试端口连接$white"
	for ip_port in `cat ip_port.txt | grep "web_port" | sed "s/web_port=\"//g" | sed "s/\"//g"`
	do
	{
		for ip_ok in `cat $dir_file/result/ip_ok.txt | grep -v "##" | awk '{print $1}'`
		do
		{
			curl -s -m 5 $ip_ok:$ip_port >/dev/null
			if [ $? -eq 0 ]; then
				echo "$ip_ok $ip_port curl端口正常"
				echo "$ip_ok $ip_port curl端口正常" >> $dir_file/result/ip_port_ok.txt
			else
				echo "$ip_ok $ip_port  curl端口失败" >> $dir_file/result/ip_port_no.txt
			fi
		}&
		done
		wait
	}&
	done
	wait

	for ip_port in `cat ip_port.txt | grep "tcp_port" | sed "s/tcp_port=\"//g" | sed "s/\"//g"`
	do
	{
		for ip_ok in `cat $dir_file/result/ip_ok.txt | grep -v "##" | awk '{print $1}'`
		do
		{
			if_port=$(echo | telnet $ip_ok $ip_port | grep -v "not resolve"| grep Connected | wc -l)
			if [ $if_port -eq 1 ]; then
				echo "$ip_ok $ip_port telnet连接端口正常"
				echo "$ip_ok $ip_port telnet连接端口正常" >> $dir_file/result/ip_port_ok.txt
			else
				echo "$ip_ok $ip_port  telnet连接端口失败" >> $dir_file/result/ip_port_no.txt
			fi
		}&
		done
		wait
	}&
	done
	wait

	for i in `ls $dir_file/result/*.txt`
	do
		cat $i | sort -t . -k 4n -o $i
	done
	
echo -e "$green批量测试端口连接完成，具体结果查看${yellow}ip_port_ok.txt${white}和${red}ip_port_no.txt$white"
summary
}

summary() {
	clear
	echo "-------------------------------------------------------------------"
	echo -e "$green汇总报告：$white"
	cat $dir_file/result/ip_ok.txt
	echo ""
	cat $dir_file/result/ip_port_ok.txt
	echo ""
	echo -e "$green批量ping完成，具体结果查看${yellow}ip_ok.txt${white}和${red}ip_no.txt$white"
	echo -e "$green批量测试端口连接完成，具体结果查看${yellow}ip_port_ok.txt${white}和${red}ip_port_no.txt$white"
	echo "-------------------------------------------------------------------"	
	echo ""

}
ip






















