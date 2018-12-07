# 安装手册 #

1. 将 ilog_install_shells.zip 解压后上传至集群中准备部署 ilog 应用的节点服务器的 /opt/temp 路径下

2. 修改配置文件内容：install_parms 下，每一个组件都对应有一个参数文件，主要包含版本号等信息，目前不需要修改，以后请根据实际情况做调整；根目录下每一个组件都对应有一个配置文件，以 *_config 命名，内容包含了集群节点的具体情况，包括安装路径、节点名称、端口号等信息，请根据实际情况做修改，参数具体说明请随时沟通；

3. 安装前提条件：至少三台 CentOS 7 服务器，并且进行了 hosts 映射配置、免登陆配置、jdk安装配置、安装ntpd、时钟同步、安装 http 服务、关闭 SELinux 等基础环境的配置；

4. 使用 chmod 777 install.sh 给总安装脚本赋权。

5. 根据安装菜单选项进行每一个组件的安装，推荐先安装 mysql 和 tomcat ，以验证脚本在正式环境的正确性，接着以 zookeeper、kafka、elasticsearch、logstash、kafka-logs 的顺序进行集群环境的安装，最后安装 ilog 应用。

6. 注意：需要对 ilog.war 中的相关配置文件根据实际环境修改后再进行安装。