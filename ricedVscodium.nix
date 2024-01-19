{ 
    pkgs, 
    pkg,
    css ? [],
    js ? [],
    ... 
}: let
	lib = pkgs.lib;

    htmlPath = "resources/app/out/vs/code/electron-sandbox/workbench/workbench.html";
    assetsPath = "lib/vscode/resources/app/out/vs/code/electron-sandbox/workbench";

    files = with builtins; let 
        mapPath = fileType: files: map (old: {
            inherit old;
            new = "${builtins.hashFile "sha256" old}.${fileType}";
        }) files;
    in {
        css = mapPath "css" css;
        js = mapPath "js" js;
    };
in pkg.overrideAttrs {
    postInstall = let 
        allFiles = files.css ++ files.js;
        cpCmds = builtins.map (file: "cp ${file.old} $out/${file.new}") allFiles;        

    in lib.strings.concatStringsSep "\n" cpCmds;

    patches = with builtins; let 
        mkCss = path: "<link rel=\"stylesheet\" type=\"text/css\" href=\"${path.new}\">";
        mkJs = path: "<script type=\"text/javascript\" src=\"${path.new}\"></script>";

        rawLines = (map mkCss files.css) ++ (map mkJs files.js);
        patchLines = map (rawLine: "+	${rawLine}") rawLines; 

        patch =''
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
