FROM ubuntu:18.04
MAINTAINER guangrei <grei@tuta.io>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -qqy curl wget vim build-essential g++ gcc git make python2.7 sshfs zip unzip tzdata > /dev/null

RUN ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

RUN git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it && ~/.bash_it/install.sh > /dev/null

ENV NVM_VERSION v0.33.11
ENV NODE_VERSION 10.14.2
ENV NVM_DIR /usr/local/nvm
RUN mkdir $NVM_DIR
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN echo "source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default" | bash

RUN npm i -g c9 && npm i -g pm2 && npm i -g localtunnel > /dev/null

# get c9 and checkout temp fix for missing plugin
RUN git clone https://github.com/c9/core.git /c9 && \
    cd /c9 && \
    scripts/install-sdk.sh > /dev/null

# use bash during build
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt install -qqy apt python-setuptools python-pip
RUN pip install -U pip
RUN pip install -U virtualenv && \
    virtualenv --python=python2 $HOME/.c9/python2 && \
    source $HOME/.c9/python2/bin/activate
RUN apt update && apt install -y python-dev
RUN mkdir /tmp/codeintel && pip download -d /tmp/codeintel codeintel==0.9.3 > /dev/null

# tambahan

RUN pip install pytz
RUN mkdir -p /root/.c9/script
COPY dtt.py /root/.c9/script/dtt.py
RUN echo "python2 /root/.c9/script/dtt.py" >> ~/.bashrc

RUN echo  | ssh-keygen -t rsa -b 4096 -C "grei@tuta.io" -N ""

RUN wget -q "https://gist.github.com/guangrei/513ecc8cf29ddb2d192deb774fb75462/raw/1dce5eb8fb30df24dd297301079e15e4537467e5/localtunnel.sh" -O /usr/bin/localtunnel && chmod +x /usr/bin/localtunnel

RUN git config --global user.email "grei@tuta.io" && git config --global user.name "grei"

# programing language

RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc && echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bashrc && pip install pipenv > /dev/null

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && cd ~/.rbenv && src/configure && make -C src && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && echo 'eval "$(rbenv init -)"' >> ~/.bashrc > /dev/null

RUN git clone git://github.com/phpenv/phpenv.git ~/.phpenv && echo 'export PATH="$HOME/.phpenv/bin:$PATH"' >> ~/.bashrc && echo 'eval "$(phpenv init -)"' >> ~/.bashrc && git clone https://github.com/php-build/php-build ~/.phpenv/plugins/php-build > /dev/null

RUN git clone https://github.com/syndbg/goenv.git ~/.goenv && echo 'export GOENV_ROOT="$HOME/.goenv"' >> ~/.bashrc && echo 'export PATH="$GOENV_ROOT/bin:$PATH"' >> ~/.bashrc && echo 'eval "$(goenv init -)"' >> ~/.bashrc > /dev/null

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /workspace


ARG c9port=80
ARG user=kira
ARG pass=passwd
ARG workspace="/workspace"

ENV c9port $c9port
ENV user $user
ENV pass $pass
ENV workspace $workspace

EXPOSE 80
VOLUME /workspace
WORKDIR /workspace

CMD pm2-runtime /c9/server.js -- -p $c9port -a $user:$pass --listen 0.0.0.0 -w $workspace