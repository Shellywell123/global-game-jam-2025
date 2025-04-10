FROM docker.io/nickblah/lua:5.4-luarocks-bullseye

RUN apt-get update && apt-get install -y build-essential

# install nodejs
RUN apt install -y nodejs npm

# install pegasus dependencies
RUN apt-get install -y gcc zlib1g-dev libjpeg-dev

# install lua rock packages
RUN luarocks install tl
RUN luarocks install cyan
RUN luarocks install pegasus
RUN luarocks install sha1
RUN luarocks install base64

COPY . .

RUN npm install

RUN npm run build

EXPOSE 26000

CMD ["tl", "run", "teal/server/main.tl"]
