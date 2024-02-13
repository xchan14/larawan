/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
 using Gtk;
 using GLib;
 using Larawan.Views;
 
 public class Larawan.Application : Gtk.Application {
  public Application () {
    Object (
        application_id: "io.github.xchan14.larawan",
        flags: ApplicationFlags.FLAGS_NONE
    );
  }

  protected override void activate () {
    // Call the parent class's activate method
    base.activate();

    // Create a new window
    info("Starting Larawan...");
    var main_window = new MainWindow(this);
    main_window.present ();
  }

  public static int main (string[] args) {
    var app = new Larawan.Application ();
    return app.run (args);
  }
    
}