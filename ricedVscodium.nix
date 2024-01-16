{ 
    lib, 
    pkgs, 
    rice ? { css = []; js = []; }, 
    ... 
}: pkgs.vscodium.overrideAttrs {
    patches = let 
        htmlPath = "resources/app/out/vs/code/electron-sandbox/workbench/workbench.html";

        inline = path: builtins.replaceStrings ["\n"] [""] (builtins.readFile path);

        mkCss = path: "<style>${inline path}</style>";
        mkJs = path: "<script>${inline path}</script>";

        rawLines = (map mkCss rice.css or []) ++ (map mkJs rice.js or []);
        patchLines = map (rawLine: "+	${rawLine}") rawLines; 

        patch = with builtins; ''
diff --git a/${htmlPath} b/${htmlPath}
index eb525bd..e0d57bf 100644
--- a/${htmlPath}
+++ b/${htmlPath}
@@ -69,4 +69,${toString (4 + length patchLines)} @@
 
 	<!-- Startup (do not modify order of script tags!) -->
 	<script src="workbench.js"></script>
${lib.strings.concatStringsSep "\n" patchLines}
 </html>
        '';

      patchFile = pkgs.writeText "injected.patch" patch;
    in if (builtins.length patchLines > 0) then [
        patchFile
    ] else [];
}