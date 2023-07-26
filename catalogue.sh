echo ">>>>>>>>>> Create catalogue service file >>>>>>>>>>>"
cp catalogue.service /etc/systemd/system/catalogue.service

echo ">>>>>>>>>> Create MongoDB Repo file >>>>>>>>>>>"
cp mongo.repo /etc/yum.repos.d/mongo.repo

echo ">>>>>>>>>> Install NodeJS repos >>>>>>>>>>>"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash

echo ">>>>>>>>>> Install NodeJS >>>>>>>>>>>"
yum install nodejs -y

echo ">>>>>>>>>> Create application users >>>>>>>>>>>"
useradd roboshop

echo ">>>>>>>>>> Create application directory >>>>>>>>>>>"
mkdir /app

echo ">>>>>>>>>> Download application content >>>>>>>>>>>"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip

echo ">>>>>>>>>> Extract application content >>>>>>>>>>>"
cd /app
unzip /tmp/catalogue.zip
cd /app

echo ">>>>>>>>>> Download NodeJS Dependencies >>>>>>>>>>>"
npm install

echo ">>>>>>>>>> Install Mongo Client >>>>>>>>>>>"
yum install mongodb-org-shell -y

echo ">>>>>>>>>> Load Catalogue Schema >>>>>>>>>>>"
mongo --host mongodb.adevops14.online </app/schema/catalogue.js

echo ">>>>>>>>>> Start Catalogue Service >>>>>>>>>>>"
systemctl daemon-reload
systemctl enable catalogue
systemctl restart catalogue
