#!/bin/bash
sudo mkdir -p /home/ubuntu/MERN
cd /home/ubuntu/MERN/
sudo git clone https://github.com/UnpredictablePrashant/TravelMemory.git
cd TravelMemory/backend/
sudo echo -e "MONGO_URI='mongodb://travelmemoryuser:password@10.0.2.155:27017/travelmemory'\nPORT=3001" >> .env
sudo apt-get update -y && sudo apt-get upgrade -y
sudo curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt-get install -y nodejs
sudo apt-get install npm -y
sudo npm install -g pm2 -y
sudo npm install
sudo pm2 start index.js --name travelmemory-be
cd ../frontend
sudo npm install
AWS_ip=`curl http://checkip.amazonaws.com`
sudo echo -e "export const baseUrl = 'http://$AWS_ip:3001'" > src/url.js
sudo pm2 start --name travelmemory-fe npm -- start
sudo apt-get install nginx -y
echo 'server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}' | sudo tee /etc/nginx/sites-enabled/default >/dev/null

sudo systemctl restart nginx