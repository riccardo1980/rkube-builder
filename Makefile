
TARGETS := galen.img viper-01.img

GALEN_VERSION=4
VIPER_VERSION=3

DEBIAN_VERSION=bullseye

all: $(TARGETS)


utils/image-specs/raspi_%_${DEBIAN_VERSION}.yaml:
	@echo .
	@echo "building $(notdir $@)"
	@echo .
	@make -C utils/image-specs $(notdir $@)


galen.yaml: utils/image-specs/raspi_${GALEN_VERSION}_${DEBIAN_VERSION}.yaml
	@echo
	@echo "building $@ from $^"
	@echo
	@cat $^ | sed 's/rpi_${GALEN_VERSION}-\$$(date +%Y%m%d)/galen/' >$@

viper-%.yaml: utils/image-specs/raspi_${VIPER_VERSION}_${DEBIAN_VERSION}.yaml
	@echo
	@echo "building $@ from $^"
	@echo
	@cat $^ | sed "s/rpi_${VIPER_VERSION}-\$$(date +%Y%m%d)/$(subst .yaml,,$@)/" >$@

%.img: %.yaml
	@echo
	@echo "building $@ from $^"
	@echo
	@touch $(@:.img=.log)
	@time nice vmdb2 --verbose \
		--rootfs-tarball=${DEBIAN_VERSION}.tar.gz \
		--output=$@ $(subst .img,.yaml,$@) \
		--log $(subst .img,.log,$@)
	@chmod 0644 $@ $(@,.img=.log)


.PHONY: clean

clean:
	@rm -f $(TARGETS)
