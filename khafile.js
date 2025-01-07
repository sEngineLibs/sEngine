const fs = require("fs");
const path = require("path");

function preprocessShader(filePath, basePath) {
    const includeRegex = /^\s*#include\s+"(.+)"\s*$/gm;

    let shaderSource = fs.readFileSync(filePath, "utf8");
    let match;

    while ((match = includeRegex.exec(shaderSource)) !== null) {
        const includePath = `${path.resolve(basePath, match[1])}.glsl`;
        if (!fs.existsSync(includePath)) {
            throw new Error(`Included file not found: ${includePath}`);
        }

        const includeContent = fs.readFileSync(includePath, "utf8");
        shaderSource = shaderSource.replace(match[0], includeContent);
    }

    return shaderSource;
}

function preprocessShaders(shaderDir, outputDir) {
    const shaderInputDir = path.join(__dirname, shaderDir);
    const shaderOutputDir = path.join(__dirname, outputDir);

    if (!fs.existsSync(shaderOutputDir)) {
        fs.mkdirSync(shaderOutputDir, { recursive: true });
    }

    const shaderFiles = fs
        .readdirSync(shaderInputDir)
        .filter((file) => file.endsWith(".glsl"));

    shaderFiles.forEach((shaderFile) => {
        const inputPath = path.join(shaderInputDir, shaderFile);
        const outputPath = path.join(shaderOutputDir, shaderFile);
        const processedSource = preprocessShader(inputPath, shaderInputDir);

        fs.writeFileSync(outputPath, processedSource, "utf8");
        console.log(`Processed shader: ${shaderFile}`);
    });
}

let project = new Project("sEngine");

project.addSources("src");
project.addAssets("assets/**", {
    nameBaseDir: "assets",
    destination: "assets/{dir}/{name}",
    name: "{name}",
});

preprocessShaders("shaders", "shaders_preprocessed");
project.addShaders("shaders_preprocessed/**");

// Available Engine Compiler Flags:

// Debug:
// S2D_DEBUG_FPS -> enables FPS debugging

// Renderer:
// S2D_RP_ENV_LIGHTING -> enables environment lighting
// S2D_PP -> enables Post-Processing
// S2D_PP_DOF -> enables Depth of Field PP effect
// S2D_PP_DOF_QUALITY_LEVEL -> sets the quality level of DOF effect (0 - low, 1 - middle, 2 - high)
// S2D_PP_MIST -> enables Mist PP effect
// S2D_PP_FISHEYE -> enables Fisheye PP effect
// S2D_PP_FILTER -> enables 3x3 image convolution multi-pass PP effects
// S2D_PP_COMPOSITOR -> enables compositor / single-pass combination of various (AA, CC etc.) PP effects

resolve(project);
