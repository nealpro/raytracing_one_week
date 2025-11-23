const _vec = @import("raytracing_one_week").vec;
const vec3 = _vec.vec3;
const point3 = _vec.point3;

pub const ray = struct {
    const orig = point3;
    const dir = vec3;

    pub fn new(origin: point3, direction: vec3) ray {
        return ray{
            .orig = origin,
            .dir = direction,
        };
    }

    pub fn at(self: ray, t: f64) vec3 {
        return vec3.add(self.orig, vec3.scalarMul(t, self.dir));
    }

    pub fn get_origin(self: ray) *const point3 {
        return self.orig;
    }

    pub fn get_direction(self: ray) *const vec3 {
        return self.dir;
    }
};
