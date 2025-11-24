const std = @import("std");
const raytracing_one_week = @import("raytracing_one_week");
const vec = raytracing_one_week.vec;
const vec3 = raytracing_one_week.vec.vec3;
const point3 = raytracing_one_week.vec.point3;
const Ray = raytracing_one_week.ray.Ray;

fn ray_color(ray: *const Ray) vec.color {
    const unit_direction: vec3 = vec3.unit(ray.get_direction());
    const a = (unit_direction.y() + 1.0) * 2;
    return vec.color{
        .base = vec3.new(1.0, 1.0, 1.0).scaleUp(1.0 - a).add(vec3.new(0.5, 0.7, 1.0).scaleUp(a)),
    };
    // return vec.color{ .base = vec3.new(0, 0, 0) };
}

const image = struct {
    width: u64,
    aspect_ratio: f64,
    height: u64,
};

pub fn main() !void {
    errdefer std.log.err("Your program ran into a failure!", .{});

    // Writer for stdout
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer: std.fs.File.Writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.io.Writer = &stdout_writer.interface;

    const aspect_ratio = 16.0 / 9.0;
    const width: u64 = 400;
    var height_candidate: u64 = @intFromFloat(@as(f64, width) / aspect_ratio);
    if (height_candidate < 1) {
        height_candidate = 1;
    }

    const img = image{
        .width = width,
        .aspect_ratio = aspect_ratio,
        .height = height_candidate,
    };

    const viewport_height = 2.0;
    const viewport_width = viewport_height * img.aspect_ratio;
    const focal_length = 1.0;
    const camera_center = point3.new(0.0, 0.0, 0.0);

    const viewport_u = vec3.new(viewport_width, 0, 0);
    const viewport_v = vec3.new(0, -viewport_height, 0);

    const pixel_delta_u = viewport_u.scaleDown(@floatFromInt(img.width));
    const pixel_delta_v = viewport_v.scaleDown(@floatFromInt(img.height));

    const viewport_upper_left = camera_center.subtract(vec3.new(0, 0, focal_length).subtract(viewport_u.scaleDown(2)).subtract(viewport_v.scaleDown(2)));
    const pixel00_location = viewport_upper_left.add((pixel_delta_u.add(pixel_delta_v)).scaleDown(2));

    try stdout.print("P3\n{} {}\n255\n", .{ img.width, img.height });

    for (0..img.height) |i| {
        std.log.debug("Scanlines remaining: {}", .{img.height - i});
        for (0..img.width) |j| {
            const pixel_center = pixel00_location.add(pixel_delta_u.scaleUp(@as(f64, @floatFromInt(j)))).add(pixel_delta_v.scaleUp(@as(f64, @floatFromInt(i))));
            const ray_direction = pixel_center.subtract(camera_center);
            const r = Ray.new(camera_center, ray_direction);
            const pixel_color = ray_color(&r);
            try pixel_color.writeColor(stdout);
        }
    }

    try stdout.flush();
}
