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
@@ -62,6 +62,${toString (6 + length patchLines)} @@
 					tokenizeToString
 				;
 		"/>
${lib.strings.concatStringsSep "\n" patchLines}
 	</head>
 
 	<body aria-label="">
        '';

      patchFile = pkgs.writeText "injected.patch" patch;
    in if (builtins.length patchLines > 0) then [
        patchFile
    ] else [];
}