FROM archlinux:base

# Prevent pacman from asking questions
ARG DEBIAN_FRONTEND=noninteractive

# System packages
RUN pacman -Sy --noconfirm archlinux-keyring \
 && pacman-key --init \
 && pacman-key --populate archlinux \
 && pacman -Syu --noconfirm base-devel git sudo wget sane glibc

 
# Add a non-root user for yay
RUN useradd -m aur \
 && echo "aur ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch to non-root user for yay installation
USER aur
WORKDIR /home/aur

# Install yay
RUN git clone https://aur.archlinux.org/yay.git \
 && cd yay && makepkg -si --noconfirm --needed

# Install EpsonScan2 plugin from AUR
RUN yay -S --noconfirm --needed epsonscan2-non-free-plugin

# Switch back to root for runtime execution
USER root

# Ensure epsonscan2 backend is registered with sane
RUN mkdir -p /etc/sane.d \
 && grep -qxF 'epsonscan2' /etc/sane.d/dll.conf || echo 'epsonscan2' >> /etc/sane.d/dll.conf

# Default shell
CMD ["/bin/bash"]
