#!/usr/bin/env bash
# Monero Pool Install Script
# By: Rahim Khoja ( rahim@khoja.ca )
#
# Based on zone117x node-cryptonote-pool & fancoder cryptonote-universal-pool
# https://github.com/LoyalNine1487/monero-universal-pool
# https://github.com/fancoder/cryptonote-universal-pool 
# https://github.com/zone117x/node-cryptonote-pool
#
# Requires Ubuntu 16.04
# Installs Node 0.10.48 64-Bit & Redis
#

# System Updates and Pool Requirements
yes | sudo apt -y --force-yes update
yes | sudo apt -y --force-yes upgrade
sudo apt install libssl-dev libboost-all-dev build-essential tcl curl gcc g++ cmake screen -y
sudo apt install libtool autotools-dev autoconf pkg-config libssl-dev
# Install Redis
cd /tmp
curl -O http://download.redis.io/redis-stable.tar.gz
tar xzvf redis-stable.tar.gz
cd redis-stable
make
make test
sudo make install
sudo mkdir /etc/redis
sudo cp /tmp/redis-stable/redis.conf /etc/redis
sudo adduser --system --group --no-create-home redis
sudo mkdir /var/lib/redis
sudo chown redis:redis /var/lib/redis
sudo chmod 770 /var/lib/redis

# Update Redis Files
# Change line that starts with "supervised no" to "supervised systemd"
sudo sed -i 's/supervised no/supervised systemd/g' /etc/redis/redis.conf
# Change line that starts with "dir ./"  to "dir /var/lib/redis"
sudo sed -i 's/dir .\//dir \/var\/lib\/redis/g' /etc/redis/redis.conf

# Install Node 0.10.48
cd /tmp
curl -O https://nodejs.org/download/release/v0.10.48/node-v0.10.48-linux-x64.tar.gz
tar xzvf node-v0.10.48-linux-x64.tar.gz
sudo cp /tmp/node-v0.10.48-linux-x64/bin/node /usr/bin/
sudo cp -R /tmp/node-v0.10.48-linux-x64/lib/* /usr/lib/
sudo ln -s /usr/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm

#Install Monerod
read -p "Do you want to install monerod/monero cli tools (Do ctrl+a,d to close monerod)? (y/n)?" choice
case "$choice" in 
  y|Y ) sudo apt install libtool autotools-dev autoconf pkg-config libssl-dev;
        sudo add-apt-repository ppa:bitcoin/bitcoin;
        apt update; 
        apt install libdb4.8-dev libdb4.8++-dev;
        cd ~;
        mkdir monero;
        wget https://downloads.getmonero.org/cli/monero-linux-x64-v0.11.1.0.tar.bz2;
        tar -xjvf monero-linux-x64-v0.11.0.0.tar.bz2;
        cd monero-v0.11.0.0;
        screen -dmS monero;
        screen -S monero -X screen ./monerod;;
  n|N ) echo "no";;
  * ) echo "invalid, Please say y or n";;
esac

# Install Pool
cd /tmp
git clone -b DEV https://github.com/LoyalNine1487/monero-universal-pool.git pool
sudo mv ./pool /opt/pool
cd /opt/pool
npm update

#Firewall setup
read -p "Do you want to auto config firewall?(No if your using digital ocean) (y/n)?" choice
case "$choice" in 
  y|Y ) sudo ufw allow http;
        sudo ufw allow https;
        sudo ufw allow 3333;
        sudo ufw allow 5555;
        sudo ufw allow 7777;
        sudo ufw allow 8888;;
  n|N ) echo "no";;
  * ) echo "invalid, Please say y or n";;
esac

# You will need to update the config in the fouture
read -p "Do you want to use the example config? (y/n)?" choice
case "$choice" in 
  y|Y ) cp ./config_exmaple.json ./config.json;;
  n|N ) echo "no";;
  * ) echo "invalid, Please say y or n";;
esac
read -p "Use coustom config(Please place config in your home folder) (y/n)?" choice
case "$choice" in 
  y|Y ) cp ~/config.json ./config.json;;
  n|N ) echo "no";;
  * ) echo "invalid, Please say y or n";;
esac

sudo cp ./utils/redis.service /etc/systemd/system/redis.service
sudo systemctl start redis
sudo systemctl enable redis

// run the pool
screen -dmS pool
screen -S monero -X screen node init.js
node init.js
