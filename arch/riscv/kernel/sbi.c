#include "sbi.h"

#include "stdint.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid, uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {

    struct sbiret ret_val;
    uint64_t error, value;

    // Bind arguments to registers as per the RISC-V calling convention
    register uint64_t a0 asm("a0") = arg0;
    register uint64_t a1 asm("a1") = arg1;
    register uint64_t a2 asm("a2") = arg2;
    register uint64_t a3 asm("a3") = arg3;
    register uint64_t a4 asm("a4") = arg4;
    register uint64_t a5 asm("a5") = arg5;
    register uint64_t a6 asm("a6") = fid;
    register uint64_t a7 asm("a7") = eid;

    asm volatile("ecall"
        : "+r"(a0), "+r"(a1)
        : "r"(a2), "r"(a3), "r"(a4), "r"(a5), "r"(a6), "r"(a7)
        : "memory");

    ret_val.error = a0;
    ret_val.value = a1;
    return ret_val;
}

struct sbiret sbi_set_timer(uint64_t stime_value) {
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
}

struct sbiret sbi_debug_console_write(uint64_t num_bytes, uint64_t base_addr_lo,
                                      uint64_t base_addr_hi) {
    return sbi_ecall(0x4442434E, 0x0, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
}

struct sbiret sbi_debug_console_read(uint64_t num_bytes, uint64_t base_addr_lo,
                                     uint64_t base_addr_hi) {
    return sbi_ecall(0x4442434E, 0x1, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
}

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    return sbi_ecall(0x4442434E, 0x2, byte, 0, 0, 0, 0, 0);
}

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
}
