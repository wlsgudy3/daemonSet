#include <uapi/linux/ptrace.h>
#include <linux/sched.h>
#include <linux/nsproxy.h>
#include <linux/pid_namespace.h>

struct data_t {
    u32 pid;
    char comm[TASK_COMM_LEN];
    u32 mntns;
};

BPF_PERF_OUTPUT(events);

int trace_execve(struct pt_regs *ctx, struct filename *filename) {
    struct data_t data = {};
    struct task_struct *task;
    struct nsproxy *ns;
    struct pid_namespace *pid_ns;

    task = (struct task_struct *)bpf_get_current_task();
    ns = task->nsproxy;
    if (!ns)
        return 0;
    pid_ns = ns->pid_ns_for_children;
    if (!pid_ns)
        return 0;

    data.pid = bpf_get_current_pid_tgid() >> 32;
    data.mntns = task->nsproxy->mnt_ns->ns.inum;
    bpf_get_current_comm(&data.comm, sizeof(data.comm));

    events.perf_submit(ctx, &data, sizeof(data));
    return 0;
}
