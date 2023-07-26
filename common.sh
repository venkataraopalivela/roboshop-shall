nodejs() {
  log=/tmp/roboshop.log
  echo -e "\e[36m>>>>>>>>>> Create ${component} service file >>>>>>>>>>>\e[0m"
  cp ${component}.service /etc/systemd/system/${component}.service &>>${log}

  echo -e "\e[36m>>>>>>>>>> Create MongoDB Repo file >>>>>>>>>>>\e[0m"
  cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${log}

  echo -e "\e[36m>>>>>>>>>> Install NodeJS repos >>>>>>>>>>>\e[0m"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}

  echo -e "\e[36m>>>>>>>>>> Install NodeJS >>>>>>>>>>>\e[0m"
  yum install nodejs -y &>>${log}

  echo -e "\e[36m>>>>>>>>>> Create application users >>>>>>>>>>>\e[0m"
  useradd roboshop &>>${log}

  echo -e "\e[36m>>>>>>>>>> Cleanup old application repos >>>>>>>>>>>\e[0m"
  rm -rf /app &>>${log}

  echo -e "\e[36m>>>>>>>>>> Create application directory >>>>>>>>>>>\e[0m"
  mkdir /app &>>${log}

  echo -e "\e[36m>>>>>>>>>> Download application content >>>>>>>>>>>\e[0m"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}

  echo -e "\e[36m>>>>>>>>>> Extract application content >>>>>>>>>>>\e[0m"
  cd /app
  unzip /tmp/${component}.zip &>>${log}
  cd /app

  echo -e "\e[36m>>>>>>>>>> Download NodeJS Dependencies >>>>>>>>>>>\e[0m"
  npm install &>>${log}

  echo -e "\e[36m>>>>>>>>>> Install Mongo Client >>>>>>>>>>>\e[0m" | tee -a /tmp/roboshop.log
  yum install mongodb-org-shell -y &>>${log}

  echo -e "\e[36m>>>>>>>>>> Load User Schema >>>>>>>>>>>\e[0m" | tee -a /tmp/roboshop.log
  mongo --host mongodb.adevops14.online </app/schema/${component}.js &>>${log}

  echo -e "\e[36m>>>>>>>>>> Start User Service >>>>>>>>>>>\e[0m" | tee -a /tmp/roboshop.log
  systemctl daemon-reload &>>${log}
  systemctl enable ${component} &>>${log}
  systemctl restart ${component} &>>${log}

}