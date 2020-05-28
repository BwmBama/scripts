from urllib import request
import time
import os
import smtplib
import telegram   #pip3 install python-telegram-bot

#临时文件
path='/tmp/vps'
if not os.path.exists(path):
    os.mknod(path)
else:
    cmd = "echo "+ "\"\" " + ">" + path
    os.system(cmd)

def write_config(path, str):
    with open(path, 'w') as f:
        f.write(str)
    f.close()
    
#设置检测URL地址
url="https://www.google.com"
def get_html_info():    
    #response = request.urlopen(url)
    #html = response.read()
    #html = html.decode("utf-8","ignore")
    req = urllib.request.Request(
        url, 
        data=None, 
        headers={    #User-Agent设置，防止被屏蔽
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36'
        }
    )
    f = urllib.request.urlopen(req)
    html=f.read().decode('utf-8')

    return html

#设置检测关键字
def judge_status(html):
    begin = html.find('<title>')            #开始字符
    end   = html.find('</title>',begin)     #结束字符
    judge = html.find('Google',begin,end)   #范围查找关键字
    if judge == -1:
        return True
    else:
        return False

#通知设置
def main():
    tg_chat_id = "your chat id" #telegram_chat_id
    tg_api_key = "your api key" #telegram_Bot_api_key
    if judge_status(get_html_info()) == True:
        with open(path, 'r') as f:
            send_status=f.read()
        f.close()
        if send_status!='1\n':
            bot = telegram.Bot(token=tg_api_key)
            bot.send_message(chat_id=tg_chat_id, text="检测到VPS补货" + "\n" + "购买地址：" + "\n" + url)
            print('Telgream Send')
            write_config(path,'1\n')
        else:
            print('有货')
    else:
        print('无货') #注意，这只是为了方便测试脚本输出结果，并不是必须的
#循环运行
if __name__ == '__main__':
    while True:
        main()
        time.sleep(300)
