# -*- coding: utf-8 -*-
# https://python-telegram-bot.org/
# pip3 install python-telegram-bot
import telegram
import sys
import socket
import time
import os
import json
import urllib.request as ur
import urllib.parse as par
from retrying import retry

blocked = False

# file to save status of blocked
path ='/tmp/server_blocked'
if not os.path.exists(path):
    os.mknod(path)
else:
    cmd = "echo "+ "\"\" " + ">" + path
    os.system(cmd)

def get_config():
    global path
    config = {}
    config['path'] = path
    config['chat_id'] = 'your chat id'
    config['api_key'] = 'your api key'
    with open(path, 'r') as f:
        config['blocked']=f.read()
    f.close()
    return config

#中国联通
CUCC = ('10010.com',80)
#中国移动
CMCC = ('www.10086.cn',80)
#中国电信
CTCC = ('www.chinatelecom.com.cn',80)
    
def write_config(path, str):
    with open(path, 'w') as f:
        f.write(str)
    f.close()

def tcping(ip_port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    t_start = round(time.time()*1000)
    try:
        s.settimeout(1)
        s.connect(ip_port)
        s.shutdown(socket.SHUT_RD)
        t_end = round(time.time()*1000)
        s.settimeout(None)
        return (t_end-t_start)
        # s.close()
    except Exception as e:
        s.settimeout(None)
        return -1

def check_tcp(ip_port):
    if tcping(ip_port) == -1:
        if tcping(ip_port) == -1:
            if tcping(ip_port) == -1:
                return -1
            else:
                return 1
        else:
            return 1
    else:
        return 1

def build_str(choice):
    if choice == 0:
        str = "Server has been blocked by GFW!"
    elif choice == 1:
        str = "Server has been unblocked by GFW!"
    elif choice == 2:
        str = "Current ip:"
    elif choice == -1:
        str = "Py test!"
    return str

@retry(stop_max_attempt_number=5, wait_fixed=2000)
def sendmsg_os(str, config):
    try:
        html = ur.urlopen('https://ipapi.co/json').read()
        country = json.loads(html.decode('utf-8'))['country_name']
        myip = json.loads(html.decode('utf-8'))['ip']
        bot = telegram.Bot(token=config['api_key'])
        bot.send_message(chat_id=config['chat_id'], text=str + '\n' + country + '\n' + myip)
    except:
        html = ur.urlopen("http://whatismyip.akamai.com")
        myip = (html.read().decode('utf-8'))
        bot = telegram.Bot(token=config['api_key'])
        bot.send_message(chat_id=config['chat_id'], text=str + '\n' + myip)
        
def check_gfw():
    check=0
    if check_tcp(CUCC)== 1:
        check=check+1
        print('CUCC up')
    else:
        check=check-1
        print('CUCC down')
    if check_tcp(CMCC)== 1:
        check=check+1
        print('CMCC up')
    else:
        check=check-1
        print('CMCC down')
    if check_tcp(CTCC)== 1:
        check=check+1
        print('CTCC up')
    else:
        check=check-1
        print('CTCC down')
    return check

def check_warn_newip():
    config = get_config()
    print(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) ,end=" ")
    print(config)
    if config['blocked']=='1\n':
        check=0
        if check_gfw()>= 1:
            str = build_str(1)
            write_config(config['path'],'0')
            sendmsg_os(str, config)            
    else:
        if check_gfw()<= -1:
            time.sleep(30)
            if check_gfw()<= -1:
                time.sleep(30)
                if check_gfw()<= -1:
                    str = build_str(0)
                    write_config(config['path'],'1\n')
                    sendmsg_os(str, config)

if __name__ == '__main__':
    while True:
        check_warn_newip()
        time.sleep(30)
