
TARGETS := galen.yaml viper.yaml

all: $(TARGETS)

galen.yaml: utils/image-specs/raspi_master.yaml
	@echo "building $@ from pi3"
	@cat $^ | sed "s/__ARCH__/arm64/" | \
	sed "s/__LINUX_IMAGE__/linux-image-arm64/" | \
	sed "s/__EXTRA_PKGS__/- firmware-brcm80211/" | \
	sed "s/__DTB__/\\/usr\\/lib\\/linux-image-*-arm64\\/broadcom\\/bcm*rpi*.dtb/" |\
	sed "s/__OTHER_APT_ENABLE__//" |\
	sed "s/__HOST__/galen/" > $@

viper.yaml:
	@echo "building $@"
	@touch $@

%.img: %.yaml
	@touch $(@:.img=.log)
	@time nice vmdb2 --verbose \
		--rootfs-tarball=$(subst .img,.tar.gz,$@) \
		--output=$@ $(subst .img,.yaml,$@) \
		--log $(subst .img,.log,$@)
	@chmod 0644 $@ $(@,.img=.log)


.PHONY: clean

clean:
	@rm -f $(TARGETS)
