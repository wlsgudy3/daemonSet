FROM debian:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    bpfcc-tools \
    libbpfcc-dev \
    linux-headers-amd64 \
    clang \
    llvm \
    gcc \
    make \
    git \
    libelf-dev \
    build-essential \
    wget \
    linux-perf \
    libncurses-dev \
    bison \
    flex \
    libssl-dev \
    bc \
    kmod \
    cpio \
    rsync

# Download and extract the kernel source
WORKDIR /usr/src
RUN wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.tar.xz && \
    tar -xf linux-6.1.tar.xz && \
    mv linux-6.1 linux-source-6.1

# Copy the .config file
COPY .config /usr/src/linux-source-6.1/.config

# Build and install the kernel
WORKDIR /usr/src/linux-source-6.1
RUN make -j$(nproc) && \
    make modules_install && \
    make install

# Clone the program repository
RUN git clone https://github.com/PGHOON/eBPF_syscall.git /eBPF_syscall

# Install libbpf from the cloned repository
RUN cd /eBPF_syscall/libbpf/src && \
    make && make install

# Clone and install bpftool with submodules
RUN git clone --recurse-submodules https://github.com/libbpf/bpftool.git /bpftool && \
    cd /bpftool/src && \
    make && make install

# Build the program
WORKDIR /eBPF_syscall/multiprocess
RUN make

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
