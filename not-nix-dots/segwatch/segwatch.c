#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <execinfo.h>
#include <unistd.h>
#include <sys/wait.h>

void print_backtrace() {
    void *array[20];
    int size = backtrace(array, 20);
    backtrace_symbols_fd(array, size, STDERR_FILENO);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "usage: segwatch <program> [args...]\n");
        return 1;
    }
    pid_t pid = fork();
    if (pid == 0) {
        execvp(argv[1], &argv[1]);
        perror("exec failed");
        exit(1);
    }
    int status;
    waitpid(pid, &status, 0);
    if (WIFSIGNALED(status)) {
        int sig = WTERMSIG(status);
        if (sig == SIGSEGV) {
            fprintf(stderr, "\nSEGMENTATION FAULT DETECTED\n");
            print_backtrace();
        }
    }
    return 0;
}
