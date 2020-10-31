#!/bin/bash  
#引入用户变量
source ~/.bashrc
curl -o /usr/local/user/dockerauto-net.sh https://raw.githubusercontent.com/BwmBama/scripts/master/bash/dockerauto.sh --create-dirs
if test -s /usr/local/user/dockerauto-net.sh; then
    rm -rf /usr/local/user/dockerauto.sh
    mv /usr/local/user/dockerauto-net.sh /usr/local/user/dockerauto.sh
    source /usr/local/user/dockerauto.sh > /tmp/auto.log
else
    source /usr/local/user/dockerauto.sh > /tmp/auto.log
fi
