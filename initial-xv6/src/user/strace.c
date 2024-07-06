// TRACES THE SYSTEM CALLS USED BY A COMMAND IN ITS EXECUTION
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    int pid=fork();
    if(pid<0){
        printf("Fork Failed\n"); // printing on stderr
        exit(1);
    }
    else if(pid){ // IN PARENT 
        wait(0);
    } 
    else{ // IN CHILD
        // execute the function as it is
        trace(atoi(argv[1])); 
        if (exec(argv[2], argv + 2) < 0)
            printf("Exec Failed\n"); // printing on stderr
    }

    // we have to execute the command as it is
    exit(1);
}