# photon

eBPF-based network monitoring tool which can capture the service live traffic. Photon attaches an eBPF program to service host/vm xdp hook point and store the packets to BPF_MAP_TYPE_PERF_EVENT_ARRAY map. A user space program prints the packets and store them in the pcap file. This project was inspired by [xdpdump](https://github.com/Netronome/bpf-samples/tree/master/xdpdump) and based on the learnings of [xdp-tutorial](https://github.com/xdp-project/xdp-tutorial).

## Getting Started

A simple xdp_pass eBPF program can be found under [examples/](examples/). Use this to test your environment setup for eBPF development. 

```bash
$ cd examples/xdp && make
$ sudo ./xdp_pass -d lo // xdp_pass will be attached to XDP hook point of device lo.
```

## System Requirements

- Linux kernel 4.18+
- libbpf (319ff2f0f6c6e823a705f21a6354af8d9cbadd14)
- clang / LLVM 6.0+
- libelf-dev, libpcap-dev(Ubuntu)
- elfutils-libelf-devel, libpcap-devel(Fedora)
- Go 1.10+

## Print TCP packets

xdppacket program prints xdp TCP packets in HEX format and dump packets in the packets.pcap file. 

```bash
// open a terminal (#1)
$ cd xdppacket && make
$ sudo ./xdppacket

// open another terminal (#2)
$ go run test/http_server.go

// open another terminal (#3)
$ curl --header "Content-Type: application/json" --request POST --data '{"xdp":"awesome"}' http://localhost:81/test

// Check #1 terminal's output
// Check xdppacket/packets.pcap
```
