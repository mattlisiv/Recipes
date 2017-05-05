FROM rethinkdb:latest
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
#Ensure python is installed
RUN python3 -V
#Install Rethink Python Driver
RUN pip3 install rethinkdb

EXPOSE 8080 8080
EXPOSE 28015 28015