# Hackintosh B450 + Ryzen 3600X + RX 5600 XT - macOS Tahoe 26

OpenCore EFI configuration for:
- **Motherboard:** MSI B450M MORTAR MAX (MS-7B89)
- **CPU:** AMD Ryzen 5 3600X 6-Core (Matisse / Zen 2, Family 17h)
- **GPU:** AMD Radeon RX 5600 XT (Navi 10, Device 1002-731F)
- **Audio:** Realtek ALC892 (subsystem 1462EB89)
- **Ethernet:** Realtek RTL8168 + RTL8125
- **OS:** macOS Tahoe 26.x

## Version History

### v4.3.0 (April 2026) - Tahoe Non-Monotonic Time Panic Fix
**Critical fix for boot hang at Apple logo on macOS Tahoe 26.4+**

- 🔧 **Added laobamac's Tahoe-specific non-monotonic time panic patch** (from AMD_Vanilla PR #215)
  - Darwin 25.4.0+ (Tahoe 26.4+) shifted the thread struct offset from 0x480 to 0x490
  - Old patch couldn't match the new offset → kernel panic on boot
  - New patch entry: `laobamac | thread_invoke, thread_dispatch | Remove non-monotonic time panic | 26.4+`
- 🔧 Split `thread_invoke, thread_dispatch` non-monotonic panic patch into two entries:
  - `12.0-26.3` (MaxKernel 25.3.99) for Darwin ≤ 25.3
  - `26.4+` (MinKernel 25.4.0) for Darwin ≥ 25.4
- 🔧 Fixed all MaxKernel values: `26.99.99` → `25.99.99` to align with AMD_Vanilla upstream
  - macOS Tahoe = Darwin kernel 25.x, so MaxKernel 25.99.99 covers all Tahoe versions
- 🔧 Added `revpatch=sbv,pci` to boot-args (RestrictEvents recommended for AMD)
- 🔧 Fixed IOPCIFamily probeBusGated 26.0+ patch MaxKernel to 25.99.99

### v4.2.0 (April 2026)
- Applied AMD_Vanilla master branch patches with MaxKernel extended to 26.99.99
- Added Tahoe-specific IOPCIFamily probeBusGated patch split (12.0-15.x / 26.0+)

### v4.1.0 (April 2026)
- Fixed wrong Find patterns in AMD_Vanilla patches (B8 FF FF → C1 E8 1A)
- Corrected core count to 6 (0x06) for Ryzen 5 3600X

## Current Kexts

| Kext | Version | Purpose |
|------|---------|---------|
| OpenCore | 1.0.7 | Bootloader |
| Lilu | 1.7.3 | Kext dependency framework |
| WhateverGreen | 1.7.1 | GPU patches (Navi) |
| AppleALC | 1.9.8 | Audio (ALC892, layout 17) |
| VirtualSMC | 1.3.8 | SMC emulator |
| SMCSuperIO | 1.3.8 | Fan/IO monitoring |
| SMCAMDProcessor | 1.0 | AMD CPU SMC reporting |
| AMDRyzenCPUPowerManagement | 0.7.1 | AMD CPU power management |
| AmdTscSync | 2.0.0 | TSC sync on AMD |
| RestrictEvents | 1.1.7 | Memory warnings fix, SBV patch |
| NVMeFix | 1.1.4 | NVMe power management |
| AppleALC | 1.9.8 | Audio |
| RealtekRTL8111 | 2.4.2 | RTL8168 Ethernet |
| LucyRTL8125Ethernet | 1.2.3 | RTL8125 2.5GbE |
| RadeonSensor | 1.1.0 | AMD GPU sensor |
| SMCRadeonGPU | 1.1.0 | AMD GPU SMC |
| SMCRadeonSensors | 2.4.0 | AMD GPU sensors |
| USBToolBox + UTBDefault | 1.0 | USB port mapping |
| AppleMCEReporterDisabler | - | Disable MCE reporter on AMD |

## Boot Args

```
-v alcid=17 agdpmod=pikera keepsyms=1 hb=0 -lilubetaall -wegbeta -alcbeta revpatch=sbv,pci
```

| Arg | Purpose |
|-----|---------|
| `-v` | Verbose boot (remove for production) |
| `alcid=17` | Audio layout ID for ALC892 on MSI |
| `agdpmod=pikera` | **REQUIRED** for RX 5600 XT (Navi) display output |
| `keepsyms=1` | Preserve kernel symbols for panic debugging |
| `hb=0` | Disable Hibernate |
| `-lilubetaall` | Allow Lilu on unsupported OS versions |
| `-wegbeta` | Allow WhateverGreen on unsupported OS |
| `-alcbeta` | Allow AppleALC on unsupported OS |
| `revpatch=sbv,pci` | RestrictEvents board-id + PCI patches for AMD |

## BIOS Settings

- CSM: **OFF** (Required for Navi GPUs and OpenCore)
- Above 4G Decoding: **Enabled**
- Resize BAR: **Disabled** (ResizeGpuBars = -1 in config)
- PCIe Gen: **Gen3** (force if unstable at Auto)
- USB XHCI Hand-off: **Enabled**
- Windows 8/10 WHQL: **Disabled**
- SVM Mode: **Enabled** (for virtualization)
- Fast Boot: **Disabled**

## Features

- ✅ AMD Ryzen 5 3600X 6-core recognized properly
- ✅ RX 5600 XT full acceleration via WhateverGreen
- ✅ Audio via AppleALC (ALC892, layout 17)
- ✅ RTL8168 + RTL8125 Ethernet
- ✅ NVMe power management
- ✅ USB mapping via USBToolBox
- ✅ AMD CPU power management + sensors
- ✅ macOS Tahoe 26.x support (Darwin 25.4+ non-monotonic time panic patched)

## Known Issues

- ⚠️ Sleep/Wake may have issues (EB.WL.PWLFMV, EB.WL.PWLFRTC wake-failure messages)
- ⚠️ AMD_Vanilla hasn't merged PR #215 yet - using the patch from the open PR
- ⚠️ Boot may still hang if other kernel patches don't match Tahoe binary patterns

## Installation Notes

1. Format USB as GPT with FAT32 EFI partition
2. Copy EFI folder to USB's EFI partition
3. Boot from USB, select macOS installer
4. After installation, copy EFI to SSD's EFI partition
5. **Generate unique SMBIOS serials** before using! (MacPro7,1)

## AMD_Vanilla Patches Applied

All patches from AMD_Vanilla master branch with:
- **Core count:** 6 (0x06) for Ryzen 5 3600X
- **ProvideCurrentCpuInfo:** Enabled (required for universal 15h/16h/17h/19h patches)
- **MaxKernel:** 25.99.99 (covers all macOS Tahoe / Darwin 25.x)
- **Tahoe-specific:** laobamac's Darwin 25.4+ non-monotonic time panic patch (PR #215)

## Credit

- [Acidanthera](https://github.com/acidanthera) - OpenCore, Lilu, WhateverGreen, AppleALC
- [AMD-OSX](https://github.com/AMD-OSX/AMD_Vanilla) - AMD kernel patches
- [laobamac](https://github.com/laobamac) - Darwin 25.4+ non-monotonic time panic fix (PR #215)
- [Dortania](https://dortania.github.io/OpenCore-Install-Guide/) - OpenCore Install Guide
- [ChefKiss](https://github.com/ChefKissInc) - ForgedInvariant, NootedRed, NootRX