FROM debian:buster

#docker run -p 680:80 -p 6443:443 --name debian-wordpress-blog -it debian:bullseye
#docker run -p 780:80 --name debian-wordpress-blog -it debian:buster

# 使用阿里云debian镜像 https://developer.aliyun.com/mirror/debian
# 更新软件
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak \
    && sed -i -E 's/(deb|security).debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && apt update -y \
    && apt upgrade -y

# 设置时区
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' > /etc/timezone

# 安装常用工具
RUN apt install -y vim git wget curl \
    && apt install -y apt-utils telnet net-tools procps iputils-ping lsb-release

    # systemctl


# 安装最新稳定版nginx
RUN echo "deb http://nginx.org/packages/debian/ $(lsb_release -sc) nginx" >> /etc/apt/sources.list \
    && echo "deb-src http://nginx.org/packages/debian/ $(lsb_release -sc) nginx" >> /etc/apt/sources.list  
RUN apt install -y gnupg2 \
    && curl -s https://nginx.org/keys/nginx_signing.key | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/nginx.gpg --import \
    && chown _apt /etc/apt/trusted.gpg.d/nginx.gpg \
    # 也可以使用apt-key add添加源，不过会有废弃的警告
    # wget http://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key 
    && apt update -y \
     # 此时使用 apt search ^nginx$ 可以看到nginx已经是最新的稳定版本了
    && apt install nginx
    # nginx -v


# 安装php  鉴于wordpress插件大部分不一定支持php8，最好安装php7.4
# debian11默认是php7.4； debian10则需要添加php apt存储库 
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    #&& apt-key add /etc/apt/trusted.gpg.d/php.gpg \
    && apt update -y \
    # 此时使用 apt search php7.4 确认已有php7.4版本
    && apt install -y php7.4 php7.4-fpm
    # php -v
    # php-fpm7.4 -v


# # 安装MySQL APT存储库  安装mysql8.0
# RUN apt install -y lsb-release \
#     && wget https://repo.mysql.com//mysql-apt-config_0.8.23-1_all.deb \
#     && dpkg -i mysql-apt-config_0.8.22-1_all.deb \
#     ## 跟着配置向导，选择mysql8.0，其他disable
#     && rm mysql-apt-config_0.8.22-1_all.deb \
#     && apt update -y \
#     && apt install mysql-community-server
#     # 跟着向导配置mysql
#     # 第一步：设置root密码
#     # 第二步：选择身份认证插件 1. Use Strong Password Encryption (RECOMMENDED)  2. Use Legacy Authentication Method (Retain MySQL 5.x Compatibility)
#     #        这里选择2  （mysql8使用了新的认证插件，为了保持与旧客户端软件的兼容性，将默认身份验证插件设置为旧值）
#     #        #default_authentication_plugin' is deprecated and will be removed in a future release. Please use authentication_policy instead.
#     # 验证 mysql --version
#     # 配置文件 /etc/mysql/mysql.conf.d/mysqld.cnf

# 安装mysql5.7
RUN cd /tmp \
    && wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-server_5.7.39-1debian10_amd64.deb-bundle.tar \
    && tar -xvf mysql-server_5.7.39-1debian10_amd64.deb-bundle.tar \
    # 安装依赖
    && apt install libaio1 libatomic1 libmecab2 libnuma1 psmisc libncurses6 \
    # 依次安装deb
    && dpkg -i mysql-common_5.7.39-1debian10_amd64.deb \
    && dpkg -i mysql-community-client_5.7.39-1debian10_amd64.deb \
    && dpkg -i mysql-client_5.7.39-1debian10_amd64.deb \
    && dpkg -i mysql-community-server_5.7.39-1debian10_amd64.deb \
    # 提示输入密码, 并确认密码
    && dpkg -i mysql-server_5.7.39-1debian10_amd64.deb
    # 配置文件 /etc/mysql/mysql.conf.d/mysqld.cnf

# 启动 nginx php-fpm mysql
RUN service nginx start \
    && service php7.4-fpm start \ 
    && service start mysql

# RUN systemctl start nginx \
#     && systemctl start php7.4-fpm  \ 
#     && systemctl start mysql

# 使用 ps aux 查看进程是都启动


# 安装wordpress源码到/workspace
RUN cd /tmp && wget https://cn.wordpress.org/latest-zh_CN.tar.gz \
    && mkdir /workspace \
    && tar -xvf latest-zh_CN.tar.gz -C /workspace

# 配置nginx
COPY wordpress.conf /tmp/wordpress.conf
COPY nginx.conf /tmp/nginx.conf

RUN cd /etc/nginx \
    # /etc/nginx/nginx.conf
    # 添加server
    && cp /tmp/wordpress.conf /etc/nginx/conf.d/wordpress.conf \
    && cp /tmp/nginx.conf /etc/nginx/nginx.conf \
    # 检查配置是否正确 nginx -t
    && nginx -s reload

# Mysql 创建数据库wordpress 创建用户wordpress并授权
    # mysql -uroot -p
    # CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;
    # CREATE USER 'wordpress'@'%' IDENTIFIED BY '123456';
    # GRANT ALL ON wordpress.* TO 'wordpress'@'%';


# 访问网站
# 报502，查看日志发现 connect() to unix:/run/php/php7.4-fpm.sock failed (13: Permission denied)，php-fpm创建的unix文件用户是www-data，而nginx默认用户是nginx，造成权限问题
# 将 /etc/nginx/nginx.conf 的 user 改为 www-data
# nginx -s reload

# 网站提示：您的PHP似乎没有安装运行WordPress所必需的MySQL扩展。
# 安装php扩展
RUN apt install php7.4-mysqli php7.4-mbstring && service php7.4-fpm restart

# 网站提示：无法写入wp-config.php文件。您可以手工创建wp-config.php文件，并将以下文字粘贴于其中。
# 不想手动写入，一看就是权限问题
RUN chown -R www-data:www-data /workspace/wordpress

# 一切就绪，跟着向导填写数据库连接配置，网站基本配置，等待安装
# 安装成功

# 安装wordpress插件
# KXL Custom Functions -自己编写，解决头像被墙问题
# WP Githuber MD

# 方便起见
# 配置mysql允许任意ip访问，root允许任意ip访问

WORKDIR /workspace
