# aTrustLogin

本项目提供了一个自动化的深信服 Sangfor aTrust 登录的解决方案，无需人工干预即可实现 VPN 联网。项目功能如下：

- 自动打开 aTrust Web 登录页面
- 自动填写用户名和密码
- 自动利用密钥推导 TOTP 两步验证并填写
- 使用 Cookie 状态绕过验证码
- KeepAlive 连接保活和掉线/登出重连
- 支持 Windows、Linux，支持 x86-64 和 ARM64

## 使用方法
本项目提供Docker方法和通用方法两种方法。

Docker 方法只适用于 Linux 平台，但无需安装配置任何依赖，全自动运行，只需安装 Docker 即可。非常适合软路由、工控机等无图形界面的环境使用。

通用方法适合于所有平台，但需要手动安装 Python 3.8+ 和 Selenium 等依赖库。如果有条件，请使用 Docker 方法。

### 通用方法

首先需要配置浏览器。

在 Windows 下，默认使用系统自带的 Microsoft Edge 浏览器，因此对于 Windows 10 1903+、Windows 11 通常不需要额外安装浏览器和浏览器驱动。如果需要使用其他浏览器，请参考 [Selenium 文档](https://www.selenium.dev/documentation/en/webdriver/driver_requirements/) 安装对应的浏览器驱动。

在 Linux 下，需要安装 Chromium 浏览器。Debian/Ubuntu 可以使用 `apt-get install -y chromium chromium-driver chromium-l10n` 命令直接安装。

然后，下载本项目，安装依赖库。提供国内地址和国外地址两个下载方法。如果国外地址下载缓慢，可以使用国内地址：

国外地址：

```shell
# 如果下载缓慢，可以替换为国内地址 （见后文）
git clone --depth=1 https://github.com/kenvix/aTrustLogin.git aTrustLogin
cd aTrustLogin/src
pip install -r requirements.txt
```

国内地址：

```shell
git clone https://www.modelscope.cn/kenvix/aTrustLogin.git
cd aTrustLogin/src
pip install -r requirements.txt -i https://mirrors.ustc.edu.cn/pypi/web/simple
```

### Docker 方法
