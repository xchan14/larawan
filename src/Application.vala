/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
using Gtk;
using Gdk;
using GLib;
using Larawan.Views;
using Larawan.Constants;

public class Larawan.App : Gtk.Application {
    public App () {
        Object (
            application_id: APP_ID,
            flags : ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        // Call the parent class's activate method
        base.activate ();

        Granite.init ();
        apply_granite_theme ();

        // Create a new window
        info ("Starting Larawan...");
        var main_window = new MainWindow (this);

        var css_provider = new CssProvider ();
        css_provider.load_from_resource ("io/github/xchan14/larawan/application.css");

        StyleContext.add_provider_for_display (
            Display.get_default (),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        main_window.present ();
    }

    public static int main (string[] args) {
        var app = new Larawan.App ();
        return app.run (args);
    }

    private void apply_granite_theme () {
        // First we get the default instances for Granite.Settings and Gtk.Settings
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        // Then, we check if the user's preference is for the dark style and set it if it is
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        // Finally, we listen to changes in Granite.Settings and update our app if the user changes their preference
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
    }
}