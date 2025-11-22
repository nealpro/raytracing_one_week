const std = @import("std");
const raytracing_one_week = @import("raytracing_one_week");

pub fn main() !void {
    try raytracing_one_week.generateImageCheck();
}
