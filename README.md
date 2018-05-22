# A simple DDNS script for dnspod


运行前请修改下面三个参数：

    user_id='12345'
    login_token='0123456789abcdef'
    domain='www.domain.com'

脚本放到后台运行，每5分钟会检查一下外网IP，如果与缓存中的不一致，就会更新记录。

此脚本适用大多数Linux环境。

在openwrt路由器上需要安装curl包。由于缺少证书，会报错：

    Error reading ca cert file /etc/ssl/certs/ca-certificates.crt - mbedTLS:

我的解决方案是将debian上的 /etc/ssl/certs  整个复制到路由器上,
也可以在路由器上安装 ca-bundle 应用包。
