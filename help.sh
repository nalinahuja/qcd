# Developed by Nalin Ahuja, nalinahuja22

command cat << EOF
${__B}QCD Utility - v${__VERSION}${__N}

${__B}Usage:${__N}
  qcd                                   Change to home directory
  qcd [path]                            Change to valid directory
  qcd [link]/[subdir]/...               Change to linked directory
  qcd [N]..                             Change to Nth parent directory

${__B}Options:${__N}
  qcd [-h, --help]                      Show this help
  qcd [-c, --clean]                     Clean store file
  qcd [-v, --version]                   Show current version
  qcd [-u, --update]                    Update to latest version
  qcd [-b, --back-dir]                  Navigate to backward directory
  qcd [-t, --track-dirs]                Set directory tracking behavior

  qcd [-r, --remember]                  Remember present directory
  qcd [-f, --forget]                    Forget present directory
  qcd [-l, --list]                      List directory linkages

  qcd [path] [-r, --remember]           Remember directory by path
  qcd [link] [-o, --options]            Show symbolic link options
  qcd [link] [-f, --forget]             Forget matching symbolic links
  qcd [path] [-m, --mkdir]              Create and switch to directory
  qcd [regex] [-l, --list]              List matching directory linkages

  qcd [path] [alias] [-r, --remember]   Remember directory by alias

Developed by Nalin Ahuja, nalinahuja22
EOF
