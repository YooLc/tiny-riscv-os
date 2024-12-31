# tiny-riscv-kernel

This is a course lab project for [ZJU CS3104M Operating System](https://zju-sec.github.io/os24fall-stu/) (24 fall), here is the [lab repository](https://github.com/ZJU-SEC/os24fall-stu). Thanks to TAs for providing the framework for this project.

## Functionality

- Timer Interrupt
- Process Scheduling
- Memory Management: RV39 paging, Demand paging with CoW.
- System Call: `clone`, `getpid`, `openat`, `close`, `read`, `write`
- File System: very simple FAT32 file read/write support.

## Build and Test

```bash
nix develop .
make -j$(nproc) run
```
