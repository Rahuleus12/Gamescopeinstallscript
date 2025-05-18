sudo dnf install gcc xcb-util-errors-devel git gcc-c++ cmake meson ninja-build pkgconfig \
libX11-devel libXcomposite-devel libXdamage-devel libXext-devel libXfixes-devel libXrandr-devel \
libXrender-devel libdrm-devel libinput-devel wayland-devel libwayland-cursor libwayland-egl \
libwayland-server wayland-protocols-devel mesa-libEGL-devel mesa-libGL-devel mesa-libgbm-devel \
mesa-vulkan-drivers vulkan-loader-devel vulkan-loader vulkan-tools vulkan-headers systemd-devel \
libXcursor-devel xorg-x11-server-Xwayland xorg-x11-xinit libXxf86vm-devel libXtst-devel libXres-devel \
libXmu-devel libxkbcommon-devel pixman-devel libdecor-devel libseat-devel xcb-util-wm-devel xorg-x11-server-Xwayland-devel glslang-devel luajit-devel gdb libcap-devel perf

#setup everything
sudo dnf remove plasma-discover-notifier
sudo dnf copr enable yohane-shiro/wallpaper-engine-kde-plugin-qt6
sudo dnf install wallpaper-engine-kde-plugin-qt6 kitty fish cargo rust rustup libirecovery
cd ~
cd Programs
sudo dnf install Cider.rpm lact.rpm chrome.rpm compass.rpm
sudo systemctl enable --now lactd
sudo systemctl disable flatpak-add-fedora-repos.service

#add vitualization libraries
sudo dnf install @virtualization
sudo dnf install distrobox podman
sudo dnf install docker
sudo usermod -aG docker $USER

docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:lts

#add vscodium
sudo tee -a /etc/yum.repos.d/vscodium.repo << 'EOF'
[gitlab.com_paulcarroty_vscodium_repo]
name=gitlab.com_paulcarroty_vscodium_repo
baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
metadata_expire=1h
EOF
sudo dnf install codium
sudo dnf install discord
sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)"
