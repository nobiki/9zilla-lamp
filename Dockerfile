FROM debian:jessie
MAINTAINER Naoaki Obiki
ARG username="9zilla"
ARG password="9zilla"
RUN apt-get update
RUN apt-get install -y make gcc g++
RUN apt-get install -y vim git tig unzip tree sed bash-completion dbus sudo openssl curl wget expect cron
RUN apt-get install -y vim dnsutils procps siege pandoc locales dialog htop inetutils-traceroute iftop bmon iptraf nload slurm sl toilet lolcat
RUN mkdir /home/$username
RUN useradd -s /bin/bash -d /home/$username $username && echo "$username:$password" | chpasswd
RUN echo ${username}' ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/$username
RUN mkdir -p /home/$username/ci/
RUN chown -R $username:$username /home/$username
RUN mkdir /var/workspace/
RUN ln -s /var/workspace/ /home/$username/workspace
RUN chown $username:$username /home/$username/workspace
RUN locale-gen ja_JP.UTF-8
RUN localedef -f UTF-8 -i ja_JP ja_JP
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:jp
ENV LC_ALL ja_JP.UTF-8
RUN cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN apt-get install -y chrony
RUN sed -ri "s/^server 0.debian.pool.ntp.org/#server 0.debian.pool.ntp.org/" /etc/chrony/chrony.conf
RUN sed -ri "s/^server 1.debian.pool.ntp.org/#server 1.debian.pool.ntp.org/" /etc/chrony/chrony.conf
RUN sed -ri "s/^server 2.debian.pool.ntp.org/#server 2.debian.pool.ntp.org/" /etc/chrony/chrony.conf
RUN sed -ri "s/^server 3.debian.pool.ntp.org/#server 3.debian.pool.ntp.org/" /etc/chrony/chrony.conf
RUN echo "server ntp0.jst.mfeed.ad.jp" >> /etc/chrony/chrony.conf
RUN echo "server ntp1.jst.mfeed.ad.jp" >> /etc/chrony/chrony.conf
RUN echo "server ntp2.jst.mfeed.ad.jp" >> /etc/chrony/chrony.conf
RUN echo "allow 172.18/12" >> /etc/chrony/chrony.conf
RUN systemctl enable chrony
RUN sudo -u $username mkdir -p /home/$username/gitwork/bitbucket/dotfiles/
RUN sudo -u $username git clone "https://nobiki@bitbucket.org/nobiki/dotfiles.git" /home/$username/gitwork/bitbucket/dotfiles/
RUN sudo -u $username cp /etc/bash.bashrc /home/$username/.bashrc
RUN sudo -u $username cp /home/$username/gitwork/bitbucket/dotfiles/.bash_profile /home/$username/.bash_profile
RUN sudo -u $username cp /home/$username/gitwork/bitbucket/dotfiles/.gitconfig /home/$username/.gitconfig
RUN sudo -u $username mkdir -p /home/$username/.ssh/
RUN sudo -u $username cp /home/$username/gitwork/bitbucket/dotfiles/.ssh/config /home/$username/.ssh/config
RUN curl -o /usr/local/bin/jq "http://stedolan.github.io/jq/download/linux64/jq"
RUN chmod +x /usr/local/bin/jq
ADD archives/peco_linux_amd64/peco /usr/local/bin/
RUN chmod +x /usr/local/bin/peco
RUN git clone "https://github.com/b4b4r07/enhancd.git" /usr/local/src/enhancd
RUN chmod +x /usr/local/src/enhancd/init.sh
RUN echo 'source /usr/local/src/enhancd/init.sh' >> /home/$username/.bash_profile
RUN apt-get install -y php5 php5-dev php5-cgi php5-cli php5-curl php5-mongo php5-mysql php5-memcache php5-mcrypt mcrypt php5-readline php5-json php5-imagick imagemagick php5-oauth
RUN systemctl disable apache2
RUN curl -sS "https://getcomposer.org/installer" | php -- --install-dir=/usr/local/bin
RUN apt-get install -y apache2
RUN a2enmod rewrite ssl proxy status setenvif unique_id
RUN a2dismod userdir
RUN a2dissite 000-default default-ssl
RUN mkdir -p /var/virtualdomains/example.local/
RUN echo "example.local" > /var/virtualdomains/example.local/index.html
RUN chown -R $username:$username /var/virtualdomains/
RUN mkdir -p /var/log/apache2/vhost/
RUN chmod 755 /var/log/apache2/
RUN chmod 755 /var/log/apache2/vhost/
ADD settings/apache2/example.conf /etc/apache2/sites-available/
RUN a2ensite example
RUN systemctl enable apache2
ADD settings/nvm/nvm_install.sh /home/$username/
RUN chmod +wx /home/$username/nvm_install.sh
RUN apt-get install -y mariadb-client libmysqlclient-dev
RUN apt-get install -y xvfb
RUN echo "Xvfb :99 -screen 0 1920x1200x24 > /dev/null &" > /usr/local/bin/selenium-xvfb
RUN chmod +x /usr/local/bin/selenium-xvfb
RUN wget -q -O - "https://dl-ssl.google.com/linux/linux_signing_key.pub" | apt-key add -
RUN echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update
RUN apt-get install -y google-chrome-stable
RUN apt-get install -y firefox-esr
RUN apt-get install -y php5 php5-curl php5-imagick imagemagick
RUN systemctl disable apache2
RUN curl -sS "https://getcomposer.org/installer" | php -- --install-dir=/usr/local/bin
RUN apt-get install -y default-jdk
ADD archives/selenium-server-standalone.jar /usr/local/bin/
RUN echo "DISPLAY=:99 java -jar /usr/local/bin/selenium-server-standalone.jar -Dwebdriver.chrome.driver=/usr/local/lib/selenium/chromedriver" > /usr/local/bin/selenium
RUN chmod +x /usr/local/bin/selenium
RUN mkdir /usr/local/lib/selenium
ADD archives/chromedriver /usr/local/lib/selenium/
RUN mkdir -p /usr/local/lib/behat/
ADD settings/behat/composer.json /usr/local/lib/behat/
ADD settings/behat/behat.yml /usr/local/lib/behat/
RUN chown -R $username:$username /usr/local/lib/behat/
RUN ln -s /usr/local/lib/behat/bin/behat /usr/local/bin/behat
RUN ln -s /usr/local/lib/behat/ /home/$username/ci/behat
