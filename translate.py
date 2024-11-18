def xlat_satp(satp):
    mode = (satp >> 60) & 0xf
    asid = (satp >> 44) & 0xffff
    ppn = satp & 0xfffffffffff
    pgd_addr = ppn << 12

    print("SATP:")
    print("Hex: mode = 0x%x, asid = 0x%x, ppn = 0x%x (pgd_addr = 0x%x)" % (mode, asid, ppn, pgd_addr))
    print("Dec: mode = %d, asid = %d, ppn = %d (pgd_addr = %d)" % (mode, asid, ppn, pgd_addr))


# RISC-V Physical Address, SV39, extract ppn and offset
def xlat_pa(pa):
    ppn = [0, 0, 0]
    ppn[0] = (pa >> 30) & 0x3ffffff
    ppn[1] = (pa >> 21) & 0x1ff
    ppn[2] = (pa >> 12) & 0x1ff
    offset = pa & 0xfff

    print("Physical Address:")
    print("Hex: ppn[0] = 0x%x, ppn[1] = 0x%x, ppn[2] = 0x%x, offset = 0x%x" % (ppn[0], ppn[1], ppn[2], offset))
    print("Dec: ppn[0] = %d, ppn[1] = %d, ppn[2] = %d, offset = %d" % (ppn[0], ppn[1], ppn[2], offset))

# RISC-V Virtual Address, SV39, extract vpn and offset
def xlat_va(va):
    vpn = [0, 0, 0]
    vpn[0] = (va >> 30) & 0x1ff
    vpn[1] = (va >> 21) & 0x1ff
    vpn[2] = (va >> 12) & 0x1ff
    offset = va & 0xfff

    print("Virtual Address:")
    print("Hex: vpn[0] = 0x%x, vpn[1] = 0x%x, vpn[2] = 0x%x, offset = 0x%x" % (vpn[0], vpn[1], vpn[2], offset))
    print("Dec: vpn[0] = %d, vpn[1] = %d, vpn[2] = %d, offset = %d" % (vpn[0], vpn[1], vpn[2], offset))

# RISC-V Virtual Address, SV39 PTE
def xlat_pte(pte):
    ppn = [0, 0, 0]
    ppn[0] = (pte >> 28) & 0x3ffffff
    ppn[1] = (pte >> 19) & 0x1ff
    ppn[2] = (pte >> 10) & 0x1ff
    
    perm = pte & 0x1ff
    valid = (pte >> 63) & 0x1

    print("PTE:")
    page_start = (ppn[0] << 30) | (ppn[1] << 21) | (ppn[2] << 12)
    print("Page Start Address: 0x%x" % page_start)
    print("Hex: ppn[0] = 0x%x, ppn[1] = 0x%x, ppn[2] = 0x%x, perm = 0x%x, valid = 0x%x" % (ppn[0], ppn[1], ppn[2], perm, valid))
    print("Dec: ppn[0] = %d, ppn[1] = %d, ppn[2] = %d, perm = %d, valid = %d" % (ppn[0], ppn[1], ppn[2], perm, valid))

while True:
    addr = input("Input a 64-bit hex number: ")
    # extract 0x prefix
    if addr[:2] == "0x":
        addr = addr[2:]

    xlat_satp(int(addr, 16))
    xlat_pa(int(addr, 16))
    xlat_va(int(addr, 16))
    xlat_pte(int(addr, 16))