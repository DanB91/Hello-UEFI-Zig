Hello UEFI
---
This repo contains a very small amount of code to get started writing an OS or a bare-metal UEFI application in Zig.

Requirements:
---
- Zig compiler 0.12.0-dev.1101+25400fadf or newer. Pulling down the latest build is your best bet
- Aforementioned Zig compiler in $PATH
- qemu-system-x86_64 in $PATH
- Linux or Mac (might run on Windows, but has not been tested)


To Run:
---
`zig build run` will build and run this UEFI program in qemu.
