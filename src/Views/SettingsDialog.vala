/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
using Gtk;
using Granite;
using Larawan.Constants;

public class Larawan.Views.SettingsDialog : Granite.Dialog {

  Label album_folder_label = null;

  public ApplicationWindow window { get; construct set; }
  public string album_folder { get; set; }

  public SettingsDialog(ApplicationWindow window) {
    Object(window: window);
  }

  construct {
    transient_for = window;
    var box = new Box(Orientation.VERTICAL, 10);
    var header = new Granite.HeaderLabel ("Settings");
    box.append(header);

    var folder_box = new Box (Orientation.HORIZONTAL, 5);
    var folder_label = new Label("Album Folder: ");
    var folder_select_button = new Button.with_label("📁");
    var settings = new GLib.Settings(APP_ID);
    album_folder_label = new Label ("");

    settings.bind (
      "album-folder",
      album_folder_label,
      "label", 
      SettingsBindFlags.DEFAULT);

    var file_dialog = new FileDialog() {
      //  initial_folder = File.new_for_path (album_path)
    };
    folder_select_button.clicked.connect(() => {
      file_dialog.select_folder.begin (window, null, (obj, result) => {
        try {
          File file = file_dialog.select_folder.end (result);
          album_folder_label.label = file.get_path ();
        } catch(Error e) {
          stdout.printf (e.message);
        }
      });
    });

    folder_box.append(folder_label);
    folder_box.append(folder_select_button);
    
    var folder_label_box = new Box(Orientation.HORIZONTAL, 0);
    folder_label_box.append (album_folder_label);

    box.append(folder_box);
    box.append (folder_label_box);

    add_button ("Close", Gtk.ResponseType.CANCEL);

    get_content_area().append(box);

    response.connect((response_id) => {
      if(response_id == Gtk.ResponseType.CANCEL) {
        destroy();
      }
    });
  }

}