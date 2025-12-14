const _vec = @import("vec.zig");
const vec3 = _vec.vec3;
const point3 = _vec.point3;

pub const ray = struct {
    orig: point3,
    dir: vec3,

    pub fn new(origin: point3, direction: vec3) ray {
        return ray{
            .orig = origin,
            .dir = direction,
        };
    }

    pub fn at(self: *const ray, t: f64) vec3 {
        return vec3.appendNew(&self.orig, &vec3.scalarMulNew(t, &self.dir));
    }

    pub fn get_origin(self: *const ray) *const point3 {
        return &self.orig;
    }

    pub fn get_direction(self: *const ray) *const vec3 {
        return &self.dir;
    }
};
