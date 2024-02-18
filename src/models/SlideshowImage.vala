/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
using Gtk;
using Gdk;

namespace Larawan.Models {

    public class SlideshowImage : Object {
        uint unload_timeout_id;

        public static SlideshowImage ? from_file (int id, string filepath) {
            if (!SlideshowImage.is_image_file (filepath)) {
                return null;
            }
            return new SlideshowImage (id, filepath);
        }

        public static bool is_image_file (string file_path) {
            // Get the file extension
            string extension = get_extension (file_path);

            // List of common image file extensions
            string[] image_extensions = { "png", "jpg", "jpeg", "gif", "bmp" };

            // Check if the file extension is in the list of image extensions
            return extension in image_extensions;
        }

        public static string get_extension (string path) {
            int index = path.last_index_of_char ('.');
            return path.substring (index + 1);
        }

        public int id { get; construct set; }

        public string filepath { get; construct set; }

        public string filename {
            owned get {
                return Path.get_basename (filepath);
            }
        }

        public Picture picture { get; construct set; }

        public SlideshowImage (int id, string filepath) {
            Object (
                id: id,
                filepath: filepath
            );
        }

        construct {
            picture = create_picture ();
        }

        private Picture create_picture () {
            var picture = new Picture () {
                can_shrink = true,
                content_fit = ContentFit.COVER,
            };
            picture.add_css_class ("current-image");
            return picture;
        }

        public void unload_picture () {
            unload_timeout_id = Timeout.add_seconds (2000, () => {
                Paintable paintable = picture.paintable;
                paintable.dispose ();
                return Source.remove (unload_timeout_id);
            }, Priority.HIGH);
        }

        public void load_picture (int width, int height) {
            info ("Loading picture...");
            int file_width;
            int file_height;

            try {
                Pixbuf.get_file_info (
                    filepath,
                    out file_width,
                    out file_height);

                int new_width = width;
                int new_height = (int) (file_height * new_width / file_width);

                debug ("New size %ix%i", new_width, new_height);

                // Load an image file
                Pixbuf pixbuf = new Pixbuf.from_file (filepath);
                pixbuf = pixbuf.scale_simple (
                    new_width,
                    new_height,
                    InterpType.BILINEAR);

                debug ("actual size %ix%i", pixbuf.width, pixbuf.height);

                picture.set_paintable (Texture.for_pixbuf (pixbuf));
                info ("Picture of %s loaded!", filename);
            } catch (Error e) {
                info ("Unable to load file: %s", filepath);
                info ("Error: %s", e.message);
            }
        }
    }
}