# photon

eBPF-based network monitoring tool which can capture the service live traffic. Photon attaches an eBPF program to service host/vm xdp hook point and store the packets to BPF_MAP_TYPE_PERF_EVENT_ARRAY map. A user space program assembles the packets into a human readable format. 

## Getting Started

A simple xdp_pass eBPF program can be found under [examples/](examples/). Use this to test your environment setup for eBPF development. 

```bash
$ cd examples/xdp && make
$ sudo ./xdp_pass -d lo // xdp_pass will be attached to XDP hook point of device lo.
```