/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Christian Camilon <chancamilon@proton.me>
 */
using Gtk;

namespace Larawan.Widgets {

    public class EntryButton : Gtk.Box {
        Entry entry;
        Button button;

        public signal void clicked ();

        public string text {
            get {
                return this.entry.text;
            }
            set {
                this.entry.text = value;
            }
        }

        public bool readonly {
            get {
                return !entry.editable;
            }
            set {
                entry.editable = !value;
            }
        }

        public string icon_name { get; construct set; }

        public EntryButton.from_icon_name (string icon_name) {
            Object (icon_name: icon_name);
        }

        construct {
            orientation = Orientation.HORIZONTAL;

            entry = new Entry () {
                hexpand = true
            };
            entry.add_css_class ("entry-button-text");

            button = new Button.from_icon_name (icon_name);
            if (button.get_icon_name () != null) {
                button.remove_css_class ("image-button");
            }
            button.add_css_class ("entry-button-btn");

            append (entry);
            append (button);

            button.clicked.connect (() => clicked ());
        }
    }
}