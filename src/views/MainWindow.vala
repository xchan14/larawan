/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
using Gtk;
using Gdk;
using Gee;
using GLib;
using Granite;
using Larawan.Constants;
using Larawan.Models;

public class Larawan.Views.MainWindow : Adw.ApplicationWindow {

    SlideshowPlaylist slideshow_playlist;
    uint resize_timeout_id = 0;

    Stack picture_stack;
    SettingsDialog settings_dialog;
    GLib.Settings settings;
    WindowHandle window_handle;
    ScrolledWindow scrolled_window;
    Button settings_button;
    Stack main_content;
    Placeholder empty_dir_placeholder;
    Button empty_dir_placeholder_button;

    public MainWindow (Larawan.App larawan) {
        Object (application: larawan);
    }

    construct {
        resizable = false;
        slideshow_playlist = new SlideshowPlaylist ();
        settings = new GLib.Settings (APP_ID);
        set_size_request (settings.get_int ("width"), settings.get_int ("height"));

        picture_stack = new Stack () {
            transition_type = StackTransitionType.SLIDE_LEFT_RIGHT,
            transition_duration = 750,
            vexpand = true,
        };

        empty_dir_placeholder = new Placeholder ("So Empty!") {
            description = "Display album of your choice like your special someone or pets for example.",
            hexpand = true
        };
        empty_dir_placeholder_button = empty_dir_placeholder.append_button (
            new ThemedIcon ("folder-open"),
            "Select Album",
            "Adds picture from selected album folder and subdirectory."
        );

        var loading_album = new Label ("Loading Album...");
        loading_album.add_css_class (Granite.STYLE_CLASS_H1_LABEL);

        main_content = new Stack ();
        main_content.add_named (picture_stack, "picture_stack");
        main_content.add_named (empty_dir_placeholder, "empty_dir");
        main_content.add_named (loading_album, "loading");

        scrolled_window = new ScrolledWindow () {
            child = main_content,
            propagate_natural_width = false,
            has_frame = false,
            vscrollbar_policy = PolicyType.NEVER,
            hscrollbar_policy = PolicyType.NEVER,
        };
        var viewport = (Viewport) scrolled_window.child;
        viewport.vscroll_policy = ScrollablePolicy.MINIMUM;
        viewport.hscroll_policy = ScrollablePolicy.MINIMUM;

        window_handle = new WindowHandle () {
            child = scrolled_window,
        };

        settings_button = new Button.with_label ("⚙️") {
            halign = Align.END,
            valign = Align.END,
            can_focus = false
        };
        settings_button.add_css_class ("settings-button");
        settings_button.clicked.connect (on_settings_button_clicked);

        var overlay = new Overlay () {
            child = window_handle,
            can_target = true,
            overflow = Overflow.HIDDEN
        };
        overlay.add_overlay (settings_button);

        content = overlay;
        bind_events ();
    }

    private void bind_events () {
        settings.changed.connect (on_settings_changed);
        map.connect (on_map);
        empty_dir_placeholder_button.clicked.connect (on_empty_dir_placeholder_button_clicked);
        slideshow_playlist.current_changed.connect (on_playlist_current_changed);
    }

    private void on_map () {
        init_playlist.begin ((obj, res) => init_playlist.end (res));
    }

    private void on_settings_changed (string key) {
        if (key == "album-folder" || key == "recursive") {
            slideshow_playlist.stop ();
            init_playlist.begin ((obj, res) => init_playlist.end (res));
        }

        if (key == "duration") {
            slideshow_playlist.reset_display_duration (settings.get_int ("duration"));
        }

        if (key == "width" || key == "height") {
            resize_window ();
        }
    }

    private void on_settings_button_clicked () {
        if (settings_dialog == null) {
            settings_dialog = new SettingsDialog (this);
        }
        settings_dialog.show ();
    }

    private void on_empty_dir_placeholder_button_clicked () {
        var initial_folder = File.new_for_path (settings.get_string ("album-folder"));
        var file_dialog = new FileDialog () {
            initial_folder = initial_folder
        };
        file_dialog.select_folder.begin (this, null, (obj, result) => {
            try {
                File file = file_dialog.select_folder.end (result);
                settings.set_string ("album-folder", file.get_path ());
            } catch (Error e) {
                info (e.message);
            }
        });
    }

    private void on_playlist_current_changed (SlideshowImage image) {
        info ("Showing image %s with %ix%i resolution...", image.filename, width_request, height_request);
        image.load_picture (width_request, height_request);
        picture_stack.set_visible_child_name (image.id.to_string ());
        info ("Image %s shown in stack!", image.filename);
    }

    private async void init_playlist () {
        show_loading ();
        string album_path = settings.get_string ("album-folder");
        int duration = settings.get_int ("duration");
        bool recursive = settings.get_boolean ("recursive");

        info ("Initializing playlist...");
        yield slideshow_playlist.initialize_async (album_path, duration, recursive);

        slideshow_playlist.stop ();
        clear_picture_stack ();

        foreach (var image in slideshow_playlist.image_queue) {
            picture_stack.add_named (image.picture, image.id.to_string ());
            info ("Added picture %s with id %i.", image.filename, image.id);
        }

        if (slideshow_playlist.empty) {
            show_empty_page ();
            info ("Playlist empty.");
        } else {
            show_playlist ();
            slideshow_playlist.play ();
            info ("Playlist initialized.");
        }
    }

    private void show_loading () {
        main_content.set_visible_child_name ("loading");
    }

    private void show_playlist () {
        main_content.set_visible_child_name ("picture_stack");
    }

    private void show_empty_page () {
        info ("Empty directory selected.");
        main_content.set_visible_child_name ("empty_dir");
    }

    private void clear_picture_stack () {
        info ("Clearing picture stack...");
        if (picture_stack != null) {
            foreach (var id in slideshow_playlist.image_ids) {
                var child = picture_stack.get_child_by_name (id);
                if (child != null) {
                    picture_stack.remove (child);
                    child.destroy ();
                }
            }
        }
    }

    void resize_window () {
        width_request = settings.get_int ("width");
        height_request = settings.get_int ("height");

        if (resize_timeout_id == 0) {
            info ("Resizing window...");
            resize_timeout_id = Timeout.add (1000, () => {
                resize_done ();
                return false;
            }, Priority.HIGH);
        }
    }

    void resize_done () {

        reload_image ();
        Source.remove (resize_timeout_id);
        resize_timeout_id = -1;
    }

    void reload_image () {
        info ("Reloading image...");
        slideshow_playlist.current ? .load_picture (width_request, height_request);
    }
}