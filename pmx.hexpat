#pragma pattern_limit 1000000

char signature[0x04] @ 0x00;
float version @ 0x04;
u8 globals_count @ 0x08;
u8 globals[globals_count] @ 0x09;

struct Text {
    u32 length;
    char16 string[length / 2];
};

Text name_en @ 0x11;
Text name_jp @ 0x2f;
Text comment_en @ 0x4d;
Text comment_jp @ 0x7b;

struct Vector2 {
    float x;
    float y;
};

struct Vector3 {
    float x;
    float y;
    float z;
};

struct Index {
    if (globals[2] == 1) u8 i;
    if (globals[2] == 2) u16 i;
    if (globals[2] == 4) u32 i;
};

struct BDEF1 {
    Index index;
};

struct BDEF2 {
    Index index_1;
    Index index_2;
    float weight;
};

struct BDEF4 {
    Index index_1;
    Index index_2;
    Index index_3;
    Index index_4;
    float weight_1;
    float weight_2;
    float weight_3;
    float weight_4;
};

struct SDEF {
    Index index_1;
    Index index_2;
    float weight;
    Vector3 c;
    Vector3 r0;
    Vector3 r1;
};

struct Vertex {
    Vector3 pos;
    Vector3 normal;
    Vector2 uv;
    
    u8 deform_type;
    if (deform_type == 0) BDEF1 deform;
    if (deform_type == 1) BDEF2 deform;
    if (deform_type == 2) BDEF4 deform;
    if (deform_type == 3) BDEF4 deform;
    
    float edge_scale;
};

s32 vertex_count @ 0xa9;
Vertex vertices[vertex_count] @ 0xad;
