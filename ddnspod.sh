#!/bin/bash
###   ddnspod 0.1
###   A simple DDNS script for dnspod
###   https://github.com/liyiwu/ddnspod

##  config
user_id='12345'
login_token='0123456789abcdef'
domain='www.domain.com'
###   end

agent="ddnspod/0.1(eric@jiangda.info)"
domaindata="login_token=${user_id},${login_token}&format=json&domain=${domain#*.}&sub_domain=${domain%%.*}"
domainjson=`curl -s -A ${agent} -X POST https://dnsapi.cn/Record.List -d "${domaindata}"`
returncode=${domainjson#*code\":\"}
if [ ${returncode%%\"*} != '1' ]
then
    echo "Failed to get records for ${domain}"
    exit
fi
recordjson=${domainjson#*records\":[}
record_id=${recordjson#*id\":\"}
record_line_id=${recordjson#*line_id\":\"}
record_type=${recordjson#*type\":\"}
value=${recordjson#*value\":\"}
last_ip=${value%%\"*}
postdata="${domaindata}&record_line_id=${record_line_id%%\"*}&record_id=${record_id%%\"*}&record_type=${record_type%%\"*}"
while :
do
    current_ip=`curl -s ip.cn | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
    echo "old:${last_ip}   new:${current_ip}"
    if [ ${current_ip} != ${last_ip} ]
    then
        last_ip=${current_ip}
        curl -s -A ${agent} -X POST https://dnsapi.cn/Record.Modify -d "${postdata}&value=${current_ip}"
    fi
    sleep 5m
done
