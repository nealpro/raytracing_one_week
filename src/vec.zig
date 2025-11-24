const std = @import("std");
const ioWriter = std.io.Writer;

pub const vec3 = struct {
    // f64 slice with length 3
    e: [3]f64,
    pub fn new(e0: f64, e1: f64, e2: f64) vec3 {
        return vec3{
            .e = .{ e0, e1, e2 },
        };
    }

    pub fn default() vec3 {
        return vec3.new(0.0, 0.0, 0.0);
    }

    pub fn x(self: vec3) f64 {
        return self.e[0];
    }
    pub fn y(self: vec3) f64 {
        return self.e[1];
    }
    pub fn z(self: vec3) f64 {
        return self.e[2];
    }

    pub fn negative(self: vec3) vec3 {
        return vec3.new(-self.x(), -self.y(), -self.z());
    }

    // Immutable
    pub fn get_i(self: *const vec3, i: u8) [*]const f64 {
        if (i >= 3) {
            @panic("Index out of bounds");
        }
        return &self.e[i];
    }

    // Only use when you need to mutate the vector
    pub fn get_iPtr(self: *vec3, i: u8) [*]f64 {
        if (i >= 3) {
            @panic("Index out of bounds");
        }
        return &self.e[i];
    }

    // pub fn append(self: *vec3, other: vec3) void {
    //     self.e[0] += other.e[0];
    //     self.e[1] += other.e[1];
    //     self.e[2] += other.e[2];
    // }

    pub fn add(self: *const vec3, other: vec3) vec3 {
        return vec3.new(
            self.e[0] + other.e[0],
            self.e[1] + other.e[1],
            self.e[2] + other.e[2],
        );
    }

    pub fn subtract(self: *const vec3, other: vec3) vec3 {
        return vec3.new(
            self.e[0] - other.e[0],
            self.e[1] - other.e[1],
            self.e[2] - other.e[2],
        );
    }

    pub fn scalarAdd(self: *const vec3, t: f64) vec3 {
        return vec3.new(
            self.e[0] + t,
            self.e[1] + t,
            self.e[2] + t,
        );
    }

    pub fn scalarSub(self: *const vec3, t: f64) vec3 {
        return vec3.new(
            self.e[0] - t,
            self.e[1] - t,
            self.e[2] - t,
        );
    }

    pub fn scaleUp(self: *const vec3, t: f64) vec3 {
        return vec3.new(
            self.e[0] * t,
            self.e[1] * t,
            self.e[2] * t,
        );
    }

    pub fn scaleDown(self: *const vec3, t: f64) vec3 {
        return vec3.new(
            self.e[0] / t,
            self.e[1] / t,
            self.e[2] / t,
        );
    }

    pub fn clone(self: vec3) vec3 {
        return vec3.new(self.e[0], self.e[1], self.e[2]);
    }

    pub fn length(self: vec3) f64 {
        return @sqrt(self.lengthSquared());
    }
    pub fn lengthSquared(self: vec3) f64 {
        return self.e[0] * self.e[0] + self.e[1] * self.e[1] + self.e[2] * self.e[2];
    }

    // pub fn normalize(self: *vec3) void {
    //     self.scaleDown(self.length());
    // }

    // fn add(u: vec3, v: vec3) vec3 {
    //     return vec3.new(u.e[0] + v.e[0], u.e[1] + v.e[1], u.e[2] + v.e[2]);
    // }

    // fn sub(u: vec3, v: vec3) vec3 {
    //     return vec3.new(u.e[0] - v.e[0], u.e[1] - v.e[1], u.e[2] - v.e[2]);
    // }

    // fn mul(u: vec3, v: vec3) vec3 {
    //     return vec3.new(u.e[0] * v.e[0], u.e[1] * v.e[1], u.e[2] * v.e[2]);
    // }

    // fn div(u: vec3, v: vec3) vec3 {
    //     return vec3.new(u.e[0] / v.e[0], u.e[1] / v.e[1], u.e[2] / v.e[2]);
    // }

    // fn scalarMul(t: f64, v: vec3) vec3 {
    //     return vec3.new(t * v.e[0], t * v.e[1], t * v.e[2]);
    // }

    fn scalarDiv(v: *const vec3, t: f64) vec3 {
        return vec3.new(v.e[0] / t, v.e[1] / t, v.e[2] / t);
    }

    // fn dot(u: vec3, v: vec3) f64 {
    //     return u.e[0] * v.e[0] + u.e[1] * v.e[1] + u.e[2] * v.e[2];
    // }

    // fn cross(u: vec3, v: vec3) vec3 {
    //     return vec3.new(
    //         u.e[1] * v.e[2] - u.e[2] * v.e[1],
    //         u.e[2] * v.e[0] - u.e[0] * v.e[2],
    //         u.e[0] * v.e[1] - u.e[1] * v.e[0],
    //     );
    // }

    pub fn unit(v: *const vec3) vec3 {
        return vec3.scalarDiv(v, v.length());
    }
};

pub const point3 = vec3;

pub const color = struct {
    base: vec3,

    pub fn writeColor(self: color, writer: *ioWriter) !void {
        const r: f64 = self.base.x();
        const g: f64 = self.base.y();
        const b: f64 = self.base.z();

        const ir: u8 = @intFromFloat(r * 255.999);
        const ig: u8 = @intFromFloat(g * 255.999);
        const ib: u8 = @intFromFloat(b * 255.999);

        try writer.print("{} {} {}\n", .{ ir, ig, ib });
    }
};
