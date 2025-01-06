let project = new Project("sEngine");

project.addAssets("assets/**", {
    nameBaseDir: "assets",
    destination: "assets/{dir}/{name}",
    name: "{name}",
});
project.addSources("src");

await project.addProject("subprojects/sCore");
await project.addProject("subprojects/sUI");
await project.addProject("subprojects/s2D");

// Available Compiler Flags
// SENGINE_DEBUG_FPS -> enables FPS debugging

resolve(project);
