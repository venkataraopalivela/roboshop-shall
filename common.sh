log=/tmp/roboshop.log

func_apppreq() {
    echo -e "\e[36m>>>>>>>>>> Create ${component} service file >>>>>>>>>>>\e[0m"
    cp ${component}.service /etc/systemd/system/${component}.service &>>${log}
    echo $?

    echo -e "\e[36m>>>>>>>>>> Create application users >>>>>>>>>>>\e[0m"
    useradd roboshop &>>${log}
    echo $?

    echo -e "\e[36m>>>>>>>>>> Cleanup old application repos >>>>>>>>>>>\e[0m"
    rm -rf /app &>>${log}
    echo $?

    echo -e "\e[36m>>>>>>>>>> Create application directory >>>>>>>>>>>\e[0m"
    mkdir /app &>>${log}
    echo $?

    echo -e "\e[36m>>>>>>>>>> Download application content >>>>>>>>>>>\e[0m"
    curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}
    echo $?
    echo -e "\e[36m>>>>>>>>>> Extract application content >>>>>>>>>>>\e[0m"
    cd /app
    echo $?
    unzip /tmp/${component}.zip &>>${log}
    cd /app
}

func_systemd() {
  echo -e "\e[36m>>>>>>>>>> Start ${component} Service >>>>>>>>>>>\e[0m" | tee -a /tmp/roboshop.log
    systemctl daemon-reload &>>${log}
    systemctl enable ${component} &>>${log}
    systemctl restart ${component} &>>${log}
    echo $?
}
func_schema_setup() {
  if [ "${schema_type}" == "mongodb" ]; then
    echo -e "\e[36m>>>>>>>>>> Install Mongo Client >>>>>>>>>>>\e[0m" | tee -a /tmp/roboshop.log
    yum install mongodb-org-shell -y &>>${log}
    echo $?

    echo -e "\e[36m>>>>>>>>>> Load User Schema >>>>>>>>>>>\e[0m" | tee -a /tmp/roboshop.log
    mongo --host mongodb.adevops14.online </app/schema/${component}.js &>>${log}
    echo $?
  fi

  if [  "${Schema_type}" == "mysql" ]; then
      echo -e "\e[36m>>>>>>>>>> Install MySQL client  >>>>>>>>>>>\e[0m"
      yum install mysql -y &>>${log}
      echo $?

      echo -e "\e[36m>>>>>>>>>> Load Schema  >>>>>>>>>>>\e[0m"
      mysql -h mysql.adevops14.online -uroot -pRoboShop@1 < /app/schema/${component}.sql &>>${log}
      echo $?
  fi
}

func_nodejs() {
  log=/tmp/roboshop.log

  echo -e "\e[36m>>>>>>>>>> Create MongoDB Repo file >>>>>>>>>>>\e[0m"
  cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${log}
  if [ $? -eq 0 ]; then
    echo -e "\e[32m SUCCESS \e[0m"
  else
    echo -e "\e[31m FAILURE \e[0m"
  fi

  echo -e "\e[36m>>>>>>>>>> Install NodeJS repos >>>>>>>>>>>\e[0m"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}
  echo $?

  echo -e "\e[36m>>>>>>>>>> Install NodeJS >>>>>>>>>>>\e[0m"
  yum install nodejs -y &>>${log}
  echo $?

  func_apppreq

  echo -e "\e[36m>>>>>>>>>> Download NodeJS Dependencies >>>>>>>>>>>\e[0m"
  npm install &>>${log}
  echo $?

  func_schema_setup

  func_systemd
}

func_java() {

  echo -e "\e[36m>>>>>>>>>> Install Mavan >>>>>>>>>>>\e[0m"
  yum install maven -y &>>${log}
  echo $?

  func_apppreq

  echo -e "\e[36m>>>>>>>>>> Build ${component} service  >>>>>>>>>>>\e[0m"
  mvn clean package &>>${log}
  mv target/${component}-1.0.jar ${component}.jar &>>${log}
  echo $?
  func_schema_setup

  func_systemd
}

func_python() {

  echo -e "\e[36m>>>>>>>>>> Build ${component} service  >>>>>>>>>>>\e[0m"
  yum install python36 gcc python3-devel -y &>>${log}
  echo $?
  func_apppreq

  echo -e "\e[36m>>>>>>>>>> Build ${component} service  >>>>>>>>>>>\e[0m"
  pip3.6 install -r requirements.txt &>>${log}
  echo $?
  func_systemd
}