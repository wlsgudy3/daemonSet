#!/bin/bash

# 디버그 정보를 출력
echo "Starting eBPF setup..."

# 필요한 커널 파라미터 설정
sysctl -w kernel.unprivileged_bpf_disabled=0
sysctl -w net.core.bpf_jit_enable=1

# eBPF 프로그램 로드
./syscall_trace_all

# 무한 루프를 추가하여 컨테이너가 종료되지 않도록 함
while :; do
    sleep 3600
done
