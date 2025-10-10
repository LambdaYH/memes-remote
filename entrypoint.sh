#!/bin/bash

# 将accessToken写入到.env.prod文件
echo "ONEBOT_ACCESS_TOKEN=$accessToken" > /memes/.env.prod

# 创建配置文件的目录（如果不存在）
mkdir -p /root/.meme_generator

# 将Baidu翻译配置写入到config.toml文件
cat <<EOL > /root/.meme_generator/config.toml
[api]
baidu_trans_appid = "$baiduTransAppid"
baidu_trans_apikey = "$baiduTransApikey"
EOL

# 继续执行其他命令（如果有）
exec "$@"