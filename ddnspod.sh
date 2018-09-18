#!/bin/bash
###   A simple DDNS script for dnspod
###   https://github.com/liyiwu/ddnspod

##  config
user_id='12345'
login_token='0123456789abcdef'
domain='www.domain.com'
###   end

    current_ip=`curl -s ip.cn | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
echo "ddns start"
agent="ddnspod/0.6(eric@jiangda.info)"
postdata="login_token=${user_id},${login_token}&format=json&domain=${domain#*.}&sub_domain=${domain%%.*}"

while :
do
    sleep 3m;
    returnjson=`curl -s -A ${agent} -X POST https://dnsapi.cn/Record.List -d "${postdata}"`
    returncode=${returnjson#*code\":\"}
    if [ ${returncode%%\"*} == '1' ]
    then
        echo "${returnjson}"
        break
    fi
    echo "Failed to get the record for ${domain}"
done

returnjson=${returnjson#*records\":[}
record_id=${returnjson#*id\":\"}
record_line_id=${returnjson#*line_id\":\"}
value=${returnjson#*value\":\"}
echo "${value}"
last_ip=${value%%\"*}
postdata="${postdata}&record_line_id=${record_line_id%%\"*}&record_id=${record_id%%\"*}"

while :
do
    # get WAN IP from ip.cn
    # current_ip=`curl -s ip.cn | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`

    # get WAN IP from openwrt
    #current_ip=`ip add show pppoe-wan | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
    current_ip=`ip add show pppoe-wan | grep inet | cut -d " "  -f6`
    date
    echo "WAN IP is ${current_ip}"
    echo "DNS IP is ${last_ip}"
    if [ ${current_ip} != ${last_ip} ]
    then
        returnjson=`curl -s -A ${agent} -X POST https://dnsapi.cn/Record.Ddns -d "${postdata}"`
        returncode=${returnjson#*code\":\"}
        echo "update code is ${returncode}"
        if [ ${returncode%%\"*} = '1' ]
        then
            last_ip=${current_ip}
            echo "Update successful"
        fi
    fi
    echo ""
    sleep 3m
done
