# A simple DDNS script for dnspod

运行前请修改下面三个参数：

user_id='12345'
login_token='0123456789abcdef'
domain='www.domain.com'

脚本放到后台运行，每5分钟会检查一下外网IP，如果与缓存中的不一致，就会更新记录。


