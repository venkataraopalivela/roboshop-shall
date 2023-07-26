echo -e "\e[36m>>>>>>>>>> Create catalogue service file >>>>>>>>>>>\e[0m"
cp catalogue.service /etc/systemd/system/catalogue.service &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>> Create MongoDB Repo file >>>>>>>>>>>\e[0m"
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>> Install NodeJS repos >>>>>>>>>>>\e[0m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>> Install NodeJS >>>>>>>>>>>\e[0m"
yum install nodejs -y &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>> Create application users >>>>>>>>>>>\e[0m"
useradd roboshop &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>> Cleanup old application repos >>>>>>>>>>>\e[0m"
rm -rf /app &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>> Create application directory >>>>>>>>>>>\e[0m"
mkdir /app &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>> Download application content >>>>>>>>>>>\e[0m"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>> Extract application content >>>>>>>>>>>\e[0m"
cd /app
unzip /tmp/catalogue.zip &>>/tmp/roboshop.log
cd /app

echo -e "\e[36m>>>>>>>>>> Download NodeJS Dependencies >>>>>>>>>>>\e[0m"
npm install &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>> Install Mongo Client >>>>>>>>>>>\e[0m" tee -a /tmp/roboshop.log
yum install mongodb-org-shell -y &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>> Load Catalogue Schema >>>>>>>>>>>\e[0m" tee -a /tmp/roboshop.log
mongo --host mongodb.adevops14.online </app/schema/catalogue.js &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>>> Start Catalogue Service >>>>>>>>>>>\e[0m" | tee -a /tmp/roboshop.log
systemctl daemon-reload &>>/tmp/roboshop.log
systemctl enable catalogue &>>/tmp/roboshop.log
systemctl restart catalogue &>>/tmp/roboshop.log
