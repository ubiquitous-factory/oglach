
# FROM quay.io/almalinuxorg/almalinux-bootc:9.5-20250408
FROM quay.io/fedora/fedora-bootc:41 as build
# based on 
# https://github.com/fledge-iot/fledge/blob/develop/requirements.sh
RUN dnf update -y

RUN dnf install -y git python3 python3-devel postgresql postgresql-devel \
    boost-devel glib2-devel rsyslog openssl-devel \
    numpy wget zlib-devel libuuid-devel \
    krb5-workstation curl-devel cmake3 nginx nodejs gcc-c++ autoconf automake libtool

# Fedora tools
RUN dnf install -y @development-tools

# Alma Tools
# RUN dnf group install -y "Development Tools"
RUN dnf clean all;


# Install sqllite
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

# Configure fledge
COPY fledge.service /etc/systemd/system
RUN systemctl enable fledge.service
RUN mkdir -p /etc/fledge/data

# Build frontend system
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/fledge-iot/fledge-gui.git
RUN npm install -g yarn
WORKDIR /tmp/fledge-gui
RUN ./build --clean-start 
RUN mv /tmp/fledge-gui/dist /etc/fledge/gui
COPY nginx.conf /etc/fledge/nginx.conf
COPY fledge-gui.service /etc/systemd/system
RUN systemctl enable fledge-gui.service
RUN rm -fr /tmp/*

FROM quay.io/fedora/fedora-bootc:41

RUN dnf update -y

RUN dnf install -y python3 python3-devel postgresql \
    boost glib2 rsyslog openssl \
    numpy wget zlib  libuuid \
    krb5-workstation curl nginx
RUN dnf clean all;

RUN python3 -m pip install --upgrade pip 
RUN pip install setuptools 
RUN pip install aiohttp
# COPY --from=build /usr/local/include/sqlite3.h /usr/local/include/sqlite3.h
COPY --from=build /usr/local/bin/sqlite3 /usr/local/bin/sqlite3
COPY --from=build /usr/local/lib/libsqlite3.la /usr/local/lib/libsqlite3.la
COPY --from=build /usr/local/lib/libsqlite3.a /usr/local/lib/libsqlite3.a
COPY --from=build /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=build /usr/local/fledge /usr/local/fledge
COPY --from=build /usr/local/fledge/data /etc/fledge/data
COPY --from=build  /etc/fledge/gui  /etc/fledge/gui

RUN chmod 644 /usr/local/lib/libsqlite3.a

COPY nginx.conf /etc/fledge/nginx.conf
COPY fledge-gui.service /etc/systemd/system
RUN systemctl enable fledge-gui.service

COPY fledge.service /etc/systemd/system
RUN systemctl enable fledge.service

COPY startup/startup.service /etc/systemd/system
RUN mkdir -p /etc/oglach
COPY startup/startup.sh /etc/oglach/startup.sh
RUN chmod +x /etc/oglach/startup.sh
RUN systemctl enable startup.service
RUN touch /etc/oglach/oglach.run