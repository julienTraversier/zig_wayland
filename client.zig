const std = @import("std");
const wc = @cImport({
    @cInclude("wayland-client.h");
    // @cInclude("shm_open.h");
});
const xdg = @cImport({
    @cInclude("xdg-shell-client-protocol.h");
});
const c = @cImport({
    @cInclude("errno.h");
    @cInclude("fcntl.h");
    @cInclude("limits.h");
    @cInclude("stdbool.h");
    @cInclude("string.h");
    @cInclude("sys/mman.h");
    @cInclude("time.h");
    @cInclude("unistd.h");
});

fn opaqPtrTo(comptime T: type, ptr: ?*anyopaque) T {
    return @ptrCast(@alignCast(ptr));
}

fn randname(buf: *[]u8) void {
    var ts: c.struct_timespec = undefined;
    const res = c.clock_gettime(c.CLOCK_REALTIME, &ts);
    if (res != 0) {
        return;
    }
    var r: u64 = @bitCast(ts.tv_nsec);
    for (0..buf.len) |i| {
        //had to cast r to u8 for u64
        const temp: u8 = @truncate(r);
        buf[i] = 'A' + (temp & 15) + (temp & 16) * 2;
        r >>= 5;
    }
}

fn create_shm_file() i16 {
    for (0..100) |_| {
        var name = []u8"/wl_shm-XXXXXX".*;
        var slice = name[8..];
        randname(&slice);
        std.log.info("randname = {s}", .{name});
        break;
    }
    return 0;
}

pub fn main() !void {
    std.log.info("Hello from client", .{});
    _ = create_shm_file();
}
