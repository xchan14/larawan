/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
using Gtk;
using Granite;
using Larawan.Constants;
using Larawan.Widgets;

public class Larawan.Views.SettingsDialog : Granite.Dialog {

    EntryButton album_folder = null;
    Switch shuffle_switch = null;
    GLib.Settings settings;
    FileDialog file_dialog;
    Scale duration_scale;
    Switch recursive_switch;
    Scale window_width_scale;
    Scale window_height_scale;
    Box root_box;

    public ApplicationWindow window { get; construct set; }

    public SettingsDialog (ApplicationWindow window) {
        Object (window: window);
    }

    construct {
        transient_for = window;
        set_size_request (700, 0);
        add_css_class ("settings-dialog");
        resizable = false;
        root_box = new Box (Orientation.VERTICAL, 10);

        var slideshow_label = new Label ("Slideshow") {
            xalign = 0.0f
        };
        slideshow_label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);
        root_box.append (slideshow_label);
        add_album_folder_field ();
        add_recursive_field ();
        add_duration_field ();

        var window_label = new Label ("Window") {
            xalign = 0.0f
        };
        window_label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);
        window_label.add_css_class ("window-legend-label");

        root_box.append (window_label);
        add_width_field ();
        add_height_field ();

        add_button ("Close", Gtk.ResponseType.CANCEL);
        get_content_area ().append (root_box);
        bind_settings ();
        bind_events ();
    }

    private void bind_events () {
        album_folder.clicked.connect (() => {
            file_dialog.select_folder.begin (window, null, (obj, result) => {
                try {
                    File file = file_dialog.select_folder.end (result);
                    album_folder.text = file.get_path ();
                } catch (Error e) {
                    info (e.message);
                }
            });
        });

        response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.CANCEL) {
                hide ();
            }
        });
    }

    private void bind_settings () {
        settings = new GLib.Settings (APP_ID);
        settings.bind ("album-folder", album_folder, "text", SettingsBindFlags.DEFAULT);
        settings.bind ("shuffle", shuffle_switch, "active", SettingsBindFlags.DEFAULT);
        settings.bind ("recursive", recursive_switch, "active", SettingsBindFlags.DEFAULT);
        settings.bind ("duration", duration_scale.adjustment, "value", SettingsBindFlags.DEFAULT);
        settings.bind ("width", window_width_scale.adjustment, "value", SettingsBindFlags.DEFAULT);
        settings.bind ("height", window_height_scale.adjustment, "value", SettingsBindFlags.DEFAULT);
    }

    private void add_album_folder_field () {
        var folder_label = new Label ("Album Folder: ") {
            xalign = 1.0f,
            width_request = 150,
            hexpand = false
        };
        album_folder = new EntryButton.from_icon_name ("folder-open");
        album_folder.readonly = true;
        album_folder.hexpand = true;
        string pictures_dir = Path.build_filename (Environment.get_home_dir (), "Pictures");

        file_dialog = new FileDialog () {
            initial_folder = File.new_for_path (pictures_dir)
        };

        var album_folder_box = new Box (Orientation.HORIZONTAL, 10);
        album_folder_box.append (folder_label);
        album_folder_box.append (album_folder);
        root_box.append (album_folder_box);
    }

    private void add_recursive_field () {
        var label = new Label ("Recursive: ") {
            xalign = 1.0f,
            yalign = 0.7f,
            width_request = 150
        };
        recursive_switch = new Switch () {
            active = false
        };

        var box = new Box (Orientation.HORIZONTAL, 10) {
            baseline_position = BaselinePosition.CENTER,
        };
        box.add_css_class ("recursive-box");
        box.append (label);
        box.append (recursive_switch);

        root_box.append (box);
    }

    private void add_duration_field () {
        var duration_label = new Label ("Duration: ") {
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

        root_box.append (duration_box);
    }

    private void add_width_field () {
        var window_width_label = new Label ("Width: ") {
            xalign = 1.0f,
            yalign = 0.7f,
            width_request = 150
        };

        window_width_scale = new Scale.with_range (Orientation.HORIZONTAL, 300, 800, 1) {
            digits = 0,
            draw_value = true,
            hexpand = true,
        };

        var window_width_box = new Box (Orientation.HORIZONTAL, 10);
        window_width_box.append (window_width_label);
        window_width_box.append (window_width_scale);
        root_box.append (window_width_box);
    }

    private void add_height_field () {
        var window_height_label = new Label ("Height: ") {
            xalign = 1.0f,
            yalign = 0.7f,
            width_request = 150
        };

        window_height_scale = new Scale.with_range (Orientation.HORIZONTAL, 300, 800, 1) {
            digits = 0,
            draw_value = true,
            hexpand = true,
        };

        var window_height_box = new Box (Orientation.HORIZONTAL, 10);
        window_height_box.append (window_height_label);
        window_height_box.append (window_height_scale);
        root_box.append (window_height_box);
    }
}