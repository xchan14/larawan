/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
 using Gtk;
 using Gdk;
 
 public class MyApp : Gtk.Application {
    public MyApp () {
        Object (
            application_id: "io.github.xchan14.larawan",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        // Call the parent class's activate method
        base.activate();

        // Load an image from file
        var pixbuf = new Pixbuf.from_file("/home/xchan/Downloads/sunset.jpg");

        // Create an image widget
        var image = new Gtk.Image.from_pixbuf(pixbuf);

        // Create a new window
        var main_window = new Gtk.ApplicationWindow (this) {
            child = image,
            default_height = 300,
            default_width = 300,
            title = "Hello World test!"
        };
        main_window.present ();
    }

    public static int main (string[] args) {
        return new MyApp ().run (args);
    }
}