#basierend auf https://www.bro.org/sphinx/install/install.html
#dieses skript muss aus dem verzeichnis ausgeführt werden
set -e
err_report() {
    echo "Error on line $1"
}

trap 'err_report $LINENO' ERR



# Verwende google-nameserver, andere machen Probleme
. config
sudo cp rsyslog_bro.conf /etc/rsyslog.d/rsyslog_bro.conf

#sudo sed -ir 's/[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/8.8.8.8/g' /etc/resolv.conf
sudo apt update
sudo apt-get -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev

export CC=clang34
export CXX=clang++34
export CXXFLAGS="-stdlib=libc++ -I${LOCALBASE}/include/c++/v1 -L${LOCALBASE}/lib"
export LDFLAGS="-pthread"

git clone --recursive https://github.com/bro/bro.git
cd bro
sudo ./configure && sudo make && sudo make install
#edit variables into bro configs
sudo sed -i "1 i $HOME_NET" /usr/local/zeek/etc/networks.cfg
sudo sed -i "s/interface=eth0/interface=$BRO_INTERFACE/g" /usr/local/zeek/etc/node.cfg

#edit variables into rsyslog
sudo sed -i "s/BRO_RSYSLOG_FACILITY/$BRO_RSYSLOG_FACILITY/g" /etc/rsyslog.d/rsyslog_bro.conf
sudo sed -i "s/GRAYLOG_IP/$GRAYLOG_IP/g" /etc/rsyslog.d/rsyslog_bro.conf
sudo sed -i "s/GRAYLOG_BRO_PORT/$GRAYLOG_BRO_PORT/g" /etc/rsyslog.d/rsyslog_bro.conf
sudo systemctl restart rsyslog.service

#verwende deploy, start crasht
#sudo /usr/local/bro/bin/broctl deploy
