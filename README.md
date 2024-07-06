# Custom System Calls and Scheduling in xv6

## Overview

This project extends the xv6 operating system by implementing custom system calls and alternative scheduling policies. The primary objectives are to:

1. Add system calls `getreadcount`, `sigalarm`, and `sigreturn`.
2. Implement two new scheduling policies: First-Come-First-Serve (FCFS) and Multi-Level Feedback Queue (MLFQ).
## Resources
- [Insturctions](https://karthikv1392.github.io/cs3301_osn/mini-projects/mp2)

## System Calls

### getreadcount

This system call returns the count of successful `read()` system calls performed by the process.

**Function Signature:**

```c
cCopy code
int getreadcount(void)

```

### sigalarm and sigreturn

These system calls provide an alarm mechanism that alerts a process periodically based on CPU time usage.

- `sigalarm(interval, handler)`: After every `interval` ticks of CPU time, the kernel calls the `handler` function.
- `sigreturn()`: Resets the process state to before the handler was called, allowing the process to resume execution.

## Scheduling Policies

### First-Come-First-Serve (FCFS)

FCFS executes processes in the order they arrive. The process with the earliest creation time gets executed first and runs until completion.

### Multi-Level Feedback Queue (MLFQ)

MLFQ assigns different priorities to processes and dynamically adjusts these priorities based on their behavior and CPU usage. It uses four priority queues with different time slices and implements aging to prevent starvation.

## Implementation Details

### System Calls

### getreadcount Implementation

1. **Define System Call Number:** Add `#define SYS_getreadcount 22` in `syscall.h`.
2. **Declare System Call Prototype:** Add the declaration in `syscall.c` and `sysproc.c`.
3. **Implement System Call:** Track read counts in `sysfile.c`.
4. **User-Space Wrapper:** Create a wrapper function in `usys.S`.
5. **User Program Usage:** Include the header file and call the wrapper function.

### sigalarm and sigreturn Implementation

1. **Define Signal Number:** Add `#define SIGALRM 14` in `signal.h`.
2. **Handle Signal in trap.c:** Update `trap.c` to recognize and handle `SIGALRM`.
3. **Signal Handler Function:** Implement the handler in `signal.c`.
4. **Set Alarm System Call:** Create `sys_alarm` in `sysproc.c`.
5. **User Program Usage:** Include header files and use the system call.

### Scheduling Policies

### FCFS Implementation

1. **Add Process Creation Time:** Modify `struct proc` in `proc.h` to store creation time.
2. **Select Process in scheduler():** Choose the process with the earliest creation time.
3. **Make Non-Preemptive:** Disable preemption in `trap.c`.

### MLFQ Implementation

1. **Add MLFQ Variables:** Update `struct proc` with level, check-in, timeslice, entry time, and run time.
2. **Declare Queues and Functions:** Define priority queues and aiding functions.
3. **Initialize Queues:** Initialize in `procinit()` in `proc.c`.
4. **Scheduler Update:** Implement aging and scheduling logic in `scheduler()`.
5. **Update Timeslice:** Adjust in `update_time()` in `proc.c`.
6. **Trap Update:** Change priority based on timeslice in `trap.c`.

![Alt text](https://github.com/rathee-19/Custom-System-Calls-and-Scheduling-in-xv6/blob/main/mlfq_plot.png)

## Testing and Usage

### Testing System Calls

- Use provided user programs to test `getreadcount`, `sigalarm`, and `sigreturn`.

### Testing Scheduling Policies

- Compile with `FCFS` or `MLFQ` flags and run `schedulertest` to validate.

## Conclusion

This project enhances xv6 with custom system calls for read counting and alarm signaling, and it implements two new scheduling algorithms, providing a comprehensive understanding of OS-level system call handling and process scheduling mechanisms.
