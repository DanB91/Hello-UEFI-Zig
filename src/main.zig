const std = @import("std");
const utf16 = std.unicode.utf8ToUtf16LeStringLiteral;
const uefi = std.os.uefi;
fn hang() void {
    while (true) {
        asm volatile ("pause");
    }
}

//int EfiMain(handle, system_table)

pub fn main() void {
    const console_out = uefi.system_table.con_out.?;
    _ = console_out.reset(true);
    _ = console_out.clearScreen();
    _ = console_out.outputString(utf16("Hello World!!\r\n"));
    const boot_services = uefi.system_table.boot_services.?;

    var gop: *uefi.protocols.GraphicsOutputProtocol = undefined;
    var status = boot_services.locateProtocol(&uefi.protocols.GraphicsOutputProtocol.guid, null, @as(*?*anyopaque, @ptrCast(&gop)));
    if (status != uefi.Status.Success) {
        _ = console_out.outputString(utf16("No GOP!\r\n"));
        hang();
    }
    _ = console_out.outputString(utf16("Has GOP!\r\n"));

    {
        //TODO: query mode 0 and check to make sure that mode 0 works
        status = gop.setMode(0);
        if (status != uefi.Status.Success) {
            _ = console_out.outputString(utf16("Set mode 0 failed!\r\n"));
            hang();
        }
    }
    //var screen_width: usize = gop.mode.info.horizontal_resolution;
    //var screen_height: usize = gop.mode.info.vertical_resolution;
    var frame_buffer_address: u64 = gop.mode.frame_buffer_base;
    var frame_buffer_len: usize = gop.mode.frame_buffer_size;

    //TODO dynamically allocate memory descriptors with allocatePool() to guarantee that the array to hold them is big enough
    var memory_descriptors: [64]uefi.tables.MemoryDescriptor = undefined;
    var mmap_size = memory_descriptors.len * @sizeOf(uefi.tables.MemoryDescriptor);
    var map_key: usize = 0;
    var descriptor_size: usize = 0;
    var descriptor_version: u32 = 0;
    status = boot_services.getMemoryMap(&mmap_size, &memory_descriptors, &map_key, &descriptor_size, &descriptor_version);
    if (status != uefi.Status.Success) {
        _ = console_out.outputString(utf16("Get memory map failed!\r\n"));
        hang();
    }

    status = boot_services.exitBootServices(uefi.handle, map_key);
    if (status != uefi.Status.Success) {
        _ = console_out.outputString(utf16("Exit boot services failed!\r\n"));
        hang();
    }

    //TODO check the pixel format of the frame buffer. assuming xRGB (blue is LSB) for now.
    const frame_buffer: []volatile u32 = @as([*]volatile u32, @ptrFromInt(frame_buffer_address))[0 .. frame_buffer_len / 4];
    for (frame_buffer) |*px| {
        px.* = 0x00FF0000;
    }

    hang();

    //
    //TODO:
    //      1) Get printf debugging working!
    //         a) To output to the serial io port
    //      2) Set your own virtual memory map.
    //      3) Enable write-combining for the frame buffer
    //      4) Get keyboard and mouse working
    //         a) Get a PS/2 driver
    //         b) Get a USB driver
    //      5) Alot more!
}
