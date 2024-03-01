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

    construct {
        Intl.setlocale (LocaleCategory.ALL, "");
        GLib.Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        GLib.Intl.textdomain (GETTEXT_PACKAGE);
    }

    public static int main (string[] args) {
        Granite.init ();
        var app = new Larawan.App ();
        return app.run (args);
    }

    public override void startup () {
        base.startup ();
        // Granite.init ();
    }

    protected override void activate () {
        // Call the parent class's activate method
        base.activate ();

        apply_granite_theme ();

        // Create a new window
        info ("Starting Larawan...");
        var main_window = new MainWindow (this);

        main_window.present ();
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