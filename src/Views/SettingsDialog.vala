/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
using Gtk;
using Granite;

public class Larawan.Views.SettingsDialog : Granite.Dialog {
  public ApplicationWindow window { get; construct set; }

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
    var folder_select_button = new Button.with_label("Choose Album");
    var settings = new GLib.Settings(Constants.APP_ID);
    var file_dialog = new FileDialog();
    settings.bind("album-folder", file_dialog, "active", SettingsBindFlags.DEFAULT);
    folder_select_button.clicked.connect(() => {
      file_dialog.select_folder(window, null);
    });
    folder_box.append(folder_label);
    folder_box.append(folder_select_button);

    box.append(folder_box);

    var save_button = add_button ("Save", Gtk.ResponseType.ACCEPT);
    save_button.add_css_class(Granite.STYLE_CLASS_SUGGESTED_ACTION);

    add_button ("Cancel", Gtk.ResponseType.CANCEL);

    get_content_area().append(box);

    response.connect((response_id) => {
      if(response_id == Gtk.ResponseType.CANCEL) {
        destroy();
      }
    });
  }

}