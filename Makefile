all: build

.PHONY: all build install local

IMAGE=$(shell basename $(CURDIR))
CONTAINER=${IMAGE}-tmp
APP=gnome-terminal-3.28.2
PATCHFILE=search_on_google.patch

clean:
	docker rm -f ${CONTAINER}
	docker rmi -f ${IMAGE}
	rm -Rf src

build:
	docker build -t ${IMAGE} --build-arg PATCHFILE .
	docker create --name ${CONTAINER} ${IMAGE}
	mkdir -p binary
	docker cp ${CONTAINER}:/buildroot/${APP}/src/gnome-terminal binary/
	docker cp ${CONTAINER}:/buildroot/${APP}/src/gnome-terminal-server binary/
	docker rm -f ${CONTAINER}
	docker rmi -f ${IMAGE}

install:
	sudo cp binary/gnome-terminal /usr/bin/gnome-terminal.real
	sudo rm -Rf /usr/lib/gnome-terminal/gnome-terminal-server
	sudo cp binary/gnome-terminal-server /usr/lib/gnome-terminal/gnome-terminal-server
	sudo chown root.root /usr/bin/gnome-terminal.real
	sudo chown root.root /usr/lib/gnome-terminal/gnome-terminal-server
	echo "Install complete. Close all terminal windows and open again"

uninstall:
	sudo apt-get --reinstall install gnome-terminal
	echo "Uninstall complete. Close all terminal windows and open again"

local:
	mkdir -p src
	cd src && apt-get -y source gnome-terminal
	cd src && cp -R ${APP} ${APP}-orig
	cd src/${APP} && patch -p1 <../../${PATCHFILE}

patch:
	cd src && diff -rwu ${APP}-orig ${APP}; [ $$? -eq 1 ]

