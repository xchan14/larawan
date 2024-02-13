using Gtk;
using Gdk;
using GLib;

public class Larawan.Views.MainWindow : Adw.ApplicationWindow {

  Stack picture_stack;
  int stack_position = 0;
  Array<string> filenames;

  static construct {
    Adw.init();
  }

  public MainWindow(Larawan.Application larawan){
      Object(application: larawan);
  }

  construct {


    var directory_path = "/home/xchan/pCloud/Photos/Wallpaper/Desktop";

    // Create a new Dir object for the directory
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

      var event_controller = new EventControllerKey();
      event_controller.key_pressed.connect((controller) => {
        stdout.printf("Image clicked...");
      });
      picture.add_controller(event_controller);
    }

    var window_handle = new WindowHandle () {
      child = picture_stack,
      hexpand = true,
      vexpand = true,
    };

    content = window_handle;

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

}