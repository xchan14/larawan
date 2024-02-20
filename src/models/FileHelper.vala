/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Your Name <chancamilon@proton.me>
 */
using Gee;
using GLib;

namespace Larawan.Models {

    public class FileHelper {

        public static async string[] get_files_async (string path, bool recursive = false) {
            var files = new ArrayList<string>();

            // If selected folder can't be opened,
            // Reset to Home's pictures folder of user.
            try {
                info ("Opening directory %s", path);
                var directory = Dir.open (path);

                string filename;
                while ((filename = directory.read_name ()) != null) {
                    string full_path = path + "/" + filename;
                    bool is_dir = yield is_directory (full_path);

                    if (is_dir && recursive) {
                        var subdir_files = yield get_files_async (full_path);

                        foreach (var file in subdir_files) {
                            files.add (file);
                        }
                    } else {
                        files.add (full_path);
                    }
                }
                return files.to_array ();
            } catch (FileError e) {
                info ("Error opening directory of %s.", path);
                info ("%s: %s", e.domain.to_string (), e.message);
                return files.to_array ();
            }
        }

        public static async bool is_directory (string path) {
            try {
                var file = File.new_for_path (path);
                FileInfo file_info = yield file.query_info_async ("standard::type", FileQueryInfoFlags.NONE, Priority.DEFAULT);

                FileType file_type = file_info.get_file_type ();
                return file_type == FileType.DIRECTORY;
            } catch (Error e) {
                error (e.message);
            }
        }
    }
}