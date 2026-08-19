#version 450 core
#extension GL_ARB_separate_shader_objects : enable

layout(vertices = 4) out;

layout(binding = 0) uniform Uniforms {
    mat4 mvpMatrix;
    vec4 numberOfLineSegments;
    vec4 numberOfLineStrips;
    vec4 lineColor;
} uniforms;

void main(void) {

    // Quad domain (isolines is unsupported on MoltenVK/Metal): keep the
    // v-direction flat (level 1) and drive tessellation density along u,
    // the curve parameter, with numberOfLineSegments.
    gl_TessLevelOuter[0] = 1.0;
    gl_TessLevelOuter[1] = uniforms.numberOfLineSegments.x;
    gl_TessLevelOuter[2] = 1.0;
    gl_TessLevelOuter[3] = uniforms.numberOfLineSegments.x;

    gl_TessLevelInner[0] = uniforms.numberOfLineSegments.x;
    gl_TessLevelInner[1] = 1.0;

    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
}