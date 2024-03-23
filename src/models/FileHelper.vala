/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Christian Camilon <chancamilon@proton.me>
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

                    if (!FileUtils.test (full_path, FileTest.EXISTS)) {
                        info ("%s does not exist.", full_path);
                        continue;
                    }

                    if (FileUtils.test (full_path, FileTest.IS_DIR) && recursive) {
                        string[] subdir_files = yield get_files_async (full_path, recursive);

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
    }
}