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

  
  ArrayQueue<SlideshowImage> images_to_show;
  ArrayQueue<SlideshowImage> shown_images;
  SlideshowImage current_image;
  int picture_duration = 1;
  uint picture_timeout_id = -1;
  int window_width = 300;
  int window_height = 300;

  Stack picture_stack;
  SettingsDialog settings_dialog;
  GLib.Settings settings;
  WindowHandle window_handle;
  ScrolledWindow scrolled_window;
  Button settings_button;
  Box main_content;

  public MainWindow(Larawan.Application larawan){
      Object(application: larawan);
  }

  construct {
    resizable = false;
    settings = new GLib.Settings(APP_ID);
    picture_duration = settings.get_int("duration");

    picture_stack = new Stack () {
      transition_type = StackTransitionType.CROSSFADE,
      transition_duration = 1000,
      vexpand = true,
    };

    main_content = new Box(Orientation.VERTICAL, 0);
    main_content.append(picture_stack);

    scrolled_window = new ScrolledWindow() {
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
    window_handle.set_size_request(window_width, window_height);

    settings_button = new Button.with_label("⚙️") {
      halign = Align.END,
      valign = Align.END,
      can_focus = false
    };
    settings_button.add_css_class("settings-button");
    settings_button.clicked.connect(on_settings_button_clicked);

    var overlay = new Overlay() {
      child = window_handle,
      can_target = true,
      overflow = Overflow.HIDDEN
    };
    overlay.add_overlay(settings_button);

    content = overlay;

    resize_window();

    settings.changed.connect(on_settings_changed);
    map.connect(on_map);
    activate_focus.connect(on_activate_focus);
    move_focus.connect(on_move_focus);
  }

  private void on_map() {
    load_album();
    play_slideshow();
    show_next();
  }

  private void on_activate_focus() {
    settings_button.visible = true;
  }

  private void on_move_focus() {
    settings_button.visible = false;
  }

  private void on_settings_changed(string key) {
    if(key == "album-folder") {
      load_album();
    }

    if(key == "duration") { 
      reset_duration();
    }

    if(key == "width" || key == "height") {
      resize_window();
    }
  }

  private void on_settings_button_clicked() {
    settings_dialog = new SettingsDialog(this);
    settings_dialog.show();
  }

  private void play_slideshow() {
    info("Playing slideshow...");
    
    // If images to show isn't greater than 1.
    // no need to create interval.
    if(images_to_show.size <= 1) {
      info("There are only %i images to show.", images_to_show.size);
      return;
    }

    picture_timeout_id = Timeout.add_seconds(picture_duration,() => {
      info("Pic duration: %i", picture_duration);
      show_next();
      return true;
    }, Priority.DEFAULT);
  }

  private void reset_slideshow() {
    info("Resetting slide show.");
    if(images_to_show.peek() == null) {
      images_to_show.add_all(shown_images);
      current_image = null;
      shown_images.clear();
    }
    play_slideshow();
  }

  private void reset_duration() {
    if(picture_timeout_id > 0) {
      Source.remove(picture_timeout_id);
      picture_timeout_id = -1;
      info("Interval reset!");
    }
    picture_duration = settings.get_int("duration");
    play_slideshow();
  }

  private void load_album() {
    string album_path = settings.get_string("album-folder");
    info("Loading album.");

    Dir directory = null;

    // If selected folder can't be opened,
    // Reset to Home's pictures folder of user.
    try {
      info("Opening album directory.");
      directory = Dir.open(album_path);
    } catch (FileError e) {
      album_path = Environment.get_home_dir() + "/Pictures";
      settings.set_string("album-folder", album_path);
    }

    info("Removing current album pictures in picture stack.");
    while(picture_stack?.get_visible_child() != null) {
      Widget child = picture_stack.get_visible_child();
      picture_stack.remove(child);
      child.destroy();
    }

    // Reset slideshow image items
    images_to_show = new ArrayQueue<SlideshowImage>();
    shown_images = new ArrayQueue<SlideshowImage>();

    // Read filenames from the directory
    string filename;
    while ((filename = directory.read_name()) != null) {
      string full_path = album_path + "/" + filename;

      var slideshow_image = SlideshowImage.from_file(full_path);
      if(slideshow_image == null) {
        continue;
      }

      // Add file to show in list of images 
      // if found to be an image file.
      images_to_show.offer(slideshow_image);
      picture_stack.add_named (slideshow_image.picture, filename);
      info("Added %s in pic stack", slideshow_image.filename);
    }

    debug("Appended main_content with picture_stack");
    info("Done creating picture stack");
  }

  private void show_next() {
    info("Showing next picture.");

    debug(" Adding current image to shown_images list.");
    if(current_image != null) {
      shown_images.offer(current_image);
      current_image.unload_picture();
    }

    current_image = images_to_show.poll();
    if(current_image == null) {
      reset_slideshow();
      return;
    }
    debug("Current image: %s", current_image.filename);

    reload_image();
    picture_stack.set_visible_child_name(current_image.filename);
    
    info("Current picture set.");
  }

  void resize_window () {
    width_request = settings.get_int("width");
    height_request = settings.get_int("height");
    reload_image();
  }

  void reload_image() {
    current_image.load_picture(width_request, height_request);
  }

}