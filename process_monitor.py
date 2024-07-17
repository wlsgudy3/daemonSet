# process_monitor.py

from bcc import BPF

# BPF 프로그램 로드
b = BPF(src_file="process_monitor.c")
b.attach_kprobe(event="do_execve", fn_name="trace_execve")

# 이벤트 핸들러
def print_event(cpu, data, size):
    event = b["events"].event(data)
    print("PID: {}, PPID: {}, Command: {}".format(event.pid, event.ppid, event.comm.decode('utf-8', 'replace')))

# 이벤트 수신
b["events"].open_perf_buffer(print_event)

# 이벤트 처리 루프
while True:
    try:
        b.perf_buffer_poll()
    except KeyboardInterrupt:
        exit()
