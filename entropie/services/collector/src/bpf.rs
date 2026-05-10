use anyhow::{anyhow, Result};
use std::os::unix::io::RawFd;

const NR_BPF: i64 = 321;
const BPF_MAP_LOOKUP_ELEM: u32 = 1;
const BPF_MAP_GET_NEXT_KEY: u32 = 4;
const BPF_OBJ_GET_INFO_BY_FD: u32 = 15;
const BPF_MAP_GET_FD_BY_ID: u32 = 14;
const BPF_MAP_GET_NEXT_ID: u32 = 12;

/// Layout matches the BPF flow_key struct (host byte order)
#[repr(C)]
#[derive(Clone, Debug, Default)]
pub struct FlowKey {
    pub src_ip: u32,
    pub dst_ip: u32,
    pub src_port: u16,
    pub dst_port: u16,
    pub _pad: [u8; 4],
}

/// Layout matches the BPF flow_val struct
#[repr(C)]
#[derive(Clone, Debug, Default)]
pub struct FlowVal {
    pub packets: u64,
    pub bytes: u64,
}

pub struct Flow {
    pub src_ip: u32,
    pub dst_ip: u32,
    pub src_port: u16,
    pub dst_port: u16,
    pub packets: u64,
    pub bytes: u64,
}

/// BPF object info (subset of bpf_map_info)
#[repr(C)]
struct BpfMapInfo {
    map_type: u32,
    id: u32,
    key_size: u32,
    value_size: u32,
    max_entries: u32,
    map_flags: u32,
    name: [u8; 16],
    _rest: [u8; 128],
}

fn bpf_syscall(cmd: u32, attr: &mut [u8]) -> i64 {
    unsafe {
        libc::syscall(NR_BPF, cmd as libc::c_long, attr.as_mut_ptr(), attr.len() as libc::c_long)
    }
}

/// Find the flow_map by iterating all BPF map IDs and matching key/value sizes.
pub fn find_flow_map() -> Result<RawFd> {
    let key_size = std::mem::size_of::<FlowKey>() as u32;
    let val_size = std::mem::size_of::<FlowVal>() as u32;

    let mut start_id: u32 = 0;
    loop {
        // BPF_MAP_GET_NEXT_ID: {u32 start_id, u32 next_id, ...}
        let mut attr = [0u8; 16];
        attr[0..4].copy_from_slice(&start_id.to_ne_bytes());
        let ret = bpf_syscall(BPF_MAP_GET_NEXT_ID, &mut attr);
        if ret != 0 {
            return Err(anyhow!("no more BPF maps (iterated from id={})", start_id));
        }
        // kernel writes next_id at offset 4 (start_id input is at offset 0)
        let next_id = u32::from_ne_bytes(attr[4..8].try_into().unwrap());
        start_id = next_id;

        // Get FD for this map id
        let mut fd_attr = [0u8; 16];
        fd_attr[0..4].copy_from_slice(&next_id.to_ne_bytes());
        let fd = bpf_syscall(BPF_MAP_GET_FD_BY_ID, &mut fd_attr) as i32;
        if fd < 0 { continue; }

        // Get map info
        let mut info = BpfMapInfo {
            map_type: 0, id: 0, key_size: 0, value_size: 0, max_entries: 0,
            map_flags: 0, name: [0; 16], _rest: [0; 128],
        };
        let info_size = std::mem::size_of::<BpfMapInfo>() as u32;

        // BPF_OBJ_GET_INFO_BY_FD attr: {bpf_fd, info_len, info_ptr, ...}
        let mut info_attr = [0u8; 32];
        info_attr[0..4].copy_from_slice(&(fd as u32).to_ne_bytes());
        info_attr[4..8].copy_from_slice(&info_size.to_ne_bytes());
        let info_ptr = &mut info as *mut BpfMapInfo as u64;
        info_attr[8..16].copy_from_slice(&info_ptr.to_ne_bytes());
        bpf_syscall(BPF_OBJ_GET_INFO_BY_FD, &mut info_attr);

        if info.key_size == key_size && info.value_size == val_size {
            return Ok(fd);
        }

        unsafe { libc::close(fd); }
    }
}

/// Read all flow entries from the BPF map.
pub fn read_flows(map_fd: RawFd) -> Result<Vec<Flow>> {
    let key_size = std::mem::size_of::<FlowKey>();
    let val_size = std::mem::size_of::<FlowVal>();
    let mut flows = Vec::new();

    let mut key = FlowKey::default();
    let mut next_key = FlowKey::default();

    // Iterate with BPF_MAP_GET_NEXT_KEY starting from NULL key
    let mut first = true;
    loop {
        let mut attr = [0u8; 40];
        let fd_bytes = (map_fd as u32).to_ne_bytes();
        attr[0..4].copy_from_slice(&fd_bytes);

        if first {
            // key_ptr = NULL (zero)
            attr[8..16].copy_from_slice(&0u64.to_ne_bytes());
            first = false;
        } else {
            let key_ptr = &key as *const FlowKey as u64;
            attr[8..16].copy_from_slice(&key_ptr.to_ne_bytes());
        }
        let next_key_ptr = &mut next_key as *mut FlowKey as u64;
        attr[16..24].copy_from_slice(&next_key_ptr.to_ne_bytes());

        let ret = bpf_syscall(BPF_MAP_GET_NEXT_KEY, &mut attr);
        if ret != 0 { break; } // ENOENT = no more keys

        // Lookup value for next_key
        let mut val = FlowVal::default();
        let mut lookup_attr = [0u8; 40];
        lookup_attr[0..4].copy_from_slice(&fd_bytes);
        let nk_ptr = &next_key as *const FlowKey as u64;
        let v_ptr = &mut val as *mut FlowVal as u64;
        lookup_attr[8..16].copy_from_slice(&nk_ptr.to_ne_bytes());
        lookup_attr[16..24].copy_from_slice(&v_ptr.to_ne_bytes());
        bpf_syscall(BPF_MAP_LOOKUP_ELEM, &mut lookup_attr);

        flows.push(Flow {
            src_ip: next_key.src_ip,
            dst_ip: next_key.dst_ip,
            src_port: next_key.src_port,
            dst_port: next_key.dst_port,
            packets: val.packets,
            bytes: val.bytes,
        });

        key = next_key.clone();
    }

    Ok(flows)
}
