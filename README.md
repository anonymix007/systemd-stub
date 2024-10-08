# Quick Start

Install dependencies:
```
pacman -S acl cryptsetup docbook-xsl gperf lz4 xz pam libelf intltool kmod libarchive libcap libidn2 libgcrypt libmicrohttpd libxcrypt libxslt util-linux linux-api-headers python-jinja python-lxml quota-tools shadow git meson libseccomp pcre2 audit kexec-tools libxkbcommon bash-completion p11-kit systemd libfido2 tpm2-tss rsync bpf libbpf clang llvm curl gnutls python-pyelftools libpwquality qrencode python-pefile
```
Clone and build stub:
```console
git clone https://github.com/anonymix007/systemd-stub
git clone https://github.com/anonymix007/systemd -b multiple-dt
cd systemd
meson setup -Dbootloader=enabled builddir
meson compile -C builddir version.h
cd ../systemd-stub
make EFI_ARCH=aa64 CROSS_COMPILE=aarch64-linux-gnu-
```
And then build UKI:
```console
python src/ukify/ukify.py build --config x1e.conf -o linux-x1e.efi
# Or on the device itself:
make linux-x1e.efi
```

## Credits
- `hwids/*.txt`: (dtbloader)[https://github.com/TravMurav/dtbloader/tree/main/scripts/hwids]
