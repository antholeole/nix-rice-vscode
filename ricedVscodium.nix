{ 
    pkgs, 
    pkg,
    css ? [],
    js ? [],
    ...
}: let
	lib = pkgs.lib;

    htmlPath = "resources/app/out/vs/code/electron-sandbox/workbench/workbench.html";

    files = with builtins; let 
        assetsPath = "TODO";

        mapPath = fileType: files: map (old: {
            inherit old;
            new = "${assetsPath}/${builins.hashFile "sha256" old}.${fileType}";
        }) files;
    in {
        css = mapPath "css" css;
        js = mapPath "js" js;
    };

    # We have to put the files in one of the directories under /gulpfile.vscode.js#L210

    mkCss = path: "<link rel=\"stylesheet\" type=\"text/css\" href=\"${path}\">";
    mkJs = path: "<script type=\"text/javascript\" src=\"${path}\"></script>";
in pkg.overrideAttrs {
    postInstall = let 
        allFiles = files.css ++ files.js;
        cpCmds = builtins.map (file: "cp ${file.old} ${file.new}") allFiles;        

    in lib.strings.concatStringsSep "\n" cpCmds;

    patches = let 
        rawLines = (map mkCss files.css.new) ++ (map mkJs files.js.new);
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
