using Gtk;
using Gdk;

public class Larawan.Views.MainWindow : Adw.ApplicationWindow {

  static construct {
    Adw.init();
  }

  public MainWindow(Larawan.Application larawan){
      Object(application: larawan);
  }

  construct {
    var gesture_click = new GestureClick ();

    // Connect the signal handler for the clicked event
    gesture_click.pressed.connect(() => {
      info("image pressed!!!");
    });

    // Create an image widget
    //  var image = new Gtk.Image.from_pixbuf(pixbuf);
    var image = new Picture.for_filename ("/home/xchan/Downloads/sunset.jpg");
    image.hexpand = true;
    image.vexpand = true;
    image.content_fit = ContentFit.COVER;
    image.width_request = 480;
    image.height_request = 300;
    content = image;
  }

}