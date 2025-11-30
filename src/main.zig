const std = @import("std");
const sqrt = std.math.sqrt;
const rtow = @import("raytracing_one_week");
const vec = rtow.vec;
const vec3 = rtow.vec.vec3;
const point3 = rtow.vec.point3;
const Ray = rtow.ray.Ray;

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

fn hit_cube(center: *const point3, radius: f64, r: *const Ray) f64 {
    const rad_vec = vec3.new(radius, radius, radius);
    const min = center.subtractNew(&rad_vec);
    const max = center.appendNew(&rad_vec);

    var t_min: f64 = -std.math.inf(f64);
    var t_max: f64 = std.math.inf(f64);

    const origin = r.get_origin();
    const direction = r.get_direction();

    // X axis
    {
        const invD = 1.0 / direction.x();
        var t0 = (min.x() - origin.x()) * invD;
        var t1 = (max.x() - origin.x()) * invD;
        if (invD < 0.0) {
            const temp = t0;
            t0 = t1;
            t1 = temp;
        }
        if (t0 > t_min) t_min = t0;
        if (t1 < t_max) t_max = t1;
        if (t_max <= t_min) return -1.0;
    }

    // Y axis
    {
        const invD = 1.0 / direction.y();
        var t0 = (min.y() - origin.y()) * invD;
        var t1 = (max.y() - origin.y()) * invD;
        if (invD < 0.0) {
            const temp = t0;
            t0 = t1;
            t1 = temp;
        }
        if (t0 > t_min) t_min = t0;
        if (t1 < t_max) t_max = t1;
        if (t_max <= t_min) return -1.0;
    }

    // Z axis
    {
        const invD = 1.0 / direction.z();
        var t0 = (min.z() - origin.z()) * invD;
        var t1 = (max.z() - origin.z()) * invD;
        if (invD < 0.0) {
            const temp = t0;
            t0 = t1;
            t1 = temp;
        }
        if (t0 > t_min) t_min = t0;
        if (t1 < t_max) t_max = t1;
        if (t_max <= t_min) return -1.0;
    }

    if (t_max > 0.0) {
        return t_min;
    }
    return -1.0;
}

fn ray_color(ray: *const Ray) vec.color {
    const center = point3.new(0, 0, -1);
    const radius = 0.33;
    const t = hit_cube(&center, radius, ray);
    if (t > 0.0) {
        const P = ray.at(t);
        const P_local = P.subtractNew(&center);

        const r_val = (P_local.x() + radius) / (2.0 * radius);
        const g_val = (P_local.y() + radius) / (2.0 * radius);
        const b_val = (P_local.z() + radius) / (2.0 * radius);

        return vec.color{ .base = vec3.new(
            std.math.clamp(r_val, 0.0, 1.0),
            std.math.clamp(g_val, 0.0, 1.0),
            std.math.clamp(b_val, 0.0, 1.0),
        ) };
    }

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
            const pixel_center = pixel00_location.appendNew(
                &pixel_delta_u.scaleUpNew(@as(f64, @floatFromInt(j))),
            ).appendNew(
                &pixel_delta_v.scaleUpNew(@as(f64, @floatFromInt(i))),
            );
            const ray_direction = pixel_center.subtractNew(&camera_center);
            const r = Ray.new(camera_center, ray_direction);

            if (i == 0 and j == img.width / 2) {
                std.log.debug("Debug Pixel (0, width/2)", .{});
                std.log.debug("Ray dir: {d}, {d}, {d}", .{ ray_direction.x(), ray_direction.y(), ray_direction.z() });
                const hit = hit_cube(&point3.new(0, 0, -1), 0.01, &r);
                std.log.debug("Hit: {}", .{hit});
            }

            const pixel_color = ray_color(&r);
            try pixel_color.writeColor(stdout);
        }
    }

    try stdout.flush();
}
