{ 
    pkgs, 
    pkg,
    css ? [],
    js ? []
    ... 
}: let
	lib = pkgs.lib;
in pkg.overrideAttrs {
    patches = let 
        htmlPath = "resources/app/out/vs/code/electron-sandbox/workbench/workbench.html";

        mkCss = path: "<link rel=\"stylesheet\" type=\"text/css\" href=\"${path}\">";
        mkJs = path: "<script type=\"text/javascript\" src=\"${path}\"></script>";

        rawLines = (map mkCss css or []) ++ (map mkJs js or []);
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
