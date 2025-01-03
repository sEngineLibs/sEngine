let project = new Project("sEngine");

project.addAssets("Assets/**");
project.addShaders("Shaders/**");
project.addSources("Sources");

await project.addProject("Subprojects/sCore");
await project.addProject("Subprojects/sUI");
await project.addProject("Subprojects/s2D");

// Available Compiler Flags
// SENGINE_DEBUG_FPS -> enables FPS debugging

resolve(project);
