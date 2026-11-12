# Tenbay V-MS3000K OpenWrt support notes

R121 is a hardware-tested prototype for the Tenbay V-MS3000K access point. This branch records the evidence and the work needed for an upstream device-support pull request.

| Component | Observed on the test device |
| --- | --- |
| SoC and target | MediaTek MT7981B, `mediatek/filogic` |
| Ethernet | `eth0` is WAN and `eth1` is LAN. Wired LAN negotiated 1 Gbit/s. |
| Storage | 128 MiB SPI NAND with NMBM. The two firmware slots are each 48 MiB. |
| Firmware slots | OEM `ubi` starts at `0x00580000`. OpenWrt `ubi1` starts at `0x03580000`. |
| OpenWrt volumes | Kernel FIT at ID 0, SquashFS at ID 1 and UBIFS configuration overlay at ID 2. |

## Hardware evidence

- The OEM web installer installed R120 into `ubi1`. OpenWrt initialized the empty overlay, and a UCI setting survived reboot.
- LuCI upgraded R120 to R121 with settings retained. UART verified the new firmware, the writable UBIFS overlay and the two-port LuCI inventory.
- A supervised boot into `ubi` reached the OEM web interface. The primary kernel and root filesystem matched the OEM backup. A normal reboot returned to R121, and its temporary UCI test value survived.
- Both Wi-Fi bands worked during earlier prototype testing. The final R121 round trip covered wired access and storage.

## Upstream contribution plan

1. Port the DTS, device profile and network defaults to current OpenWrt `main`. Describe the two physical ports, Factory calibration and the slot offsets in the device support patch.
2. Split SPI NAND identification and NMBM write handling from the board patch. Document why the observed NAND needs an ONFI fallback and obtain review of the write bounds and error handling.
3. Integrate image generation and sysupgrade with the OpenWrt build system. Keep the upgrade destination restricted to `ubi1` and document the recovery path through the OEM slot.
4. Build from the upstream branch and retest NAND boot, configuration persistence, LuCI upgrade and the OEM recovery round trip before opening the device-support PR. R121's OEM package has only been validated offline for a clean OEM installation. The hardware installation path was OEM to R120 to R121.

The prototype used Linux 6.18.60 and a local build. These results apply to that build. This branch contains the handoff notes for the upstream port.
