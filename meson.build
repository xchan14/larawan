# project name and programming language
project('io.github.xchan14.larawan', 'vala', 'c')

gnome = import('gnome')

i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

asresources = gnome.compile_resources(
    'as-resources', 
    'data' / meson.project_name() + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    asresources,
    config_file,
    'src' / 'Application.vala',
    'src' / 'Constants.vala',
    'src' / 'widgets' / 'EntryButton.vala',
    'src' / 'views' / 'MainWindow.vala',
    'src' / 'views' / 'SettingsDialog.vala',
    'src' / 'models' / 'SlideshowImage.vala',
    'src' / 'models' / 'SlideshowPlaylist.vala',
    'src' / 'models' / 'FileHelper.vala',
    dependencies: [
        dependency('glib-2.0', version: '>=2.70'),
        dependency('gtk4'),
        dependency('granite-7'),
        dependency('libadwaita-1')
    ],
    link_args : ['-lm',],
    install: true
)

#Translate and install our .desktop file
i18n.merge_file(
    input: 'data' / meson.project_name() + '.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.source_root() / 'po',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

#Translate and install our .metainfo file
i18n.merge_file(
    input: 'data' / meson.project_name() + '.metainfo.xml.in',
    output: meson.project_name() + '.metainfo.xml',
    po_dir: meson.source_root() / 'po',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

subdir('data')
subdir('po')

gnome.post_install(glib_compile_schemas: true)