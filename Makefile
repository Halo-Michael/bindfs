TARGET = bindfs
VERSION = 0.1.4
CC = xcrun -sdk iphoneos clang -arch arm64 -Os
LDID = ldid
SED = gsed

.PHONY: all clean

all: clean mount_bindfs
	mkdir com.michael.bindfs_$(VERSION)_iphoneos-arm
	mkdir com.michael.bindfs_$(VERSION)_iphoneos-arm/DEBIAN
	cp control com.michael.bindfs_$(VERSION)_iphoneos-arm/DEBIAN
	$(SED) -i 's/^Version:\x24/Version: $(VERSION)/g' com.michael.bindfs_$(VERSION)_iphoneos-arm/DEBIAN/control
	mkdir com.michael.bindfs_$(VERSION)_iphoneos-arm/sbin
	mv mount_bindfs com.michael.bindfs_$(VERSION)_iphoneos-arm/sbin
	dpkg -b com.michael.bindfs_$(VERSION)_iphoneos-arm

mount_bindfs: clean
	$(CC) -miphoneos-version-min=14.0 mount_bindfs.c -o mount_bindfs -lutil
	strip mount_bindfs
	$(LDID) -Sentitlements.xml mount_bindfs

clean:
	rm -rf com.michael.bindfs_*_iphoneos-arm* mount_bindfs
