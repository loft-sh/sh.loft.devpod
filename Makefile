OS := $(shell uname)
.PHONY: install sources flatpak bundle clean

install:
	flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak --user install flathub -y org.flatpak.Builder \
		org.gnome.Platform//46 \
		org.gnome.Sdk//46 \
		org.freedesktop.Platform//22.08 \
		org.freedesktop.Sdk//22.08 \
		runtime/org.freedesktop.Sdk.Extension.rust-stable/x86_64/23.08 \
		runtime/org.freedesktop.Sdk.Extension.golang/x86_64/23.08 \
		runtime/org.freedesktop.Sdk.Extension.node20/x86_64/23.08
	pipx install "git+https://github.com/flatpak/flatpak-builder-tools.git#egg=flatpak_node_generator&subdirectory=node"
	wget -N https://raw.githubusercontent.com/flatpak/flatpak-builder-tools/master/cargo/flatpak-cargo-generator.py
	python3 -m venv .pyenv
	sh -c ". .pyenv/bin/activate && python3 -m pip install aiohttp toml"

sources:
	sh -c ". .pyenv/bin/activate && python3 flatpak-cargo-generator.py -o cargo-sources.json ../devpod/desktop/src-tauri/Cargo.lock"
	flatpak-node-generator -r -o node-sources.json yarn ../devpod/desktop/yarn.lock

flatpak:
	rm -rf .flatpak-builder/build/Devpod*/
	flatpak build-init .flatpak-builder sh.loft.devpod org.freedesktop.Sdk//22.08 org.freedesktop.Platform//22.08 || :
	flatpak-builder --disable-rofiles-fuse --keep-build-dirs --user --install --force-clean build sh.loft.devpod.yml --repo=.repo

# flatpak run sh.loft.devpod --keep

bundle:
	flatpak build-bundle .repo sh.loft.devpod.flatpak sh.loft.devpod

clean:
	rm -rf .flatpak-builder build/
