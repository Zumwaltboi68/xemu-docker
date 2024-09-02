# Use Ubuntu as the base image
FROM ubuntu:latest

# Set environment variables to prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install required dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libsdl2-dev \
    libepoxy-dev \
    libpixman-1-dev \
    libgtk-3-dev \
    libssl-dev \
    libsamplerate0-dev \
    libpcap-dev \
    ninja-build \
    python3-yaml \
    libslirp-dev \
    wget \
    novnc \
    websockify \
    x11vnc \
    xvfb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone the xemu repository from GitHub
RUN git clone https://github.com/mborgerson/xemu.git /xemu

# Set the working directory to the xemu directory
WORKDIR /xemu

# Build xemu using the provided build script
RUN ./build.sh

# Expose port 8080 for web access
EXPOSE 8080

# Start the VNC server, websockify, and xemu
CMD xvfb-run --server-args="-screen 0 1024x768x24" \
    x11vnc -display :99 -forever -shared -rfbport 5900 -nolookup -nopw & \
    websockify --web=/usr/share/novnc/ 8080 localhost:5900 & \
    ./dist/xemu
