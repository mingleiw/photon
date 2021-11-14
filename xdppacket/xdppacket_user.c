// SPDX-License-Identifier: (GPL-2.0 OR BSD-2-Clause)
// Copyright (c) 2018 Netronome Systems, Inc.
/* Modifications Copyright (c) 2021 Minglei Wang (sudomw@gmail.com) */

#include <assert.h>
#include <libgen.h>
#include <perf-sys.h>
#include <poll.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include <bpf/bpf.h>
#include <bpf/libbpf.h>
#include <linux/if_ether.h>
#include <linux/if_link.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/sysinfo.h>
#include <sys/resource.h>
#define PCAP_DONT_INCLUDE_PCAP_BPF_H
#include <pcap/pcap.h>
#include <pcap/dlt.h>
#include <time.h>
#include "xdppacket_common.h"

#define NS_IN_SEC 1000000000
#define PAGE_CNT 8
#define NANOSECS_PER_USEC 1000

static pcap_t* p;
static pcap_dumper_t* pd;
static const char *default_pcap_filename = "packets.pcap";
static const char *default_bpf_obj_filename = "xdppacket_kern.o";

struct perf_event_sample {
	struct perf_event_header header;
	__u64 timestamp;
	__u32 size;
	struct packet_metadata metadata;
	__u8 pkt_data[64];
};

static __u32 xdp_flags;
static int ifindex;

static void unload_prog(int sig)
{
	bpf_set_link_xdp_fd(ifindex, -1, xdp_flags);
	printf("unloading xdp program...\n");
	exit(0);
}

void print_metadata(struct packet_metadata meta, __u64 timestamp)
{
	char src_str[INET6_ADDRSTRLEN];
	char dst_str[INET6_ADDRSTRLEN];
	char l3_str[32];
	char l4_str[32];

	switch (meta.l3_proto) {
	case ETH_P_IP:
		strcpy(l3_str, "IP");
		inet_ntop(AF_INET, &meta.src, src_str, INET_ADDRSTRLEN);
		inet_ntop(AF_INET, &meta.dst, dst_str, INET_ADDRSTRLEN);
		break;
	case ETH_P_IPV6:
		strcpy(l3_str, "IP6");
		inet_ntop(AF_INET6, &meta.srcv6, src_str, INET6_ADDRSTRLEN);
		inet_ntop(AF_INET6, &meta.dstv6, dst_str, INET6_ADDRSTRLEN);
		break;
	case ETH_P_ARP:
		strcpy(l3_str, "ARP");
		break;
	default:
		sprintf(l3_str, "%04x", meta.l3_proto);
	}

	switch (meta.l4_proto) {
	case IPPROTO_TCP:
		sprintf(l4_str, "TCP seq %d", ntohl(meta.seq));
		break;
	case IPPROTO_UDP:
		strcpy(l4_str, "UDP");
		break;
	case IPPROTO_ICMP:
		strcpy(l4_str, "ICMP");
		break;
	default:
		strcpy(l4_str, "");
	}

	printf("%lld.%06lld %s %s:%d > %s:%d %s, length %d\n",
	       timestamp / NS_IN_SEC, (timestamp % NS_IN_SEC) / 1000,
	       l3_str,
	       src_str, ntohs(meta.port16[0]),
	       dst_str, ntohs(meta.port16[1]),
	       l4_str, meta.data_len);
}

int print_event(struct perf_event_sample *sample)
{
	struct pcap_pkthdr h = {
		.caplen	= PACKET_LEN,
		.len	= sample->metadata.pkt_len,
	};
	struct timespec ts;
	int i, err;

	err = clock_gettime(CLOCK_MONOTONIC, &ts);
	if (err < 0) {
		printf("ERROR: failed to get clock time! (%i)\n", err);
		return LIBBPF_PERF_EVENT_ERROR;
	}

	h.ts.tv_sec  = ts.tv_sec;
	h.ts.tv_usec = ts.tv_nsec / NANOSECS_PER_USEC;

	print_metadata(sample->metadata, sample->timestamp);
    printf("\t");

	for (i = 0; i < sample->metadata.pkt_len; i++) {
		printf("%02x", sample->pkt_data[i]);

		if ((i + 1) % 16 == 0)
		{
			printf("\n\t");
		}
		else if ((i + 1) % 2 == 0)
		{
			printf(" ");
		}
	}
	printf("\n");
	pcap_dump((u_char *) pd, &h, sample->pkt_data);

	return LIBBPF_PERF_EVENT_CONT;
}


static enum bpf_perf_event_ret print_event_fn(void *event, void *printfn)
{
	int (*print_fn)(struct perf_event_sample *) = printfn;
	struct perf_event_sample *sample = event;

	if (sample->header.type == PERF_RECORD_SAMPLE)
		return print_fn(sample);
	else
		return LIBBPF_PERF_EVENT_CONT;
}

int event_poller(struct perf_event_mmap_page **mem_buf, int *sys_fds, int cpu_total)
{
	struct pollfd poll_fds[MAX_CPUS];
	void *buf = NULL;
	size_t len = 0;
	int total_size;
	int pagesize;
	int res;
	int n;

	for (n = 0; n < cpu_total; n++) {
		poll_fds[n].fd = sys_fds[n];
		poll_fds[n].events = POLLIN;
	}

	pagesize = getpagesize();
	total_size = PAGE_CNT * pagesize;
	for (;;) {
		poll(poll_fds, cpu_total, 250);

		for (n = 0; n < cpu_total; n++) {
			if (poll_fds[n].revents) {
				res = bpf_perf_event_read_simple(mem_buf[n],
								 total_size,
								 pagesize,
								 &buf, &len,
								 print_event_fn,
								 print_event);
				if (res != LIBBPF_PERF_EVENT_CONT)
					break;
			}
		}
	}
	free(buf);
}

int setup_perf_poller(int perf_map_fd, int *sys_fds, int cpu_total,
		      struct perf_event_mmap_page **mem_buf)
{
	struct perf_event_attr attr = {
		.sample_type	= PERF_SAMPLE_RAW | PERF_SAMPLE_TIME,
		.type		= PERF_TYPE_SOFTWARE,
		.config		= PERF_COUNT_SW_BPF_OUTPUT,
		.wakeup_events	= 1,
	};
	int mmap_size;
	int pmu;
	int n;

	mmap_size = getpagesize() * (PAGE_CNT + 1);

	for (n = 0; n < cpu_total; n++) {
		/* create perf fd for each thread */
		pmu = sys_perf_event_open(&attr, -1, n, -1, 0);
		if (pmu < 0) {
			printf("ERROR: failed to set up perf fd\n");
			return 1;
		}
		/* enable PERF events on the fd */
		ioctl(pmu, PERF_EVENT_IOC_ENABLE, 0);

		/* give fd a memory buf to write to */
		mem_buf[n] = mmap(NULL, mmap_size, PROT_READ | PROT_WRITE,
				  MAP_SHARED, pmu, 0);
		if (mem_buf[n] == MAP_FAILED) {
			printf("ERROR: failed to create mmap\n");
			return 1;
		}
		/* point eBPF map entries to fd */
		assert(!bpf_map_update_elem(perf_map_fd, &n, &pmu, BPF_ANY));
		sys_fds[n] = pmu;
	}
	return 0;
}

int main(int argc, char **argv)
{
	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
	static struct perf_event_mmap_page *mem_buf[MAX_CPUS];
	struct bpf_prog_load_attr prog_load_attr = {
		.prog_type = BPF_PROG_TYPE_XDP,
		.file = default_bpf_obj_filename,
	};
	struct bpf_map *perf_map;
	struct bpf_object *obj;
	int sys_fds[MAX_CPUS], perf_map_fd, prog_fd, n_cpus;

	// default: SKB_MODE
	// TODO: support other modes
	xdp_flags = XDP_FLAGS_SKB_MODE;
	n_cpus = get_nprocs();
	
	// default: lo
	// TODO: support command line args
	ifindex = if_nametoindex("lo");
	if (ifindex == 0) {
		printf("ERROR: invalid interface\n");
		return -1;
	}

	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
		printf("ERROR: failed to setrlimit(RLIMIT_MEMLOCK)");
		return -1;
	}

	/* load ebpf obj file */
	int err = bpf_prog_load_xattr(&prog_load_attr, &obj, &prog_fd);
	if (err) {
		fprintf(stderr, "ERROR: loading BPF-OBJ file(%s) (%d): %s\n",
			default_bpf_obj_filename, err, strerror(-err));
		return -1;
	}

	if (prog_fd < 1) {
		printf("ERROR: failed to load bpf program\n");
		return -1;
	}

	signal(SIGINT, unload_prog);
	signal(SIGTERM, unload_prog);

	if (bpf_set_link_xdp_fd(ifindex, prog_fd, xdp_flags) < 0) {
		printf("ERROR: failed to attach program\n");
		return -1;
	}

	// find eBPF per map file descriptor
	perf_map = bpf_object__find_map_by_name(obj, "packet_map");
	perf_map_fd = bpf_map__fd(perf_map);

	if (perf_map_fd < 0) {
		printf("ERROR: cannot find map\n");
		return -1;
	}

	if (setup_perf_poller(perf_map_fd, sys_fds, n_cpus, &mem_buf[0]))
		return -1;

	// setup pcap
	p = pcap_open_dead(DLT_EN10MB, 65535);
	if (!p)
		return -1;
	
	pd = pcap_dump_open(p, default_pcap_filename);
	if (!pd)
		return -1;	

	event_poller(mem_buf, sys_fds, n_cpus);
	
	//clean up
	pcap_dump_close(pd);
	pcap_close(p);

	return 0;
}