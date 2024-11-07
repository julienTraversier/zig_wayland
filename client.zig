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

fn randname(buf: *[6]u8) void {
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
pub fn main() !void {
    std.log.info("Hello from client", .{});
    var buf: [6]u8 = undefined;
    randname(&buf);
    std.log.info("randname = {s}", .{buf});
}
