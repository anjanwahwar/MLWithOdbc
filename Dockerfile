FROM oryxprod/python-3.7:20190109.2
LABEL maintainer="appsvc-images@microsoft.com"

RUN apt-get install curl
RUN apt-get install apt-transport-https
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/msprod.list

RUN apt-get update
ENV ACCEPT_EULA=y DEBIAN_FRONTEND=noninteractive
RUN apt-get install mssql-tools unixodbc-dev -y

# Web Site Home
ENV HOME_SITE "/home/site/wwwroot"

#Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        openssh-server \
        vim \
        curl \
        wget \
        tcptraceroute \
        libzbar-dev \
    && pip install --upgrade pip \
    && pip install subprocess32 \
    && pip install gunicorn \ 
    && pip install virtualenv \
    && pip install flask 

RUN apt-get install gcc -y --reinstall build-essential
		
WORKDIR ${HOME_SITE}

EXPOSE 8000
# setup SSH
RUN mkdir -p /home/LogFiles \
     && echo "root:Docker!" | chpasswd \
     && echo "cd /home" >> /etc/bash.bashrc 

COPY sshd_config /etc/ssh/
RUN mkdir -p /opt/startup
COPY init_container.sh /opt/startup/init_container.sh

# setup default site
RUN mkdir /opt/defaultsite
COPY hostingstart.html /opt/defaultsite
COPY application.py /opt/defaultsite
COPY requirements.txt /opt/defaultsite/
COPY SalaryPrediction.pkl /opt/defaultsite/
RUN pip install -r /opt/defaultsite/requirements.txt

# configure startup
RUN chmod -R 777 /opt/startup
COPY hostingstart.html /opt/defaultsite
COPY entrypoint.py /usr/local/bin


ENTRYPOINT ["/opt/startup/init_container.sh"]
