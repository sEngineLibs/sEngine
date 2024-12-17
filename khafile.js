let project = new Project("sEngine");

project.addAssets("Assets/**");
project.addShaders("Shaders/**");
project.addSources("Sources");

await project.addProject("Subprojects/sCore");
await project.addProject("Subprojects/sUI");
await project.addProject("Subprojects/s2D");

// -> Engine Compiler Flags
// --> Debugging
project.addDefine("SENGINE_DEBUG_FPS");
// S2D
project.addDefine("S2D_SHOW_GRID");

resolve(project);
