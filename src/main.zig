pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    // try stdout.print("Run `zig build test` to run the tests.\n", .{});

    const width: usize = 256;
    const height: usize = 256;

    try stdout.print("P3\n{} {}\n255\n", .{ width, height });

    for (0..height) |i| {
        for (0..width) |j| {
            const r = @as(usize, @as(f64, i) / (width - 1) * 255.999);
            const g = @as(usize, @as(f64, j) / (height - 1) * 255.999);
            const b = 0.0;

            stdout.print("{} {} {}\n", .{ r, g, b });
        }
    }

    // for (height, 0..) |value, i| {}

    try bw.flush(); // Don't forget to flush!
}

const std = @import("std");

// /// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
// const lib = @import("raytracing_one_week_lib");
