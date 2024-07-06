# Modified xv6 OS

## Rohan | 2022101128

---
## Running OS

1. Install qemu
2. From the root directory of project, run 
```
make clean;
make qemu SCHEDULER={SCHEDULER} CPUS={CPUS};
```

- `SCHEDULER` can be one of the following:
  - `RR` (Round Robin) (Default)
  - `FCFS` (First Come First Serve)
  - `MLFQ` (Multi Level Feedback Queue)



### First Come First Serve (FCFS)

- `Non-preemptive scheduling` : Disable pre-emption in usertrap and kerneltrap in kernel/trap.c
- `Always looks for process with lowest creation time` : 
     - Change the way process is chosen in scheduler() in proc.c
     - Add starttime of process in proc.h and initialise it in allocproc()
### Multi Level Feedback Queue (MLFQ)

- `Preemptive Scheduling`
- `5` queues are created :
    - `struct node` is defined which contains `struct proc*` and `struct node* next`
    - `NPROC` nodes are already created with empty processes
    - struct Queue contains `head` of queue and `size` of queue
    - Regular routines like `push` , `pop` , `remove` are implemented in proc.c
- For each process we have `queueno` , `inqueue` (to check whether a process is part of a queue) ,  `timeslice` ( time left in this queue ) and `qitime` (entry time in a queue to implement ageing)
- Process in queue _`i`_ gets _`2^i`_ ticks to run
- If a process spends more than certain number of ticks (ageing ticks) in a process , it is demoted to a lower queue (ageing) , implemented in scheduler
- Then  , process in the lowermost queueno is chosen and implemented
- If a process exhausts the timeslice in a queue and it's still Runnable, it gets demoted to lower priority (only if it's not already in the lowest) , implemented in `usertrap()` and `kerneltrap()` in trap.c

- **Exploitation:** A process can exploit this MLFQ algorithms by programming it to go to sleep for a small time just before it is about to exhaust the timeslice of top priority queue. This way it gets to stay on the top priority queue , thus causing large waiting time for processes in higher queues

## Analysis  
RR : Avg rtime 25, avg wtime 120  
FCFS :  Avg rtime 74, avg time 87  
MLFQ : Average rtime 18,  wtime 167  

## Specification 

Details about the implementation of the scheduling algorithms have been included under Specification 2

Notable facts are - 
1. FCFS has the least wait time because of no pre-emption
2. MLFQ performs very well despite the constraint of using only one CPU

### MLFQ Scheduling Analysis

![Loading mlfq analysis](mlfq_plot./png "MLFQ Analysis")

