class MainWindow: Gtk.Window
{

	public MainWindow ()
	{
		var widget = new GtkWidgetExample.Widget ();
		add (widget);
	}
}

class Main : GLib.Object
{
	public static int main (string[] args) {
		Gtk.init (ref args);

		var mainwindow = new MainWindow ();
		mainwindow.destroy.connect (Gtk.main_quit);
		mainwindow.show_all ();

		Gtk.main ();
		return 0;
	}
}
