# project name and programming language
project('io.github.xchan14.larawan', 'vala', 'c')

gnome = import('gnome')

asresources = gnome.compile_resources(
    'as-resources', 
    'data' / meson.project_name() + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    asresources,
    'src' / 'Application.vala',
    'src' / 'Constants.vala',
    'src' / 'Views' / 'MainWindow.vala',
    'src' / 'Views' / 'SettingsDialog.vala',
    dependencies: [
        dependency('gtk4'),
        dependency('granite-7'),
        dependency('libadwaita-1')
    ],
    install: true
)

# Install our .desktop file so the Applications Menu will see it
install_data(
    'data' / meson.project_name() + '.desktop',
    install_dir: get_option('datadir') / 'applications',
    rename: meson.project_name() + '.desktop'
)

# Install our .metainfo.xml file so AppCenter will see it
install_data(
    'data' / meson.project_name() + '.metainfo.xml',
    install_dir: get_option('datadir') / 'metainfo',
    rename: meson.project_name() + '.metainfo.xml'
)

install_data (
    'data' / meson.project_name() + '.gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas',
    rename: meson.project_name() + '.gschema.xml'
)

gnome.post_install(glib_compile_schemas: true)