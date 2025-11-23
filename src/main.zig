const std = @import("std");
const raytracing_one_week = @import("raytracing_one_week");
const vec = raytracing_one_week.vec;
const vec3 = raytracing_one_week.vec.vec3;
const ray = raytracing_one_week.ray.ray;
const image = raytracing_one_week.image;

pub fn main() !void {
    defer std.log.debug("Your program ran into a success!", .{});

    // Writer for stdout
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer: std.fs.File.Writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.io.Writer = &stdout_writer.interface;

    const img = image{};
    try stdout.print("P3\n{} {}\n255\n", .{ img.width, img.height });
    for (0..img.height) |i| {
        std.log.debug("Scanlines remaining: {}", .{img.height - i});
        for (0..img.width) |j| {
            const color = vec.color{ .base = vec3.new(
                @as(f64, @floatFromInt(j)) / (@as(f64, img.width) - 1.0),
                @as(f64, @floatFromInt(i)) / (@as(f64, img.height) - 1.0),
                0.55,
            ) };

            try color.writeColor(stdout);
        }
    }

    try stdout.flush();
}
