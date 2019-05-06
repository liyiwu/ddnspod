#!/bin/bash
###   A simple DDNS script for dnspod
###   https://github.com/liyiwu/ddnspod

##  config
user_id='12345'
login_token='0123456789abcdef'
domain='www.domain.com'
###   end

# wait internet and sync time
sleep 2m;
ntpclient -c 1 -h 0.openwrt.pool.ntp.org > /dev/null

echo "Start at $(date)"
agent="ddnspod/0.7(eric@jiangda.info)"
postdata="login_token=${user_id},${login_token}&format=json&domain=${domain#*.}&sub_domain=${domain%%.*}"
#echo $postdata
while :
do
    #echo "curl -s -A ${agent} -X POST https://dnsapi.cn/Record.List -d '${postdata}'"
    #returnjson=$(curl -k -s -A ${agent} -X POST https://dnsapi.cn/Record.List -d "${postdata}")
    returnjson=$(wget --post-data="${postdata}" https://dnsapi.cn/Record.List -nv -O -)
    returncode=${returnjson#*code\":\"}
    if [ ${returncode%%\"*} == '1' ]
    then
        #echo "${returnjson}"
        break
    fi
    echo "Failed to get the record for ${domain}"
    sleep 1m;
done

returnjson=${returnjson#*records\":[}
record_id=${returnjson#*\[\{\"id\":\"}
record_line_id=${returnjson#*line_id\":\"}
value=${returnjson#*value\":\"}
last_ip=${value%%\"*}
postdata="${postdata}&record_line_id=${record_line_id%%\"*}&record_id=${record_id%%\"*}"

while :
do
    # get WAN IP from ip.cn
    # current_ip=`curl -k -s ip.cn | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`

    # get WAN IP from openwrt
    current_ip=`ip add show pppoe-wan | grep "inet "|grep -v inet6| cut -d " "  -f6`
    if [ ${current_ip} != ${last_ip} ]
    then
        date
        echo "WAN IP is ${current_ip}"
        echo "DNS IP is ${last_ip}"
	    #echo "curl -k -s -A ${agent} -X POST https://dnsapi.cn/Record.Ddns -d '${postdata}'"
        #returnjson=`curl -k -s -A ${agent} -X POST https://dnsapi.cn/Record.Ddns -d "${postdata}"`
        returnjson=`wget --post-data="${postdata}" https://dnsapi.cn/Record.Ddns -nv -O -`
        returncode=${returnjson#*code\":\"}
        #echo "update code is ${returncode}"
        if [ ${returncode%%\"*} = '1' ]
        then
            last_ip=${current_ip}
            date
            echo "New IP is ${last_ip}, Update successful"
        fi
        echo " "
    fi
    sleep 5m
done
