---
layout: post
title: "阿里云Nginx+uwsgi+Django云服务搭建"
date: 2018-6-25 20:36
comments: true
tags: 
  - 技术
---


#### 环境准备

* 连接服务器
```
ssh root@120.78.181.212  然后输入密码
```
* 上传项目文件

```
目录要提前建好
1.sudo scp -r /Users/wangyang/python/django_demo root@120.78.181.212:/root/python/django_demo
2.通过上传至第三方仓库下载(github)

```
* pip安装
```
sudo apt-get install python-pip
```
* Mysql 安装

```
sudo apt-get install mysql-server
 
apt-get install mysql-client
 
sudo apt-get install libmysqlclient-dev
```

---

* 搭建虚拟环境
>  安装virtualenvwrapper

```
pip install virtualenvwrapper
```

> 查看python命令路径
```
which python     -> /usr/bin/python
which python3    -> /usr/bin/python3
```
> 配置环境变量
```
=>Mac
1.在.bash_profile中加入  
export WORKON_HOME='~/.virtualenvs'
source /usr/local/bin/virtualenvwrapper.sh
2.source .bash_profile
=>Ubutu
1.在.bashrc中加入
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python2.7 # 这句是为了防止环境变量$PATH中已有其它环境的python，需要换成自己需要的python路径
export WORKON_HOME=$HOME/.virtualenvs # 放所有虚拟环境的地方
source /usr/local/bin/virtualenvwrapper.sh
2.source .bashrc
```
> 常用命令

```
 mkvirtualenv py2  创建环境
 mkvirtualenv --python=/usr/local/python3.5.3/bin/python py2  创建环境
 
 workon 查看当前

 workon py2  应用环境
 
 deactivate  退出虚拟环境
 
 rmvirtualenv py2 删除虚拟环境
```
* 依赖安装
 1.首先在本地项目生产依赖目录文件
```
pip freeze>requirements.txt
```
2.在某一环境下安装

```
pip install -r requirements.txt
```
3.创建数据库

```
mysql -uroot -p****** 进入shell
show databases; 显示全部数据库
create database tiantian; 创建数据库
```

4.迁移数据库
```
python manage.py makemigrations
python manage.py migrate
```

* 安装uwsgi

```
pip install uwsgi
```
#### 配置项目文件
* 修改setting.py
```
ALLOWED_HOSTS = ['*', ]

```
* 运行项目
```
python manage.py runserver 0:8000
```
* 访问
```
在浏览器中输入自己服务器对公ip访问
 对公ip:8000
```
* 错误解决（不能访问）
```
1.检查防火墙
 
sudo ufw status # 检查防火墙状态
sudo ufw disable  # 可以临时关闭防火墙
sudo ufw allow 8000 # 或者保持防火墙开启，允许8000端口连接

2.服务器安全组规则
  添加规则： 授权对象 0.0.0.0/0 
  端口范围 7000/8111
```
* 重启服务
```
确认正常后，打开setting.py
DEBUG=False
```
#### 配置uwsgi
* 检查uwsgi服务是否正常
```
创建一个test.py
def application(env, start_response):
    start_response('200 OK', [('Content-Type','text/html')])
    return ["Hello World"]  # python2
    # return [b"Hello World"]  # python3
    
uwsgi --http :8000 --wsgi-file test.py 运行
127.0.0.1：8000  访问
```
* uwsgi 配置
```
项目文件下创建 uwsgi.ini文件
[uwsgi]
# socket = 0:8001 # 使用nginx连接时使用
http = 0:8080 # 直接做web服务器使用

# 项目目录
chdir = /root/django_demo
# 项目中wsgi.py文件的目录
wsgi-file = /root/django_demo/wsgi.py
# 主进程
master = true
# 多进程&多线程
processes = 6
threads = 2
pidfile=uwsgi.pid #可用来停止服务
```
* 命令
```
uwsgi --ini uwsgi.ini 开启服务
uwsgi --stop uwsgi.pid 停止服务
ps ajx|grep uwsgi  查看进程信息
pkill -f -9 uwsgi  强制停止uwsgi
```

#### 配置nginx
* 安装nginx

```
sudo apt-get install nginx
```
* 配置

```
在项目目录下
cp /etc/nginx/uwsgi_params .
```
* 创建 my.nginx.conf
```
upstream django {
    server    127.0.0.1:8001;
    # server      unix://home/python/Desktop/project_test/my_sock.sock;
}

server {
    listen      8000;  # 端口号
    server_name 127.0.0.1;  # 服务器 ip 或是域名
    charset     utf-8;  # 字符集

    # 最大上传限制
    # client_max_body_size 75M;

    location /media  {
        alias /home/python/Desktop/project_test/media_common;  # 媒体文件所在文件夹
    }

    location /static {
        alias /home/python/Desktop/project_test/static_common;  # 静态文件所在文件夹
    }


    # 将所有非媒体请求转到Django服务器上
    location / {
        uwsgi_pass      django;  # 最上方已定义
        # 将所有参数都转到uwsgi下
        include         /home/python/Desktop/project_test/uwsgi_params; # uwsgi_params的路径
    }
}
```
* 建立软链接
```
sudo ln -s /root/django_demo/my_nginx.conf /etc/nginx/sites-enabled/
```
* 创建静态文件
```
先获取目录权限 chmod 666 /root/django_demo
创建文件夹
 mkdir static_common
 mkdir media_common
```
* 修改项目setting.py
```
注释掉 STATIC
STATIC_ROOT = os.path.join(BASE_DIR, 'static_common')
MEDIA_ROOT = os.path.join(BASE_DIR, 'media_common')
```
* 迁移
```
python manage.py collectstatic
```
* 问题解决
静态文件加载不出来
```
1.测试 公网ip:8000/static/admin/css/base.css 是否能加载
 ->如果403 ，先对文件夹申请权限
 ->然后检查 /etc/nginx/nginx_conf 第一行
 --->正确的头应该是  user  root;
2.也可排查log找到具体问题
  /var/log/nginx 目录下会有 access.log error.log文件，打开就可排查
```

#### 其它小问题
 * 端口占用
```
lsof -i:8000 列出端口占用程序

netstat -ap 所有端口

kill -9 PID号 杀掉程序
```
* vi 方向键失效

```
这是因为ubuntu预装的是vim-tiny
步骤一，输入下述命令以卸载vim-tiny：
sudo apt-get remove vim-common
步骤二，输入下述命令以安装vim-full：
sudo apt-get install vim
```
* ubuntu Unable to locate package
```
新系统需要  sudo apt-get update
```

* 配置pip国内源

国内源
```

豆瓣(douban) http://pypi.douban.com/simple/ (推荐) 
清华大学 https://pypi.tuna.tsinghua.edu.cn/simple/ 
阿里云 http://mirrors.aliyun.com/pypi/simple/ 
中国科技大学 https://pypi.mirrors.ustc.edu.cn/simple/ 
中国科学技术大学 http://pypi.mirrors.ustc.edu.cn/simple/ 
```
创建 pip.conf

```
  mkdir ~/.pip
  cd ~/.pip
  touch pip.conf
```
编辑pip.conf,将下面内容copy进文件
```
[global] 
index-url = http://pypi.douban.com/simple 
[install] 
trusted-host=pypi.douban.com
```







