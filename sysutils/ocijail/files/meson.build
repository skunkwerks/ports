project(
  'ocijail',
  'cpp',
  license: 'BSD-2-Clause',
  meson_version: '>=1.0',
  default_options: ['cpp_std=c++20', 'warning_level=1', 'buildtype=debugoptimized'],
)

# Both are header-only, from devel/nlohmann-json and devel/cli11.
json_dep = dependency('nlohmann_json', version: '>=3.11')
cli11_dep = dependency('CLI11')
m_dep = meson.get_compiler('cpp').find_library('m')

executable(
  'ocijail',
  'ocijail/create.cpp',
  'ocijail/delete.cpp',
  'ocijail/exec.cpp',
  'ocijail/features.cpp',
  'ocijail/hook.cpp',
  'ocijail/jail.cpp',
  'ocijail/kill.cpp',
  'ocijail/list.cpp',
  'ocijail/main.cpp',
  'ocijail/mount.cpp',
  'ocijail/process.cpp',
  'ocijail/start.cpp',
  'ocijail/state.cpp',
  'ocijail/tty.cpp',
  dependencies: [json_dep, cli11_dep, m_dep],
  install: true,
)
