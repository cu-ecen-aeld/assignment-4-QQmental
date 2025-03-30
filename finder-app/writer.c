#include <stdlib.h>
#include <stdio.h>
#include <syslog.h>

int main(int argc, char *argv[])
{
    if (argc-1 != 2)
    {
        openlog(NULL, 0, LOG_USER);
        syslog(LOG_ERR, "You should pass 2 arguments, the first is a file, the second is a string\n");
        //closelog();
        printf("You should pass 2 arguments, the first is a file, the second is a string\n");
        return 1;
    }
    
    FILE *fptr = fopen(argv[1], "w");
    if (fptr == NULL)
    {
        openlog(NULL, 0, LOG_USER);
        syslog(LOG_ERR, "fail to open %s\n", argv[1]);
        printf("fail to open %s\n", argv[1]);
        return 1;
    }
    fprintf(fptr, "%s", argv[2]);
    //printf("hello world %p %s %s\n", fptr, argv[1], argv[2]);
    syslog(LOG_DEBUG, "Writing <%s> to <%s>", argv[2], argv[1]);
    fclose(fptr);
    return 0;
}