const std = @import("std");
const wc = @cImport({
    @cInclude("wayland-client.h");
    @cInclude("shm_open.h");
});

fn opaqPtrTo(comptime T: type, ptr: ?*anyopaque) T {
    return @ptrCast(@alignCast(ptr));
}

const our_state = struct {
    compositor: ?*wc.struct_wl_compositor,
    wl_shm: ?*wc.struct_wl_shm,
    fn new() our_state {
        return our_state{ .compositor = null, .wl_shm = null };
    }
};

fn registry_handle_global(data: ?*anyopaque, registry: ?*wc.struct_wl_registry, name: u32, interface: [*c]const u8, version: u32) callconv(.C) void {
    _ = version; // autofix
    // std.log.info("interface {s} version {d} ,name {d}\n", .{ interface, version, name });
    // var state = @as(*our_state, @alignCast(@ptrCast(data)));
    var state = opaqPtrTo(*our_state, data);
    if (interface == wc.wl_compositor_interface.name) {
        state.compositor = opaqPtrTo(*wc.struct_wl_compositor, wc.wl_registry_bind(registry, name, &wc.wl_compositor_interface, 4));
        state.wl_shm = opaqPtrTo(*wc.struct_wl_shm, wc.wl_registry_bind(registry, name, &wc.wl_shm_interface, 1));
    }
}
fn registry_handle_global_remove(data: ?*anyopaque, registry: ?*wc.struct_wl_registry, name: u32) callconv(.C) void {
    _ = name; // autofix
    _ = registry; // autofix
    _ = data; // autofix
    //left blank
}
const registry_listener = wc.struct_wl_registry_listener{ .global = registry_handle_global, .global_remove = registry_handle_global_remove };

pub fn main() anyerror!void {
    std.log.info("Hello from client", .{});
    const display = wc.wl_display_connect(null);
    const registry = wc.wl_display_get_registry(display) orelse return;
    var state: our_state = our_state.new();
    _ = wc.wl_registry_add_listener(registry, &registry_listener, &state);
    _ = wc.wl_display_roundtrip(display);
    // const surface = wc.wl_compositor_create_surface(state.compositor);
}
