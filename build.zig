const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe_client = b.addExecutable(.{ .name = "client", .target = b.host, .root_source_file = b.path("client.zig") });
    const exe_server = b.addExecutable(.{ .name = "server", .target = b.host, .root_source_file = b.path("server.zig") });
    b.installArtifact(exe_client);
    b.installArtifact(exe_server);
    exe_client.addCSourceFile(.{
        .file = b.path("./shm_open.c"),
    });
    exe_client.addCSourceFile(.{
        .file = b.path("./xdg-shell-protocol.c"),
    });
    exe_client.linkSystemLibrary("c");
    exe_client.linkSystemLibrary("wayland-client");
    // exe_client.linkSystemLibrary("rt");
    exe_client.root_module.addIncludePath(b.path("."));

    exe_server.linkSystemLibrary("c");
    exe_server.linkSystemLibrary("wayland-server");
}
