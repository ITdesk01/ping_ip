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

rm -rf *.txt

ip() {
echo -e "$green开始进行批量ping$white"
cat >/tmp/ip.txt <<EOF
	192.168.10
EOF
	for ip in `cat /tmp/ip.txt | grep -v "#" | awk '{print $1}'`
	do
	{
		for i in `seq 1 254`
		do
		{
			ping -c 1 ${ip}.${i} >/dev/null
			if [ $? -eq 0 ]; then
				echo "${ip}.${i} 正常ping通"
				echo "${ip}.${i}" >>ip_ok_tmp.txt
			else
				#echo "${ip}.${i} 无法ping通"
				echo "${ip}.${i}" >>ip_no_tmp.txt
			fi
		} &
		done
		wait
		
	}&
	done
	wait

	cat ip_ok_tmp.txt | sort -u >ip_ok.txt
	cat ip_no_tmp.txt | sort -u >ip_no.txt
	rm -rf ip_ok_tmp.txt
	rm -rf ip_no_tmp.txt

	sed -i "1 i \能够正常ping通的IP如下" ip_ok.txt
	sed -i "1 i \这里的IP无法ping通" ip_no.txt
echo -e "$green批量ping完成，具体结果查看${yellow}ip_ok.txt${white}和${red}ip_no.txt$white"
ip_port
}

ip_port() {
echo -e "$green开始进行批量测试端口连接$white"
cat >/tmp/ip_port.txt <<EOF
	80
	5000
EOF

	for ip_port in `cat /tmp/ip_port.txt | grep -v "#" | awk '{print $1}'`
	do
	{
		for ip_ok in `cat ip_ok.txt | grep -v "##" | awk '{print $1}'`
		do
		{
			curl -s -m 5 $ip_ok:$ip_port >/dev/null
			if [ $? -eq 0 ]; then
				echo "$ip_ok $ip_port 端口正常"
				echo "$ip_ok $ip_port 端口正常" >> ip_port_ok.txt
			else
				#echo "$ip_ok $ip_port　端口失败"
				echo "$ip_ok $ip_port  端口失败" >> ip_port_no.txt
			fi
		}&
		done
		wait
		
	}&
	done
	wait
	
echo -e "$green批量测试端口连接完成，具体结果查看${yellow}ip_port_ok.txt${white}和${red}ip_port_no.txt$white"
}
ip






















