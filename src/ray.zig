const vec = @import("vec.zig");
pub const ray = struct {
    const orig = vec.point3;
    const dir = vec.vec3;

    pub fn new(origin: vec.point3, direction: vec.vec3) ray {
        return ray{
            .orig = origin,
            .dir = direction,
        };
    }

    pub fn at(self: ray, t: f64) vec.vec3 {
        return vec.add(self.orig, vec.scalarMul(t, self.dir));
    }

    pub fn get_origin(self: ray) *const vec.point3 {
        return self.orig;
    }

    pub fn get_direction(self: ray) *const vec.vec3 {
        return self.dir;
    }
};
