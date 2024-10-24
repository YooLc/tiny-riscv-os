#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    asm volatile(
        "mv a7, %[eid]\n"
        "mv a6, %[fid]\n"
        "mv a0, %[arg0]\n"
        "mv a1, %[arg1]\n"
        "mv a2, %[arg2]\n"
        "mv a3, %[arg3]\n"
        "mv a4, %[arg4]\n"
        "mv a5, %[arg5]\n"
        : 
        : [eid] "r" (eid), [fid] "r" (fid),
          [arg0] "r" (arg0), [arg1] "r" (arg1), [arg2] "r" (arg2),
          [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5)
    );

    asm volatile("ecall");

    struct sbiret ret_val;
    asm volatile(
        "mv %[error], a0\n"
        "mv %[value], a1\n"
        : [error] "=r" (ret_val.error),
          [value] "=r" (ret_val.value)
    );

    return ret_val;
}

struct sbiret sbi_set_timer(uint64_t stime_value) {
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
}

struct sbiret sbi_debug_console_write(uint64_t num_bytes, uint64_t base_addr_lo, uint64_t base_addr_hi) {
    return sbi_ecall(0x4442434E, 0x0, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
}

struct sbiret sbi_debug_console_read(uint64_t num_bytes, uint64_t base_addr_lo, uint64_t base_addr_hi) {
    return sbi_ecall(0x4442434E, 0x1, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
}

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    return sbi_ecall(0x4442434E, 0x2, byte, 0, 0, 0, 0, 0);
}

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
}

