#include "raylib.h"
#include "rlights.h"
#include "raymath.h"

int main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "Gerstner Waves");

    Camera camera = {{0.0f, 2.0f, 2.0f}, {0.0f, 0.0f, 0.0f}, {0.0f, 1.0f, 0.0f}, 45.0f, 0};

    // Model drawing position
    Vector3 position = {0.0f, 0.0f, 0.0f};

    Image checked = GenImageChecked(4, 4, 1, 1, RED, GREEN);
    Texture2D texture = LoadTextureFromImage(checked);
    UnloadImage(checked);
    // GenMeshPlane has width, height, numtrianglesX, numtrianglesY

    Shader shader = LoadShader("shaders/Waves_Vertex.vs",
                               "shaders/Waves_Fragment.fs");

    // Get some required shader loactions
    shader.locs[SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shader, "viewPos");
    // NOTE: "matModel" location name is automatically assigned on shader loading,
    // no need to get the location again if using that uniform name
    // shader.locs[SHADER_LOC_MATRIX_MODEL] = GetShaderLocation(shader, "matModel");

    // Ambient light level (some basic lighting)
    int ambientLoc = GetShaderLocation(shader, "ambient");
    float amb[4] = {0.1f, 0.1f, 0.1f, 1.0f};
    SetShaderValue(shader, ambientLoc, amb, SHADER_UNIFORM_VEC4);

    Model plane = LoadModelFromMesh(GenMeshPlane(100, 100, 200, 200));
    // plane.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;
    plane.materials[0].shader = shader;

    Light light = CreateLight(LIGHT_POINT, (Vector3){500, 500, -500}, Vector3Zero(), WHITE, shader);
    SetCameraMode(camera, CAMERA_FREE); // Set a orbital camera mode

    int timeLoc = GetShaderLocation(shader, "time");

    SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose()) // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(&camera);
        float time = (float)GetTime();
        SetShaderValue(shader, timeLoc, &time, SHADER_UNIFORM_FLOAT);

        float cameraPos[3] = {camera.position.x, camera.position.y, camera.position.z};
        SetShaderValue(shader, shader.locs[SHADER_LOC_VECTOR_VIEW], cameraPos, SHADER_UNIFORM_VEC3);
        // light.position.x = cameraPos[0];
        // light.position.y = cameraPos[1];
        // light.position.z = cameraPos[2];
        // UpdateLightValues(shader, light);

        //----------------------------------------------------------------------------------
        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        BeginMode3D(camera);
        DrawModel(plane, position, 1.0f, BLUE);
        // DrawModelWires(plane, position, 1.0f, BLACK);
        // DrawGrid(10, 1.0);

        EndMode3D();

        DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow(); // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    return 0;
}