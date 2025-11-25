const std = @import("std");
const sqrt = std.math.sqrt;
const raytracing_one_week = @import("raytracing_one_week");
const vec = raytracing_one_week.vec;
const vec3 = raytracing_one_week.vec.vec3;
const point3 = raytracing_one_week.vec.point3;
const Ray = raytracing_one_week.ray.Ray;

fn height_from_width(width: u64, aspect_ratio: f64) u64 {
    const height_candidate: u64 = @intFromFloat(@as(f64, @floatFromInt(width)) / aspect_ratio);
    if (height_candidate < 1) {
        return 1;
    }
    return height_candidate;
}

fn hit_sphere(center: *const point3, radius: f64, r: *const Ray) f64 {
    const oc = center.subtractNew(r.get_origin());
    const a = vec3.dot(r.get_direction(), r.get_direction());
    const b = -2.0 * vec3.dot(r.get_direction(), &oc);
    const c = vec3.dot(&oc, &oc) - (radius * radius);
    const discriminant = (b * b) - (4 * a * c);

    if (discriminant < 0) {
        return -1.0;
    }

    return (-b - sqrt(discriminant)) / (2.0 * a);
    // return discriminant >= 0;
}

// fn hit_square(origin_candidate: ?*const point3, side_length: f64, r: *const Ray) bool {
//     const origin = origin_candidate orelse point3.new(1, 1, 1);
//     _ = origin;
//     _ = side_length;
//     _ = r;
// }

fn ray_color(ray: *const Ray) vec.color {
    const center = point3.new(0, 0, -1);
    const t = hit_sphere(&center, 0.5, ray);
    if (t > 0.0) {
        var n_intermediate = vec3.new(0, 0, -1).negative();
        n_intermediate.append(ray.at(t));
        const n: vec3 = vec3.unit(&n_intermediate);
        return vec.color{ .base = vec3.new(n.x() + 1, n.y() + 1, n.z() + 1).scaleDownNew(2) };
    }
    // if (hit_sphere(&center, 0.5, ray)) {
    //     return vec.color{ .base = vec3.new(1, 0, 0) };
    // }

    const unit_direction: vec3 = vec3.unit(ray.get_direction());
    const a = (unit_direction.y() + 1.0) * 0.5;
    return vec.color{
        .base = vec3.new(1.0, 1.0, 1.0).scaleUpNew(1.0 - a).appendNew(
            &vec3.new(0.5, 0.7, 1.0).scaleUpNew(a),
        ),
    };
}

const image = struct {
    width: u64,
    aspect_ratio: f64,
    height: u64,
};

pub fn main() !void {
    errdefer std.log.err("Your program ran into a failure!", .{});
    defer std.log.debug("Your program ran into a success!", .{});

    // Writer for stdout
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer: std.fs.File.Writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.io.Writer = &stdout_writer.interface;

    const aspect_ratio = 16.0 / 9.0;
    const width: u64 = 1200;
    const height = height_from_width(width, aspect_ratio);

    const img = image{
        .width = width,
        .aspect_ratio = aspect_ratio,
        .height = height,
    };

    const viewport_height = 2.0;
    const viewport_width = viewport_height * img.aspect_ratio;
    const focal_length = 1.0;
    const camera_center = point3.new(0.0, 0.0, 0.0);

    const viewport_u = vec3.new(viewport_width, 0, 0);
    const viewport_v = vec3.new(0, -viewport_height, 0);

    const pixel_delta_u = viewport_u.scaleDownNew(@floatFromInt(img.width));
    const pixel_delta_v = viewport_v.scaleDownNew(@floatFromInt(img.height));

    const viewport_upper_left = camera_center
        .subtractNew(&vec3.new(0, 0, focal_length))
        .subtractNew(&viewport_u.scaleDownNew(2))
        .subtractNew(&viewport_v.scaleDownNew(2));

    const pixel00_location = viewport_upper_left.appendNew(&(&pixel_delta_u.appendNew(&pixel_delta_v)).scaleDownNew(2));

    try stdout.print("P3\n{} {}\n255\n", .{ img.width, img.height });

    for (0..img.height) |i| {
        if (i % 15 == 0) {
            std.log.debug("Scanlines remaining: {}", .{img.height - i});
        }
        for (0..img.width) |j| {
            const pixel_center = pixel00_location.appendNew(&pixel_delta_u.scaleUpNew(@as(f64, @floatFromInt(j)))).appendNew(&pixel_delta_v.scaleUpNew(@as(f64, @floatFromInt(i))));
            const ray_direction = pixel_center.subtractNew(&camera_center);
            const r = Ray.new(camera_center, ray_direction);
            const pixel_color = ray_color(&r);
            try pixel_color.writeColor(stdout);
        }
    }

    try stdout.flush();
}
