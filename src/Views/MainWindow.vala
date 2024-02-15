/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
using Gtk;
using Gdk;
using GLib;
using Larawan.Constants;

public class Larawan.Views.MainWindow : Adw.ApplicationWindow {

  Stack picture_stack;
  int stack_position = 0;
  Array<string> filenames;
  SettingsDialog settings_dialog;
  GLib.Settings settings;
  WindowHandle window_handle;

  public MainWindow(Larawan.Application larawan){
      Object(application: larawan);
  }

  construct {
    resizable = false;
    settings = new GLib.Settings(APP_ID);
    string album_path = settings.get_string("album-folder");

    load_album (album_path);

    window_handle = new WindowHandle () {
      child = picture_stack,
      hexpand = true,
      vexpand = true,
    };

    var settings_button = new Button.with_label("⚙️") {
      halign = Align.END,
      valign = Align.END,
      can_focus = false
    };
    settings_button.add_css_class("settings-button");
    settings_button.clicked.connect(() => {
      settings_dialog = new SettingsDialog(this);
      settings_dialog.show();
    });

    var overlay = new Overlay() {
      child = window_handle,
      can_target = true,
    };
    overlay.add_overlay(settings_button);

    content = overlay;
    //  child = overlay;

    show_next_pic ();

    //  settings.changed.connect((key) => {
    //    if(key == "album-folder") {
    //      var new_album_path = settings.get_string("album-folder");
    //      load_album(new_album_path);
    //    }
    //  });

    Timeout.add_seconds (7, () => {
      show_next_pic ();
      return true;
    }, Priority.DEFAULT);

  }

  private void load_album(string path) {
    Dir directory = null;

    // Create a new Dir object for the directory
    string album_path = path;
    filenames = new Array<string>();

    // If selected folder can't be opened,
    // Reset to Home's pictures folder of user.
    try {
      directory = Dir.open(album_path);
    } catch (FileError e) {
      album_path = Environment.get_home_dir() + "/Pictures";
      settings.set_string("album-folder", album_path);
    }

    // Remove existing picture stack contents
    while(picture_stack?.get_visible_child() != null) {
      var child = picture_stack.get_visible_child();
      picture_stack.remove(child);
      child.destroy();
    }
    picture_stack.destroy();

    // Create new picture stack
    picture_stack = new Stack () {
      transition_type = StackTransitionType.CROSSFADE,
      transition_duration = 1500,
    };

    // Read filenames from the directory
    filenames = new Array<string> ();
    string filename;
    while ((filename = directory.read_name()) != null) {
      // Print each filename
      string full_path = album_path + "/" + filename;
      if(!is_image_file(full_path)) {
        continue;
      }

      // Set the desired width and height for the picture
      int width = 360;
      int height = 240;

      Pixbuf pixbuf = null;
      try{
        // Load an image file
        pixbuf = new Pixbuf.from_file(full_path);
      } catch(Error e) {
        info("Unable to load file: %s", full_path);
        info("Error: %s", e.message);
        continue;
      }

      // Resize the image
      pixbuf = pixbuf.scale_simple(width, height, InterpType.BILINEAR);

      var image_texture = Texture.for_pixbuf(pixbuf);

      var picture = new Picture() {
        //  can_shrink = true,
        hexpand = true,
        vexpand = true,
        content_fit = ContentFit.COVER,
      };
      picture.add_css_class("image");
      picture.set_paintable(image_texture);
      picture_stack.add_named (picture, filename);
      filenames.append_val(filename);
    }
  }

  private void show_next_pic() {
    string filename = filenames.index(stack_position);
    picture_stack.visible_child = picture_stack.get_child_by_name(filename);

    if(stack_position == (filenames.length - 1)) {
      stack_position = 0; // reset
    } else {
      stack_position++;
    }
  }

  bool is_image_file(string file_path) {
    // Get the file extension
    string extension = get_extension(file_path);

    // List of common image file extensions
    string[] image_extensions = {"png", "jpg", "jpeg", "gif", "bmp"};

    // Check if the file extension is in the list of image extensions
    return extension in image_extensions;
  }

  string get_extension(string path) { 
    int index = path.last_index_of_char('.');
    return path.substring(index + 1);
  }

}