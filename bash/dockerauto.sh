#!/bin/bash  
#引入用户变量
source ~/.bashrc
#usage: * * * * * /root/dockerauto.sh > /tmp/dockerauto.log 2>&1
# [Linux]根据CPU负载及内存占用自动重启脚本 
# 设置最小剩余内存，一般至少要剩余50M可用（单位兆）  
FREE_MEM_MIN="20" 
# 设置最大系统负载  
# SYS_LOAD_MAX="3" 
# 设置需要监控的服务名称  
    # 获得当前时间
    time=`date +%H:%M`
    # 获得剩余内存（单位兆）  
    FREE_MEM=`free -m|grep +|awk '{print $4}'`
    if [ "$FREE_MEM" = "" ]; then
    FREE_MEM=`free -m|grep Mem|awk '{print $7}'`
    fi
    # 获取最近一分钟系统负载  
    # SYS_LOAD=`uptime | awk '{print $(NF-2)}' | sed 's/,//'`  
    # 比较内存占用和系统负载是否超过阀值  
    MEM_VULE=`awk 'BEGIN{print('"$FREE_MEM"'<'"$FREE_MEM_MIN"'?"1":"0")}'`  
    # LOAD_VULE=`awk 'BEGIN{print('"$SYS_LOAD"'>='"$SYS_LOAD_MAX"'?"1":"0")}'`  
       
    # 测试结果  
    #LOAD_VULE="1"  
    #echo $(date +"%y-%m-%d %H:%M:%S") "DEBUG $NAME" "(FREE_MEM:$FREE_MEM|$MEM_VULE,LOAD:$SYS_LOAD|$LOAD_VULE)">> /tmp/mem.log  
       
     
    # 如果系统内存占用和系统负载超过阀值进行下面操作。 
    if [ $MEM_VULE = 1 ]; then 
        # 写入日志  
        echo $(date +"%y-%m-%d %H:%M:%S") "restart start" "(FREE_MEM:$FREE_MEM,LOAD:$SYS_LOAD)">> /tmp/mem.log  
        # 重启服务
        /usr/local/bin/docker-compose -f /root/docker-compose.yml restart
        sleep 10
        FREE_MEM=`free -m|grep +|awk '{print $4}'`
        if [ "$FREE_MEM" = "" ]; then
        FREE_MEM=`free -m|grep Mem|awk '{print $7}'`
        fi
        echo $(date +"%y-%m-%d %H:%M:%S") "restart done" "(FREE_MEM:$FREE_MEM,LOAD:$SYS_LOAD)">> /tmp/mem.log
    fi 

    # 定时重启服务
    if  [ "$time" = "05:00" ]; then 
        #  写入日志  
        echo $(date +"%y-%m-%d %H:%M:%S") "restart start" "(FREE_MEM:$FREE_MEM,LOAD:$SYS_LOAD)">> /tmp/mem.log  
	/usr/local/bin/docker-compose -f /root/docker-compose.yml restart
        sleep 30
        FREE_MEM=`free -m|grep +|awk '{print $4}'`
        if [ "$FREE_MEM" = "" ]; then
        FREE_MEM=`free -m|grep Mem|awk '{print $7}'`
        fi
        echo $(date +"%y-%m-%d %H:%M:%S") "restart done" "(FREE_MEM:$FREE_MEM,LOAD:$SYS_LOAD)">> /tmp/mem.log
    fi 

    # 定时更新
    if  [ "$time" = "06:00" ]; then 
        # 更新镜像
	/usr/local/bin/docker-compose -f /root/docker-compose.yml pull
	/usr/local/bin/docker-compose -f /root/docker-compose.yml up -d
	docker rmi $(docker images | grep "none" | awk '{print $3}')
	# 脚本自更新
	curl -o /etc/v3auto.sh https://raw.githubusercontent.com/BwmBama/scripts/master/bash/dockerauto.sh
    fi 
    
    # 更新 Caddy2
    if  [ "$time" = "06:05" ]; then
        sed -i 's|mjj:dd|mjj:caddy|g'  /root/docker-compose.yml
        sed -i 's|:\/etc\/Caddyfile|:\/etc\/caddy\/Caddyfile|g'  /root/docker-compose.yml
        sed -i 's|root \/srv\/www|root * \/srv\/www|g'  /root/Caddyfile
        sed -i 's|log .\/caddy.log|log {\n    output file /srv/caddy.log {\n      roll_keep  3\n    }\n  \}\n  file_server|g'  /root/Caddyfile
        sed -i 's|log .\/caddy443.log|log {\n    output file /srv/caddy.log {\n      roll_keep  3\n    }\n  \}\n  file_server|g'  /root/Caddyfile
        sed -i 's|  proxy|  reverse_proxy|g'  /root/Caddyfile
        sed -i '/websocket/d' /root/Caddyfile
        sed -i 's|header_upstream -Origin|header_up -Origin|g'  /root/Caddyfile
        sed -i 's|  gzip|  encode gzip|g'  /root/Caddyfile
        sed -i '/cloudflare/d' /root/Caddyfile
        sed -i '/    https:\/\/{host}{uri}/d' /root/Caddyfile
        sed -i 's|  redir {|  redir https:\/\/{host}{uri}|g'  /root/Caddyfile
        sed -i '/redir/{:a;n;/ }/d;/}/!ba}' /root/Caddyfile
    fi
