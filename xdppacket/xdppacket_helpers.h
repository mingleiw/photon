// SPDX-License-Identifier: (GPL-2.0 OR BSD-2-Clause)
// Copyright (c) 2018 Netronome Systems, Inc.
/* Modifications Copyright (c) 2021 Minglei Wang (sudomw@gmail.com) */

#define min(x, y) ((x) < (y) ? (x) : (y))

static __always_inline bool parse_tcp(void *data, __u64 offset, void *data_end,
				      struct packet_metadata *metadata)
{
	struct tcphdr *tcp;

	tcp = data + offset;
	if (tcp + 1 > data_end)
		return false;

	metadata->port16[0] = tcp->source;
	metadata->port16[1] = tcp->dest;
	metadata->seq = tcp->seq;

    if (tcp->dest != bpf_htons(81)) {
        return false;
    }

	return true;
}

static __always_inline bool parse_ip4(void *data, __u64 offset, void *data_end,
				      struct packet_metadata *metadata)
{
	struct iphdr *iph;

	iph = data + offset;
	if (iph + 1 > data_end)
		return false;

	if (iph->ihl != 5)
		return false;

	metadata->src = iph->saddr;
	metadata->dst = iph->daddr;
	metadata->l4_proto = iph->protocol;

	return true;
}

static __always_inline bool parse_ip6(void *data, __u64 offset, void *data_end,
				      struct packet_metadata *metadata)
{
	struct ipv6hdr *ip6h;

	ip6h = data + offset;
	if (ip6h + 1 > data_end)
		return false;

	memcpy(metadata->srcv6, ip6h->saddr.s6_addr32, 16);
	memcpy(metadata->dstv6, ip6h->daddr.s6_addr32, 16);
	metadata->l4_proto = ip6h->nexthdr;

	return true;
}


static bool is_TCP(void *data_begin, void *data_end)
{
    struct ethhdr *eth = data_begin;
    
    // check packet size
    if ((void *)(eth + 1) > data_end)
        return false;
    
    // check if it's an IP packet
    if (eth->h_proto == bpf_htons(ETH_P_IP))
    {
        struct iphdr *iph = (struct iphdr *)(eth + 1);
        if ((void *)(iph + 1) > data_end)
            return false; 
        
        if(iph->protocol == IPPROTO_TCP)
            return true;

    }
    return false;
}