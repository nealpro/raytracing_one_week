//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

const fileWriter = std.fs.File.Writer;
const ioWriter = std.io.Writer;

pub const vec = @import("vec.zig");
pub const ray = @import("ray.zig");

test "generate image" {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer: fileWriter = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *ioWriter = &stdout_writer.interface;

    const width = 256;
    const height = 256;

    try stdout.print("P3\n{} {}\n255\n", .{ width, height });

    for (0..height) |i| {
        std.log.debug("Scanlines remaining: {}", .{height - i});
        for (0..width) |j| {
            const color = vec.color{ .base = vec.vec3.new(
                @as(f64, @floatFromInt(j)) / (width - 1),
                @as(f64, @floatFromInt(i)) / (height - 1),
                0.55,
            ) };

            try color.writeColor(stdout);
        }
    }
    std.log.debug("Done.", .{});

    try stdout.flush(); // Don't forget to flush the buffer!
}
