let project = new Project("New Project");

project.addAssets("Assets/**");
project.addShaders("Shaders/**");
project.addSources("Sources");

await project.addProject("Subprojects/sCore");
await project.addProject("Subprojects/sUI");
await project.addProject("Subprojects/s2D");

// -> Engine Compiler Flags
// --> Debugging
project.addDefine("SENGINE_DEBUG_FPS");

resolve(project);
