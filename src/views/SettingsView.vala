/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Christian Camilon <chancamilon@proton.me>
 */
using Gtk;
using Granite;
using Larawan.Constants;
using Larawan.Widgets;

public class Larawan.Views.SettingsView : Box {

    const double MAX_WINDOW_HEIGHT = 650;
    const double MAX_WINDOW_WIDTH = 650;
    const double MIN_WINDOW_HEIGHT = 300;
    const double MIN_WINDOW_WIDTH = 300;

    AlbumPicker album_picker = null;
    Switch shuffle_switch = null;
    GLib.Settings settings;
    FileDialog file_dialog;
    Scale duration_scale;
    Switch recursive_switch;
    Scale window_width_scale;
    Scale window_height_scale;
    LinkButton startup_linkbutton;

    public ApplicationWindow window { get; construct set; }

    public SettingsView (ApplicationWindow window) {
        Object (window: window);
    }

    construct {
        set_size_request (700, 0);
        add_css_class ("settings-view");
        orientation = Orientation.VERTICAL;
        spacing = 10;

        var slideshow_label = new Label (_("Slideshow")) {
            xalign = 0.0f
        };
        slideshow_label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);
        append (slideshow_label);
        add_album_folder_field ();
        add_recursive_field ();
        add_duration_field ();

        var window_label = new Label (_("Window")) {
            xalign = 0.0f
        };
        window_label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);
        window_label.add_css_class ("window-legend-label");

        append (window_label);
        add_startup_field ();
        add_always_visible_field ();
        add_width_field ();
        add_height_field ();

        bind_settings ();
        bind_events ();
    }

    private void bind_events () {
        album_picker.clicked.connect (() => {
            file_dialog.select_folder.begin (window, null, (obj, result) => {
                try {
                    File file = file_dialog.select_folder.end (result);
                    album_picker.value = file.get_path ();
                } catch (Error e) {
                    info (e.message);
                }
            });
        });
    }

    private void bind_settings () {
        settings = new GLib.Settings (APP_ID);
        settings.bind ("album-folder", album_picker, "value", SettingsBindFlags.DEFAULT);
        settings.bind ("shuffle", shuffle_switch, "active", SettingsBindFlags.DEFAULT);
        settings.bind ("recursive", recursive_switch, "active", SettingsBindFlags.DEFAULT);
        settings.bind ("duration", duration_scale.adjustment, "value", SettingsBindFlags.DEFAULT);
        settings.bind ("width", window_width_scale.adjustment, "value", SettingsBindFlags.DEFAULT);
        settings.bind ("height", window_height_scale.adjustment, "value", SettingsBindFlags.DEFAULT);
    }

    private void add_album_folder_field () {
        var folder_label = new Label (_("Album Folder: ")) {
            xalign = 1.0f,
            width_request = 150,
            hexpand = false
        };
        album_picker = new AlbumPicker.from_icon_name ("folder-open");
        string pictures_dir = Path.build_filename (Environment.get_home_dir (), "Pictures");

        file_dialog = new FileDialog () {
            initial_folder = File.new_for_path (pictures_dir),
            modal = true
        };

        var album_folder_box = new Box (Orientation.HORIZONTAL, 10);
        album_folder_box.append (folder_label);
        album_folder_box.append (album_picker);
        append (album_folder_box);
    }

    private void add_recursive_field () {
        var label = new Label (_("Recursive: ")) {
            xalign = 1.0f,
            width_request = 150
        };
        recursive_switch = new Switch () {
            active = false,
            hexpand = false
        };

        var box = new Box (Orientation.HORIZONTAL, 10) {
            baseline_position = BaselinePosition.CENTER,
        };
        box.add_css_class ("recursive-box");
        box.append (label);

        var control_box = new Box (Orientation.HORIZONTAL, 10);
        var desc_label = new Label (_("Will include images from sub-directories if enabled."));
        desc_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);
        control_box.append (recursive_switch);
        control_box.append (desc_label);

        box.append (control_box);

        append (box);
    }

    private void add_duration_field () {
        var duration_label = new Label (_("Duration: ")) {
            xalign = 1.0f,
            yalign = 0.7f,
            width_request = 150
        };

        duration_scale = new Scale.with_range (Orientation.HORIZONTAL, 3, 60, 1) {
            digits = 0,
            draw_value = true,
            hexpand = true,
        };
        duration_scale.adjustment.value = 7;

        var duration_box = new Box (Orientation.HORIZONTAL, 10) {
            baseline_position = BaselinePosition.CENTER
        };
        duration_box.append (duration_label);
        duration_box.append (duration_scale);

        append (duration_box);
    }

    private void add_startup_field () {
        var label = new Label (_("Startup: ")) {
            xalign = 1.0f,
            yalign = 0.7f,
            width_request = 150
        };

        var label_text = new Label (_("Auto start <b>Larawan</b> by adding it ")) {
            use_markup = true
        };
        startup_linkbutton = new LinkButton.with_label (
            "settings://applications/startup",
            _("here.")
        );
        var value_box = new Box (Orientation.HORIZONTAL, 0);
        value_box.append (label_text);
        value_box.append (startup_linkbutton);

        var box = new Box (Orientation.HORIZONTAL, 10);
        box.add_css_class ("form-field");
        box.append (label);
        box.append (value_box);
        append (box);
    }

    private void add_width_field () {
        var window_width_label = new Label (_("Width: ")) {
            xalign = 1.0f,
            yalign = 0.7f,
            width_request = 150
        };

        window_width_scale = new Scale.with_range (
            Orientation.HORIZONTAL,
            MIN_WINDOW_WIDTH,
            MAX_WINDOW_WIDTH,
            1
                             ) {
            digits = 0,
            draw_value = true,
            hexpand = true,
        };

        var box = new Box (Orientation.HORIZONTAL, 10);
        box.add_css_class ("form-field");
        box.append (window_width_label);
        box.append (window_width_scale);
        append (box);
    }

    private void add_height_field () {
        var window_height_label = new Label (_("Height: ")) {
            xalign = 1.0f,
            yalign = 0.7f,
            width_request = 150
        };

        window_height_scale = new Scale.with_range (
            Orientation.HORIZONTAL,
            MIN_WINDOW_HEIGHT,
            MAX_WINDOW_HEIGHT,
            1
                              ) {
            digits = 0,
            draw_value = true,
            hexpand = true,
        };

        var box = new Box (Orientation.HORIZONTAL, 10);
        box.add_css_class ("form-field");
        box.append (window_height_label);
        box.append (window_height_scale);
        append (box);
    }

    private void add_always_visible_field () {
        var label = new Label (_("Always Visible: ")) {
            xalign = 1.0f,
            yalign = 0.7f,
            width_request = 150
        };

        var always_visible_label = new Label (_("Right click app > Click <b>Always on Top</b>")) {
            use_markup = true
        };

        var box = new Box (Orientation.HORIZONTAL, 10);
        box.add_css_class ("form-field");
        box.append (label);
        box.append (always_visible_label);
        append (box);
    }
}