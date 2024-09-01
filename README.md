# Quick Start

Install dependencies:
```
pacman -S acl cryptsetup docbook-xsl gperf lz4 xz pam libelf intltool kmod libarchive libcap libidn2 libgcrypt libmicrohttpd libxcrypt libxslt util-linux linux-api-headers python-jinja python-lxml quota-tools shadow git meson libseccomp pcre2 audit kexec-tools libxkbcommon bash-completion p11-kit systemd libfido2 tpm2-tss rsync bpf libbpf clang llvm curl gnutls python-pyelftools libpwquality qrencode python-pefile
```
Clone and build:
```console
git clone https://github.com/anonymix007/systemd-stub
git clone https://github.com/anonymix007/systemd -b multiple-dt
cd systemd
meson setup -Dbootloader=enabled builddir
meson compile -C builddir version.h
cd ../systemd-stub
make EFI_ARCH=aa64
```
