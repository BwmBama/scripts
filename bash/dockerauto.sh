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

    # 定时更新
    if  [ "$time" = "05:00" ]; then 
        # 更新&重建镜像
	echo $(date +"%y-%m-%d %H:%M:%S") "docker pull start" "(FREE_MEM:$FREE_MEM,LOAD:$SYS_LOAD)">> /tmp/mem.log 
	/usr/local/bin/docker-compose -f /root/docker-compose.yml pull
	/usr/local/bin/docker-compose -f /root/docker-compose.yml down
	/usr/local/bin/docker-compose -f /root/docker-compose.yml up -d
	echo $(date +"%y-%m-%d %H:%M:%S") "docker pull done" "(FREE_MEM:$FREE_MEM,LOAD:$SYS_LOAD)">> /tmp/mem.log
	docker rmi $(docker images | grep "none" | awk '{print $3}')
	# 脚本自更新
	curl -o /etc/v3auto.sh https://raw.githubusercontent.com/BwmBama/scripts/master/bash/dockerauto.sh
    fi 
    echo "ok"
