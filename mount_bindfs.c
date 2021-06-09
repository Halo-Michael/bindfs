#include <err.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mount.h>
#include <unistd.h>
#include "mntopts.h"

struct mntopt mopts[] = {
    MOPT_STDOPTS,
    MOPT_IGNORE_OWNERSHIP,
    MOPT_PERMISSIONS,
    { NULL }
};

void usage() {
    puts("mount_bindfs [options] dir mountpoint");
    puts("options:");
    puts("\t-o opt[,opt,...]\tMount options.");
}

int main(int argc, char **argv) {
    int ch, mntflags = 0;
    while ((ch = getopt(argc, argv, "ho:")) != EOF) {
        switch (ch) {
        case 'o':
            {
                int dummy;
                getmntopts(optarg, mopts, &mntflags, &dummy);
            }
            break;
        default:
            {
                usage();
                return 1;
            }
        }
    }
    argc -= optind;
    argv += optind;

    if (argc != 2) {
        usage();
        return 1;
    }

    char *dir = (char *)calloc(MAXPATHLEN, sizeof(char));
    if (realpath(argv[1], dir) == NULL)
        err(errno, "realpath dir %s", dir);
    dir = (char *)realloc(dir, (strlen(dir) + 1) * sizeof(char));

    char *mountpoint = (char *)calloc(MAXPATHLEN, sizeof(char));
    if (realpath(argv[0], mountpoint) == NULL)
        err(errno, "realpath mountpoint %s", mountpoint);
    mountpoint = (char *)realloc(mountpoint, (strlen(mountpoint) + 1) * sizeof(char));

    int mountStatus;
    if ((mountStatus = mount("bindfs", mountpoint, mntflags, dir)) < 0) {
        err(errno, "error on mount(): error = %d", mountStatus);
    };

    return 0;
}
