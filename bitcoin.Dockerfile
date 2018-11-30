FROM alpine:3.8

# Taking care of glibc shit (glibc not natively supported by Alpine but Bitcoin Core uses it)

ENV GLIBC_VERSION 2.27-r0
ENV GLIBC_SHA256 938bceae3b83c53e7fa9cc4135ce45e04aae99256c5e74cf186c794b97473bc7 
ENV GLIBCBIN_SHA256 3a87874e57b9d92e223f3e90356aaea994af67fb76b71bb72abfb809e948d0d6
# Download and install glibc (https://github.com/jeanblanchard/docker-alpine-glibc/blob/master/Dockerfile)
RUN wget -O /etc/apk/keys/sgerrand.rsa.pub https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/sgerrand.rsa.pub \
 && wget -O glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" \
 && echo "$GLIBC_SHA256  glibc.apk" | sha256sum -c - \
 && wget -O glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" \
 && echo "$GLIBCBIN_SHA256  glibc-bin.apk" | sha256sum -c - \
 && apk add --update --no-cache glibc-bin.apk glibc.apk \
 && /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib \
 && echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf \
 && rm -rf glibc.apk glibc-bin.apk

# Now let's install Bitcoin Core
 
ARG CORE_VERSION="0.17.0" 
ENV TARBALL bitcoin-${CORE_VERSION}-x86_64-linux-gnu.tar.gz 
ENV URL https://bitcoincore.org/bin/bitcoin-core-${CORE_VERSION}

RUN apk add --no-cache \
    curl \
    gnupg

WORKDIR /usr/bin

RUN wget ${URL}/SHA256SUMS.asc \
 && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "01EA5486DE18A882D4C2684590C8019E36C2E964" \
 && gpg --verify SHA256SUMS.asc \
 && wget ${URL}/${TARBALL} \
 && grep ${TARBALL} SHA256SUMS.asc | sha256sum -c - \
 && tar -xzC . -f ${TARBALL} bitcoin-${CORE_VERSION}/bin/bitcoind bitcoin-${CORE_VERSION}/bin/bitcoin-cli --strip-components=2 \
 && rm -rf ${TARBALL} SHA256SUMS.asc \
 && apk del gnupg

#RUN mkdir /bitcoin 

EXPOSE 8332 8333 18332 18333 29000

ENTRYPOINT ["bitcoind"]
