pub const Cell = struct {
    const Self = @This();
    age: f32,
    health: f32 = 0.0,

    pub fn degradeHealth(self: *Self) void {
        self.health += 1.0;
    }
};
