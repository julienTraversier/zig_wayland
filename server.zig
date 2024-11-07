const std = @import("std");
const ws = @cImport({
    @cInclude("wayland-server.h");
});
const Error = error{
    ERROR_DISPLAY_CREATE,
    ERROR_ADD_SOCKET_AUTO,
};

fn opaqPtrTo(comptime T: type, ptr: ?*anyopaque) T {
    return @ptrCast(@alignCast(ptr));
}

// fn output_handle_resource_destroy(resource: ?*ws.struct_wl_resource) callconv (.C) void {
//     var client_output = opaqPtrTo(ws.struct_wl_output, ws.wl_resource_get_user_data(resource));
//     //TODO : clean up resource
//     ws.wl_list_remove(client_output.state)
// }

fn wl_output_handle_release(client: ?*ws.struct_wl_client, resource: ?*ws.struct_wl_resource) callconv(.C) void {
    _ = client; // autofix
    ws.wl_resource_destroy(resource);
}
const wl_output_implementation: ws.struct_wl_output_interface = struct { .release = wl_output_handle_release };

// fn wl_output_handle_bind(client:?*ws.struct_wl_client, data:?*anyopaque, version:u32, id:u32) callconv(.C) void {
//     // const state:
// }

pub fn main() !void {
    std.log.info("Hello from server\n", .{});
    const display = ws.wl_display_create();
    if (display == null) {
        std.log.err("cant create display", .{});
        return Error.ERROR_DISPLAY_CREATE;
    }
    // const socket = ws.wl_display_add_socket_auto(display);
    const name_socket: [*c]const u8 = "wayland-1";
    const socket = ws.wl_display_add_socket(display, name_socket);
    if (socket != 0) {
        std.log.err("cant add socket auto", .{});
        return Error.ERROR_ADD_SOCKET_AUTO;
    }
    std.log.info("Running wayland display on {s}\n", .{name_socket});
    ws.wl_display_run(display);
    ws.wl_display_destroy(display);
}
