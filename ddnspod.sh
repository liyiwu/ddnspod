#!/bin/bash
###   ddnspod 0.2
###   A simple DDNS script for dnspod
###   https://github.com/liyiwu/ddnspod

##  config
user_id=''
login_token=''
domain='www.domain.com'
###   end

agent="ddnspod/0.1(eric@jiangda.info)"
domaindata="login_token=${user_id},${login_token}&format=json&domain=${domain#*.}&sub_domain=${domain%%.*}"
returnjson=`curl -s -A ${agent} -X POST https://dnsapi.cn/Record.List -d "${domaindata}"`
returncode=${returnjson#*code\":\"}
if [ ${returncode%%\"*} != '1' ]
then
    echo "Failed to get records for ${domain}"
    exit
fi
recordjson=${returnjson#*records\":[}
record_id=${recordjson#*id\":\"}
record_line_id=${recordjson#*line_id\":\"}
value=${recordjson#*value\":\"}
last_ip=${value%%\"*}
postdata="${domaindata}&record_line_id=111${record_line_id%%\"*}&record_id=${record_id%%\"*}"
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
