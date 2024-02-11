/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
 using Gtk;
 
 public class MyApp : Gtk.Application {
    public MyApp () {
        Object (
            application_id: "com.github.xchan.larawan",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var label = new Gtk.Label ("Hello Again World!");
   
        var main_window = new Gtk.ApplicationWindow (this) {
            child = label,
            default_height = 300,
            default_width = 300,
            title = "Hello World"
        };
        main_window.present ();
    }

    public static int main (string[] args) {
        return new MyApp ().run (args);
    }
}