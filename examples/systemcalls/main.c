#include "systemcalls.h"
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <syslog.h>


int main()
{
    char* arr[] = {"/usr/bin/test","-f","/bin/echo", NULL};
    //char *arr[] = {"/bin/echo", "123", NULL};
    bool f = do_exec(3, "/usr/bin/test","-f","/bin/echo");
    //bool f = do_exec(2, "echo", "Testing execv implementation with echo");
    //printf("f = %d\n", f);
    //int f = execv(arr[0], &arr[0]);
    printf("f = %d\n", f);
}