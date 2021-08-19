TARGET   = bindfs
VERSION  = 0.1.5
CC       ?= xcrun -sdk iphoneos clang
CFLAGS   += -arch arm64 -Os
LDID     ?= ldid
SED      ?= gsed
TXT2MAN  ?= txt2man
INSTALL  ?= install
FAKEROOT ?= fakeroot

.PHONY: all clean

all: clean mount_bindfs mount_bindfs.8
	mkdir com.michael.bindfs_$(VERSION)_iphoneos-arm
	mkdir com.michael.bindfs_$(VERSION)_iphoneos-arm/DEBIAN
	cp control com.michael.bindfs_$(VERSION)_iphoneos-arm/DEBIAN
	$(SED) -i 's/^Version:\x24/Version: $(VERSION)/g' com.michael.bindfs_$(VERSION)_iphoneos-arm/DEBIAN/control
	mkdir com.michael.bindfs_$(VERSION)_iphoneos-arm/sbin
	mkdir -p com.michael.bindfs_$(VERSION)_iphoneos-arm/usr/share/man/man8
	$(INSTALL) -m755 mount_bindfs com.michael.bindfs_$(VERSION)_iphoneos-arm/sbin
	$(INSTALL) -m644 mount_bindfs.8 com.michael.bindfs_$(VERSION)_iphoneos-arm/usr/share/man/man8
	$(FAKEROOT) dpkg -b com.michael.bindfs_$(VERSION)_iphoneos-arm

mount_bindfs: clean
	$(CC) $(CFLAGS) -miphoneos-version-min=14.0 mount_bindfs.c -o mount_bindfs -lutil
	strip mount_bindfs
	$(LDID) -Sentitlements.xml mount_bindfs

mount_bindfs.8:
	$(TXT2MAN) -t 'MOUNT_BINDFS' -s 8 -v 'BSD General Commands Manual' -B mount_bindfs mount_bindfs.8.in > mount_bindfs.8

clean:
	rm -rf com.michael.bindfs_*_iphoneos-arm* mount_bindfs mount_bindfs.8
