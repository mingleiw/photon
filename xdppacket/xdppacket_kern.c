// SPDX-License-Identifier: (GPL-2.0 OR BSD-2-Clause)
// Copyright (c) 2018 Netronome Systems, Inc.
/* Modifications Copyright (c) 2021 Minglei Wang (sudomw@gmail.com) */

#include <stdbool.h>
#include <stddef.h>
#include <string.h>
#include <linux/bpf.h>
#include <linux/in.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include <linux/tcp.h>
#include "bpf_helpers.h"
#include "bpf_endian.h"
#include "xdppacket_common.h"
#include "xdppacket_helpers.h"

struct bpf_map_def SEC("maps") packet_map = {
	.type = BPF_MAP_TYPE_PERF_EVENT_ARRAY,
	.key_size = sizeof(int),
	.value_size = sizeof(__u32),
	.max_entries = MAX_CPUS,
};

SEC("xdp_packet")
int process_packet(struct xdp_md *ctx)
{
    void *data_end = (void *)(long)ctx->data_end;
    void *data = (void *)(long)ctx->data;

	// only accept TCP traffic
	if(!is_TCP(data, data_end))
		return XDP_DROP;

    struct ethhdr *eth = data;
    struct packet_metadata metadata = {};
	__u32 offset;
	__u32 packet_len;
	__u64 flags = BPF_F_CURRENT_CPU;
	
	offset = sizeof(struct ethhdr);
	if (data + offset > data_end)
		return XDP_PASS;

	metadata.l3_proto = bpf_htons(eth->h_proto);

	if (metadata.l3_proto == ETH_P_IP) {
		if (!parse_ip4(data, offset, data_end, &metadata))
			return XDP_PASS;
		offset += sizeof(struct iphdr);
	} else if (metadata.l3_proto == ETH_P_IPV6) {
		if (!parse_ip6(data, offset, data_end, &metadata))
			return XDP_PASS;
		offset += sizeof(struct ipv6hdr);
	}

	if (data + offset > data_end)
		return XDP_PASS;

	if (metadata.l4_proto == IPPROTO_TCP) {
		if (!parse_tcp(data, offset, data_end, &metadata))
			return XDP_PASS;
		offset += sizeof(struct tcphdr);
	}

	metadata.pkt_len = data_end - data;
	metadata.data_len = data_end - data - offset;

	// invalid packet
	if(metadata.data_len < 7) {
		return XDP_PASS;
	}

	packet_len = min(metadata.pkt_len, PACKET_LEN);
	flags |= (__u64)packet_len << 32;

	bpf_perf_event_output(ctx, &packet_map, flags, &metadata, sizeof(metadata));

	return XDP_PASS;
}

char _license[] SEC("license") = "GPL";