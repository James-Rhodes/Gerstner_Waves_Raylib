#version 430

// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec4 vertexColor;

// Input uniform values
uniform mat4 mvp;
uniform mat4 matModel;
uniform mat4 matNormal;

// Output vertex attributes (to fragment shader)
out vec3 fragPosition;
out vec2 fragTexCoord;
out vec4 fragColor;
out vec3 fragNormal;

// Gerstner Wave Variables
uniform float time;

#define PI 3.14159265359

vec3 GerstnerWave(vec4 wave, vec3 p, inout vec3 tangent, inout vec3 binormal){
    //Gersner waves
    //wave is dirX,dirY,steepness,wavelength
    float steepness = wave.z;
    float wavelength = wave.w;
    vec2 dir = normalize(wave.xy);


    float k = 2.0*3.141592/wavelength;
    float c = sqrt(9.8/k);
    float a = steepness/k;
    float f = k*(dot(dir,p.xz) - c*time);


    tangent += vec3(1.0-dir.x*dir.x*steepness*sin(f),
                        dir.x*steepness*cos(f),
                        -dir.x*dir.y*steepness*sin(f));
    
    binormal += vec3(-dir.x*dir.y*steepness*sin(f),
                        dir.y*steepness*cos(f),
                        1.0-dir.y*dir.y*steepness*sin(f));
    
    return vec3(dir.x*a*cos(f),a*sin(f),dir.y*a*cos(f));//dir.y = direction in z direction
}

float rand(float n){return fract(sin(n) * 43758.5453123);}

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

float GetSteepness(float x){
    return -(1.0/(5.0*PI))*(atan(0.5*(x-3.5)))+0.1;
}

void main()
{
    // vec4 waveA = vec4(1.0,1.0,0.33,60.0); 
    // vec4 waveB = vec4(1.0,0.6,0.5,31.0);
    // vec4 waveC = vec4(1.0,1.3,0.25,18.0); 

    float NUM_WAVES = 30.0;

    vec3 vertPos = vertexPosition;
    vec3 p = vertPos;

    vec3 tangent = vec3(0.0);
    vec3 binormal = vec3(0.0);

    float wavelength = 50.0;
    vec2 direction = vec2(rand(1.0),rand(100.0));
    float steepness = 0.2;

    vec4 wave = vec4(direction.xy,steepness,wavelength);

    for(float i = 0.0; i<NUM_WAVES; i++){

        vertPos += GerstnerWave(wave,p,tangent,binormal);

        wavelength *= 0.7;
        if(i<2.5){
            direction = rotate2d((PI/3.0)+rand(1000.0*(i+1.0)/0.8))*direction; 
        }else{
            direction = vec2(rand(1.0*(i+1.0)),rand(100.0*(i+1.0)));
        }
        steepness = GetSteepness(i);
        wave = vec4(direction.xy,steepness,wavelength);

    }



    vec3 vertNorm = normalize(cross(binormal,tangent));

    

    // Send vertex attributes to fragment shader
    fragPosition = vec3(matModel*vec4(vertPos, 1.0));
    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;
    fragNormal = normalize(vec3(matNormal*vec4(vertNorm, 1.0)));



    // Calculate final vertex position
    gl_Position = mvp*vec4(vertPos, 1.0);
}