/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Christian Camilon <chancamilon@proton.me>
 */
using Gtk;

namespace Larawan.Widgets {

    public class AlbumPicker : Gtk.Box {
        Button value_text;
        Button button;
        string _value;

        public signal void clicked ();

        public string text {
            get {
                return this.value_text.label;
            }
            protected set {
                this.value_text.label = value;
            }
        }

        public string value {
            get {
                return this._value;
            }
            set {
                this._value = value;
            }
        }

        public string icon_name { get; construct set; }

        public AlbumPicker.from_icon_name (string icon_name) {
            Object (icon_name: icon_name);
        }

        construct {
            orientation = Orientation.HORIZONTAL;

            value_text = new Button () {
                hexpand = true
            };
            value_text.add_css_class ("album-picker-text");

            button = new Button.from_icon_name (icon_name);
            if (button.get_icon_name () != null) {
                button.remove_css_class ("image-button");
            }
            button.add_css_class ("album-picker-btn");

            append (value_text);
            append (button);

            value_text.clicked.connect(() => clicked());
            button.clicked.connect (() => clicked ());

            notify["value"].connect(on_value_changed);
        }

        private void on_value_changed() {
            update_text();
        }

        private void update_text() {
            this.text = Path.get_basename(value);
        }
    }
}