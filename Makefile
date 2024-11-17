CROSS_COMPILE?=
CC=$(CROSS_COMPILE)gcc
AR=$(CROSS_COMPILE)ar
LD=$(CROSS_COMPILE)ld

EFI_ARCH?=aa64
SD_BOOT_EFI_PATH:=src/boot
SD_FUNDAMENTAL_PATH:=src/fundamental
SD_TOOLS_PATH:=tools

ELF2EFI:=$(SD_TOOLS_PATH)/elf2efi.py
ELF2EFI_PARAMS=--version-major=257 \
               --version-minor=0 \
               --efi-major=1 \
               --efi-minor=1 \
               --subsystem=10 \
               --minimum-sections=45 \
               --copy-sections=.sbat,.sdmagic,.osrel

UKIFY:=src/ukify/ukify.py

CFLAGS=-mgeneral-regs-only \
       -fdiagnostics-color=always \
       -D_FILE_OFFSET_BITS=64 \
       -std=gnu11 \
       -O0 \
       -g \
       -fdiagnostics-show-option \
       -fno-common \
       -fstack-protector \
       -fstack-protector-strong \
       -fstrict-flex-arrays=3 \
       --param=ssp-buffer-size=4 \
       -DSD_BOOT=1 \
       -DEFI_MACHINE_TYPE_NAME="\"$(EFI_ARCH)\"" \
       -ffreestanding \
       -fno-strict-aliasing \
       -fshort-wchar \
       -fwide-exec-charset=UCS2 \
       -mstack-protector-guard=global \
       -fcf-protection=none \
       -fno-asynchronous-unwind-tables \
       -fno-exceptions \
       -fno-unwind-tables \
       -fno-sanitize=all \
       -fvisibility=hidden \
       -fPIC \
       -include ../systemd/builddir/src/boot/efi/efi_config.h \
       -I../systemd/builddir \
       -I$(SD_FUNDAMENTAL_PATH) \
       -I$(SD_BOOT_EFI_PATH)

CFLAGS += \
       -Wall \
       -Winvalid-pch \
       -Wextra \
       -Werror \
       -Wno-missing-field-initializers \
       -Wno-unused-parameter \
       -Wno-nonnull-compare \
       -Warray-bounds \
       -Warray-bounds=2 \
       -Wdate-time \
       -Wendif-labels \
       -Werror=format=2 \
       -Werror=format-signedness \
       -Werror=implicit-function-declaration \
       -Werror=implicit-int \
       -Werror=incompatible-pointer-types \
       -Werror=int-conversion \
       -Werror=missing-declarations \
       -Werror=missing-prototypes \
       -Werror=overflow \
       -Werror=override-init \
       -Werror=return-type \
       -Werror=shift-count-overflow \
       -Werror=shift-overflow=2 \
       -Werror=undef \
       -Wfloat-equal \
       -Wimplicit-fallthrough=5 \
       -Winit-self \
       -Wlogical-op \
       -Wmissing-include-dirs \
       -Wmissing-noreturn \
       -Wnested-externs \
       -Wold-style-definition \
       -Wpointer-arith \
       -Wredundant-decls \
       -Wshadow \
       -Wstrict-aliasing=2 \
       -Wstrict-prototypes \
       -Wsuggest-attribute=noreturn \
       -Wunused-function \
       -Wwrite-strings \
       -Wzero-length-bounds \
       -Wno-unused-result \
       -Werror=shadow

LDFLAGS=-lgcc \
        -nostdlib \
        -static-pie \
        -Wl,--entry=efi_main \
        -Wl,--fatal-warnings \
        -Wl,-static,-pie,--no-dynamic-linker,-z,text \
        -z common-page-size=4096 \
        -z max-page-size=4096 \
        -z noexecstack \
        -z relro \
        -z separate-code

LIBEFI_FILES = chid.c \
               console.c \
               device-path-util.c \
               devicetree.c \
               drivers.c \
               efi-string.c \
               efivars.c \
               export-vars.c \
               graphics.c \
               initrd.c \
               log.c \
               measure.c \
               part-discovery.c \
               pe.c \
               random-seed.c \
               secure-boot.c \
               shim.c \
               smbios.c \
               ticks.c \
               util.c \
               vmm.c

LIBEFI_SRC=$(addprefix $(SD_BOOT_EFI_PATH)/,$(LIBEFI_FILES))
LIBEFI_OBJ=$(addprefix build/,$(LIBEFI_SRC:.c=.o))

STUB_FILES=cpio.c \
           linux.c \
           splash.c \
           stub.c

STUB_SRC=$(addprefix $(SD_BOOT_EFI_PATH)/,$(STUB_FILES))
STUB_OBJ=$(addprefix build/,$(STUB_SRC:.c=.o))

LIBFUNDAMENTAL_FILES=bootspec-fundamental.c \
                     chid-fundamental.c \
                     efivars-fundamental.c \
                     sha1-fundamental.c \
                     sha256-fundamental.c \
                     string-util-fundamental.c \
                     uki.c

LIBFUNDAMENTAL_SRC=$(addprefix $(SD_FUNDAMENTAL_PATH)/,$(LIBFUNDAMENTAL_FILES))
LIBFUNDAMENTAL_OBJ=$(addprefix build/,$(LIBFUNDAMENTAL_SRC:.c=.o))

all: build/linux$(EFI_ARCH).efi.stub build/linux$(EFI_ARCH).elf.stub

build:
	mkdir -p $@

build/%.o: %.c
	@ mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $< $(LDFLAGS)

build/libefi.a: $(LIBEFI_OBJ)
	$(AR) rcs $@ $^

build/libfundamental.a: $(LIBFUNDAMENTAL_OBJ)
	$(AR) rcs $@ $^

build/%.elf.stub: $(STUB_OBJ) build/libefi.a build/libfundamental.a
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

build/%.efi.stub: build/%.elf.stub
	python $(ELF2EFI) $(ELF2EFI_PARAMS) $< $@
	@echo Built $@ successfully

linux-%.efi: %.conf build/linux$(EFI_ARCH).efi.stub
	python $(UKIFY) build --config $< --uname="$(shell uname -r)" -o $@
