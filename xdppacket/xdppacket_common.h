/* SPDX-License-Identifier: (GPL-2.0 OR BSD-2-Clause) */
/* Copyright (c) 2018 Netronome Systems, Inc. */
/* Modifications Copyright (c) 2021 Minglei Wang (sudomw@gmail.com) */

#define MAX_CPUS 128
#define PACKET_LEN 1024ul

#define bpf_printk(fmt, ...)					\
({								                \
    char ____fmt[] = fmt;				        \
    bpf_trace_printk(____fmt, sizeof(____fmt),	\
        ##__VA_ARGS__);			                \
})

struct packet_metadata {
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