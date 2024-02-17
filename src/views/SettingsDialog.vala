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
    Adjustment adjustment = null;

    public ApplicationWindow window { get; construct set; }

    public SettingsDialog (ApplicationWindow window) {
        Object (window: window);
    }

    construct {
        transient_for = window;
        set_size_request (500, 0);
        add_css_class ("settings-dialog");
        resizable = false;

        var settings = new GLib.Settings (APP_ID);
        var box = new Box (Orientation.VERTICAL, 10);

        // Album folder
        var folder_label = new Label ("Album Folder") {
            xalign = 0.0f
        };
        folder_label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

        album_folder = new EntryButton.from_icon_name ("folder-open");
        album_folder.readonly = true;
        album_folder.hexpand = true;

        settings.bind (
            "album-folder",
            album_folder,
            "text",
            SettingsBindFlags.DEFAULT);

        var file_dialog = new FileDialog () {
            initial_folder = File.new_for_path (album_folder.text)
        };
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

        box.append (folder_label);
        box.append (album_folder);

        // Duration
        var duration_label = new Label ("Duration") {
            xalign = 0.0f
        };
        duration_label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

        var duration_scale = new Scale.with_range (Orientation.HORIZONTAL, 2, 60, 1) {
            digits = 0,
            draw_value = true,
            hexpand = true,
        };
        adjustment = duration_scale.adjustment;

        settings.bind (
            "duration",
            adjustment,
            "value",
            SettingsBindFlags.DEFAULT);

        var duration_box = new Box (Orientation.VERTICAL, 0);
        duration_box.append (duration_label);
        duration_box.append (duration_scale);

        box.append (duration_box);

        // Width
        var window_width_label = new Label ("Window Width") {
            xalign = 0.0f
        };
        window_width_label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

        var window_width_scale = new Scale.with_range (Orientation.HORIZONTAL, 300, 800, 1) {
            digits = 0,
            draw_value = true,
            hexpand = true,
        };
        adjustment = window_width_scale.adjustment;

        settings.bind (
            "width",
            adjustment,
            "value",
            SettingsBindFlags.DEFAULT);

        var window_width_box = new Box (Orientation.VERTICAL, 0);
        window_width_box.append (window_width_label);
        window_width_box.append (window_width_scale);
        box.append (window_width_box);

        // Height
        var window_height_label = new Label ("Window Height") {
            xalign = 0.0f
        };
        window_height_label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

        var window_height_scale = new Scale.with_range (Orientation.HORIZONTAL, 300, 800, 1) {
            digits = 0,
            draw_value = true,
            hexpand = true,
        };
        adjustment = window_height_scale.adjustment;

        settings.bind (
            "height",
            adjustment,
            "value",
            SettingsBindFlags.DEFAULT);

        var window_height_box = new Box (Orientation.VERTICAL, 0);
        window_height_box.append (window_height_label);
        window_height_box.append (window_height_scale);
        box.append (window_height_box);

        add_button ("Close", Gtk.ResponseType.CANCEL);

        get_content_area ().append (box);

        response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.CANCEL) {
                destroy ();
            }
        });
    }
}