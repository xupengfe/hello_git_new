#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <errno.h>
#include <sys/socket.h>
#include <netinet/in.h>


#define IPT_BASE_CTL		64
#define IPT_SO_SET_REPLACE	(IPT_BASE_CTL)

static void *buffer;

int main() {
        struct ipt_replace *ipt_replace = buffer;
        int fd = socket(AF_INET, SOCK_DGRAM, 0);
	//struct ipt_entry *ipt_entry = &ipt_replace->entries[0];
	//struct xt_entry_match *xt_entry_match =
	//	(struct xt_entry_match *)&ipt_entry->elems[0];
	//const size_t tgt_size = 32;
	//const size_t match_size = 1024 - 64 - 112 - 4 - tgt_size - 4;
	//struct xt_entry_target *xt_entry_tgt =
	//	((struct xt_entry_target *) (&ipt_entry->elems[0] + match_size));
        int ret = 0;

        if (fd < 0)
                printf("socket failed:%d\n", fd);
        printf("IPPROTO_IP:%d, IPT_SO_SET_REPLACE:%d\n",
                IPPROTO_IP, IPT_SO_SET_REPLACE);

        ret = setsockopt(fd, IPPROTO_IP, IPT_SO_SET_REPLACE, buffer, 1);

        // Display information
        printf("setsockopt, ret:%d, errno:%d\n", ret, errno);

        return 0;
}
