/* SPDX-License-Identifier: GPL-2.0 */
#define MAX_CPUS 128
#define PACKET_SIZE 1024ul

#define min(x, y) ((x) < (y) ? (x) : (y))

#define bpf_printk(fmt, ...)					\
({								                \
    char ____fmt[] = fmt;				        \
    bpf_trace_printk(____fmt, sizeof(____fmt),	\
        ##__VA_ARGS__);			                \
})

struct packet_meta {
    union {
		__be32 src;
		__be32 srcv6[4];
	};
	union {
		__be32 dst;
		__be32 dstv6[4];
	};
	__u16 port16[2];
	__u16 l3_proto;
	__u16 l4_proto;
	__u16 data_len;
	__u16 pkt_len;
	__u32 seq;
};