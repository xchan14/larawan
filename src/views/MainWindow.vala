/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
using Gtk;
using Gdk;
using Gee;
using GLib;
using Larawan.Constants;
using Larawan.Models;

public class Larawan.Views.MainWindow : Adw.ApplicationWindow {

    ArrayList<SlideshowImage> images_to_show;
    ArrayQueue<SlideshowImage> shown_images;
    SlideshowImage current_image;
    int picture_duration = 1;
    uint picture_timeout_id = -1;
    int window_width;
    int window_height;

    Stack picture_stack;
    SettingsDialog settings_dialog;
    GLib.Settings settings;
    WindowHandle window_handle;
    ScrolledWindow scrolled_window;
    Button settings_button;
    Box main_content;

    public MainWindow (Larawan.Application larawan) {
        Object (application: larawan);
    }

    construct {
        resizable = false;
        settings = new GLib.Settings (APP_ID);
        picture_duration = settings.get_int ("duration");
        window_width = settings.get_int ("width");
        window_height = settings.get_int ("height");
        info ("Window size: %ix%i", window_width, window_height);

        picture_stack = new Stack () {
            transition_type = StackTransitionType.SLIDE_LEFT_RIGHT,
            transition_duration = 750,
            vexpand = true,
        };

        main_content = new Box (Orientation.VERTICAL, 0);
        main_content.append (picture_stack);

        scrolled_window = new ScrolledWindow () {
            child = main_content,
            propagate_natural_width = false,
            has_frame = false,
            max_content_width = window_width,
            vscrollbar_policy = PolicyType.NEVER
        };
        var viewport = (Viewport) scrolled_window.child;
        viewport.vscroll_policy = ScrollablePolicy.MINIMUM;
        viewport.width_request = window_width;

        window_handle = new WindowHandle () {
            child = scrolled_window,
        };
        // window_handle.set_size_request (window_width, window_height);

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

        resize_window ();

        settings.changed.connect (on_settings_changed);
        map.connect (on_map);
    }

    private void on_map () {
        load_image_files ();
        start_slideshow ();
    }

    private void on_settings_changed (string key) {
        if (key == "album-folder") {
            load_image_files ();
            start_slideshow ();
        }

        if (key == "duration") {
            reset_duration ();
        }

        if (key == "width" || key == "height") {
            resize_window ();
        }

        if (key == "shuffle") {
            reset_slides ();
        }
    }

    private void on_settings_button_clicked () {
        settings_dialog = new SettingsDialog (this);
        settings_dialog.show ();
    }

    private void start_slideshow () {
        info ("Playing slideshow...");
        show_next ();
        play ();
    }

    private void stop_slideshow () {
        if (picture_timeout_id > 0) {
            Source.remove (picture_timeout_id);
        }
    }

    private void reset_slides () {
        info ("Resetting slide show.");
        images_to_show.add_all (shown_images);
        sort_images ();
        shown_images.clear ();
    }

    private void reset_duration () {
        stop ();
        picture_duration = settings.get_int ("duration");
        play ();
    }

    private void sort_images () {
        images_to_show.order_by ((image1, image2) => image1.filename >= image2.filename ? 1 : -1);
    }

    private void load_image_files () {
        string album_path = settings.get_string ("album-folder");
        info ("Loading album.");

        stop_slideshow ();

        Dir directory = null;

        // If selected folder can't be opened,
        // Reset to Home's pictures folder of user.
        try {
            info ("Opening album directory.");
            directory = Dir.open (album_path);
        } catch (FileError e) {
            album_path = Environment.get_home_dir () + "/Pictures";
            settings.set_string ("album-folder", album_path);
        }

        info ("Removing current album pictures in picture stack.");

        // Reset slideshow image items
        images_to_show = new ArrayList<SlideshowImage>();
        shown_images = new ArrayQueue<SlideshowImage>();

        // Read filenames from the directory
        string filename;
        while ((filename = directory.read_name ()) != null) {
            string full_path = album_path + "/" + filename;

            var slideshow_image = SlideshowImage.from_file (full_path);
            if (slideshow_image == null) {
                continue;
            }

            // Add file to show in list of images
            // if found to be an image file.
            images_to_show.add (slideshow_image);
            picture_stack.add_named (slideshow_image.picture, filename);
            info ("Added %s in pic stack", slideshow_image.filename);
        }

        sort_images ();

        info ("Done creating picture stack");
    }

    private void show_next () {
        info ("Showing next picture.");

        debug ("Adding current image to shown_images list.");
        if (current_image != null) {
            shown_images.offer (current_image);
            current_image.unload_picture ();
        }

        bool shuffle = settings.get_boolean ("shuffle");

        current_image = shuffle
            ? get_next_random_image ()
            : images_to_show.remove_at (0);
        debug ("Current image: %s", current_image.filename);

        reload_image ();
        picture_stack.set_visible_child_name (current_image.filename);

        info ("Current picture set.");
    }

    private SlideshowImage get_next_random_image () {
        var rand = new Rand ();
        int index = rand.int_range (0, images_to_show.size);
        return images_to_show.remove_at (index);
    }

    void resize_window () {
        width_request = settings.get_int ("width");
        height_request = settings.get_int ("height");
        reload_image ();
    }

    void reload_image () {
        current_image.load_picture (width_request, height_request);
    }

    private void play () {
        picture_timeout_id = Timeout.add_seconds (picture_duration, () => {
            info ("Pic duration: %i", picture_duration);
            show_next ();
            if (images_to_show.size == 0) {
                reset_slides ();
            }
            return true;
        }, Priority.DEFAULT);
    }

    private void stop () {
        if (picture_timeout_id > 0) {
            Source.remove (picture_timeout_id);
            picture_timeout_id = -1;
            info ("Interval reset!");
        }
    }
}