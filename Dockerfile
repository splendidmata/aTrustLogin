FROM hagb/docker-easyconnect:latest
LABEL authors="Kenvix"

ENV TZ="Asia/Shanghai"
COPY ./docker/bin /bin
COPY ./src /opt/atrust-autologin

RUN echo "Begin build" && \
    sed -i 's|http://.*archive.ubuntu.com|https://mirrors.ustc.edu.cn|g; s|http://.*security.ubuntu.com|https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list && \
    mkdir -p ~/.pip && \
    sed -i 's|http://deb.debian.org|https://mirrors.ustc.edu.cn|g; s|http://security.debian.org|https://mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list && \
    echo "[global]" > ~/.pip/pip.conf && \
    echo "index-url = https://mirrors.ustc.edu.cn/pypi/web/simple" >> ~/.pip/pip.conf && \
    apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y chromium chromium-driver chromium-l10n python3 python3-pip && \
    cd /opt/atrust-autologin && \
    pip3 install --break-system-packages -r requirements.txt && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

CMD ["/bin/start-with-autologin.sh"]