//
//  Shader.metal
//  Snake
//
//  Created by Hanyuan Ye on 2019-07-03.
//  Copyright © 2019 HY. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct VertexOut {
    vector_float4 position [[position]];
    vector_float4 color;
};

vertex float4 basic_vertex(const device packed_float3* vertex_array [[ buffer(0) ]],
                           unsigned int vid [[ vertex_id ]]) {
    return float4(vertex_array[vid], 1.0);
}

fragment half4 basic_fragment() {
    return half4(1.0);              
}

vertex VertexOut vertexShader(const constant vector_float2 *vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]]) {
    vector_float2 currentVertex = vertexArray[vid]; //fetch the current vertex we're on using the vid to index into our buffer data which holds all of our vertex points that we passed in
    VertexOut output;
    
    output.position = vector_float4(currentVertex.x, currentVertex.y, 0, 1); //populate the output position with the x and y values of our input vertex data
    output.color = vector_float4(1,1,1,1); //set the color
    
    return output;
}

fragment vector_float4 fragmentShader(VertexOut interpolated [[stage_in]]) {
    return interpolated.color;
}
