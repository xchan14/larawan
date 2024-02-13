/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
using Gtk;
using Gdk;
using GLib;

public class Larawan.Views.MainWindow : Adw.ApplicationWindow {

  const int double_click_time = 150;
  long click1 = 0;  
  long click2 = 0;

  Stack picture_stack;
  int stack_position = 0;
  Array<string> filenames;
  SettingsDialog settings_dialog;

  public MainWindow(Larawan.Application larawan){
      Object(application: larawan);
  }

  construct {
    //  var directory_path = "/home/xchan/pCloud/Photos/Wallpaper/Desktop";
    //  var directory_path = "/home/xchan/pCloud/Photos/Family/Katniss Eve";
    var settings = new GLib.Settings(Constants.APP_ID);
    var directory_path = settings.get_string("album-folder");

    // Create a new Dir object for the directory
    stdout.printf("Directory: %s", directory_path);
    Dir directory = Dir.open(directory_path);
    if (directory == null) {
        stderr.printf("Failed to open directory: %s\n", directory_path);
        return;
    }

    picture_stack = new Stack () {
      transition_type = StackTransitionType.CROSSFADE,
      transition_duration = 1500,
    };

    // Read filenames from the directory
    filenames = new Array<string> ();
    string filename;
    while ((filename = directory.read_name()) != null) {
      // Print each filename
      string full_path = directory_path + "/" + filename;
      if(!is_image_file(full_path)) {
        continue;
      }

      // Set the desired width and height for the picture
      int width = 360;
      int height = 240;

      // Load an image file
      var pixbuf = new Pixbuf.from_file(full_path);
      // Resize the image
      pixbuf = pixbuf.scale_simple(width, height, InterpType.BILINEAR);

      var image_texture = Texture.for_pixbuf(pixbuf);

      var picture = new Picture() {
        can_shrink = true,
        hexpand = true,
        vexpand = true,
        content_fit = ContentFit.COVER,
      };
      picture.set_paintable(image_texture);
      picture_stack.add_named (picture, filename);
      filenames.append_val(filename);
    }

    var window_handle = new WindowHandle () {
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
    //  var gclick = new GestureClick();
    //  gclick.pressed.connect(() => stdout.printf("test..."));
    //  settings_button.add_controller(gclick);

    var overlay = new Overlay() {
      child = window_handle,
      can_target = true,
    };
    overlay.add_overlay(settings_button);

    content = overlay;
    //  child = overlay;

    show_next_pic();

    Timeout.add_seconds(7, () => {
      show_next_pic();
      return true;
    }, Priority.DEFAULT);
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