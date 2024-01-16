{ 
    lib, 
    pkgs, 
    rice ? { css = []; js = []; }, 
    ... 
}: pkgs.vscodium.overrideAttrs {
    patches = let 
        htmlPath = "lib/vscode/resources/app/out/vs/code/electron-sandbox/workbench/workbench.html";

        mkCss = path: "<link rel=\"stylesheet\" href=\"file://${path}\">";
        mkJs = path: "<script src=\"file://${path}\"></script>";

        rawLines = (map mkCss rice.css) ++ (map mkJs rice.js);
        patchLines = map (rawLine: "+	${rawLine}") rawLines; 

        patch = with builtins; ''
diff --git a/resources/app/out/vs/code/electron-sandbox/workbench/workbench.html b/resources/app/out/vs/code/electron-sandbox/workbench/workbench.html
index eb525bd..e0d57bf 100644
--- a/resources/app/out/vs/code/electron-sandbox/workbench/workbench.html
+++ b/resources/app/out/vs/code/electron-sandbox/workbench/workbench.html
@@ -69,4 +69,${toString (4 + length patchLines)} @@
 
 	<!-- Startup (do not modify order of script tags!) -->
 	<script src="workbench.js"></script>
${lib.strings.concatStringsSep "\n" patchLines}
 </html>
        '';

      patchFile = pkgs.writeText "injected.patch" patch;
    in [
        patchFile
    ];
}