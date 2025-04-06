# Makefile for building and running the Larawan Flatpak application

.PHONY: start build install remove debug rebuild restart rebuild-debug

start:
	G_MESSAGES_DEBUG=all flatpak run --runtime=io.elementary.Platform/x86_64/8.1 io.github.xchan14.larawan

build:
	flatpak-builder build io.github.xchan14.larawan.yml --user --install --force-clean;

install: 
	flatpak-builder install io.github.xchan14.larawan.yml --user --install --force-clean;

restart:
	make build && make start

remove: 
	if flatpak list | grep -q io.github.xchan14.larawan; then \
		flatpak remove io.github.xchan14.larawan --user --delete-data -y; \
	else \
		echo "Flatpak app io.github.xchan14.larawan is not installed."; \
	fi

debug:
	flatpak run --command=sh --devel --runtime=io.elementary.Platform/x86_64/8.1 io.github.xchan14.larawan
	
rebuild:
	make remove && make build 

rebuild-debug:
	make rebuild && make debug

install-dev-tools:
	sudo apt install libgranite-dev uncrustify

update-sdk-runtime:
	flatpak update --reinstall io.elementary.Platform/x86_64/8.1 \
	flatpak update --reinstall io.elementary.sdk/x86_64/8.1