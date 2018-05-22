#!/bin/bash
###   A simple DDNS script for dnspod
###   https://github.com/liyiwu/ddnspod

##  config
user_id='12345'
login_token='0123456789abcdef'
domain='www.domain.com'
###   end

agent="ddnspod/0.4(eric@jiangda.info)"
postdata="login_token=${user_id},${login_token}&format=json&domain=${domain#*.}&sub_domain=${domain%%.*}"
returnjson=`curl -s -A ${agent} -X POST https://dnsapi.cn/Record.List -d "${postdata}"`
returncode=${returnjson#*code\":\"}
if [ ${returncode%%\"*} != '1' ]
then
    echo "Failed to get the record for ${domain}"
    exit
fi
returnjson=${returnjson#*records\":[}
record_id=${returnjson#*id\":\"}
record_line_id=${returnjson#*line_id\":\"}
value=${returnjson#*value\":\"}
last_ip=${value%%\"*}
postdata="${postdata}&record_line_id=${record_line_id%%\"*}&record_id=${record_id%%\"*}"
while :
do
    current_ip=`curl -s ip.cn | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
    if [ ${current_ip} != ${last_ip} ]
    then
        returnjson=`curl -s -A ${agent} -X POST https://dnsapi.cn/Record.Ddns -d "${postdata}"`
        returncode=${returnjson#*code\":\"}
        if [ ${returncode%%\"*} = '1' ]
        then
            last_ip=${current_ip}
        fi
    fi
    sleep 5m
done
