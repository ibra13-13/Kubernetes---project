FROM node:18

WORKDIR /usr/src/app

COPY package*.json .

RUN npm install

COPY . .

ENV PORT=3001 \
    DB=hello \
    DBUSER=kaizen \
    DBPASS=kaizen123 \
    DBHOST=database-1-instance-1.c2stnmbcgxuw.us-east-2.rds.amazonaws.com \
    DBPORT=3306

EXPOSE 3001

CMD ["npm","start"]

