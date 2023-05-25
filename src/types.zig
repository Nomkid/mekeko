pub const Model = struct {
    name: []const u8,
    mesh: Mesh,
};

pub const Mesh = struct {
    vertices: []Vector3 = &[_]Vector3{},
    normals: ?[]Vector3 = null,
    tangents: ?[]f32 = null,
    colors: ?[]Vector3 = null, // using Vector3 for now, TODO: write a Color type
    tex_uv: ?[]Vector2 = null,
    tex_uv2: ?[]Vector2 = null,
    bones: ?[]usize = null,
    weights: ?[]f64 = null,
    index: []usize = &[_]usize{},
};

pub const Vector2 = struct { x: f32, y: f32 };
pub const Vector2i = struct { x: i32, y: i32 };
pub const Vector3 = struct { x: f32, y: f32, z: f32 };
pub const Vector3i = struct { x: i32, y: i32, z: i32 };
pub const Vector4 = struct { w: f32, x: f32, y: f32, z: f32 };
pub const Vector4i = struct { w: i32, x: i32, y: i32, z: i32 };
