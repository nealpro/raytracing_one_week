const _vec = @import("vec.zig");
const vec3 = _vec.vec3;
const point3 = _vec.point3;

pub const Ray = struct {
    orig: point3,
    dir: vec3,

    pub fn new(origin: point3, direction: vec3) Ray {
        return Ray{
            .orig = origin,
            .dir = direction,
        };
    }

    pub fn at(self: *const Ray, t: f64) vec3 {
        return vec3.add(self.orig, vec3.scalarMul(t, self.dir));
    }

    pub fn get_origin(self: *const Ray) *const point3 {
        return &self.orig;
    }

    pub fn get_direction(self: *const Ray) *const vec3 {
        return &self.dir;
    }
};
