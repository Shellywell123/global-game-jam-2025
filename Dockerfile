FROM nickblah/lua:5.4-luarocks-bullseye

COPY . .

RUN apt-get update && apt-get install -y build-essential

# install nodejs
RUN \
    apt install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_23.x | bash - && \
    apt install -y nodejs


# install pegasus dependencies
RUN apt-get install -y gcc zlib1g-dev libjpeg-dev

# install lua rock packages
RUN luarocks install tl
RUN luarocks install cyan
RUN luarocks install pegasus
RUN luarocks install sha1
RUN luarocks install base64

RUN npm install

RUN npm run build

EXPOSE 8080

CMD ["npm", "start"]
