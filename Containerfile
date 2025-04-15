
# FROM quay.io/almalinuxorg/almalinux-bootc:9.5-20250408
FROM quay.io/fedora/fedora-bootc:41
# based on 
# https://github.com/fledge-iot/fledge/blob/develop/requirements.sh
RUN dnf update -y

RUN dnf install -y git python3 python3-devel postgresql postgresql-devel \
    boost-devel glib2-devel rsyslog openssl-devel \
    numpy wget zlib-devel libuuid-devel \
    krb5-workstation curl-devel cmake3

# Fedora tools
RUN dnf install -y @development-tools
RUN  dnf install -y gcc-c++ autoconf automake libtool

# Alma Tools
# RUN dnf group install -y "Development Tools"
RUN dnf clean all;
ENV SQLITE_PKG_REPO_NAME="sqlite3-pkg"

WORKDIR /tmp
RUN git clone --depth 1 https://github.com/dianomic/${SQLITE_PKG_REPO_NAME}.git ${SQLITE_PKG_REPO_NAME}
WORKDIR /tmp/${SQLITE_PKG_REPO_NAME}/src
RUN ./configure --enable-shared=false --enable-static=true --enable-static-shell CFLAGS="-DSQLITE_MAX_COMPOUND_SELECT=900 -DSQLITE_MAX_ATTACHED=62 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_LOAD_EXTENSION -DSQLITE_ENABLE_COLUMN_METADATA -fno-common -fPIC"
RUN autoreconf -f -i
RUN make && make install

RUN python3 -m pip install --upgrade pip 
RUN pip install setuptools 

WORKDIR /tmp
RUN git clone --depth 1 https://github.com/fledge-iot/fledge.git
WORKDIR /tmp/fledge

RUN make
RUN make install
COPY fledge.sh /etc/fledge/fledge.sh
COPY fledge.service /etc/systemd/system
RUN systemctl enable fledge.service
RUN mkdir -p /etc/fledge/data

RUN dnf install -y nodejs
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/fledge-iot/fledge-gui.git
RUN npm install -g yarn
WORKDIR /tmp/fledge-gui
RUN ./build --clean-start 
RUN mv /tmp/fledge-gui/dist /etc/fledge/gui
COPY nginx.conf /etc/fledge/nginx.conf
RUN dnf install -y nginx
COPY fledge-gui.service /etc/systemd/system
RUN systemctl enable fledge-gui.service


