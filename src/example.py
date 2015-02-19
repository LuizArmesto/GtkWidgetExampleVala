#!/usr/bin/env python
#-*- coding:utf-8 -*-

from gi.repository import Gtk
from gi.repository import GtkWidgetExample

if __name__ == '__main__':
    Gtk.init([])
    window = Gtk.Window()
    window.connect('destroy', Gtk.main_quit, 'WM destroy')
    vbox = Gtk.VBox()
    timeline = GtkWidgetExample.Widget()
    vbox.add(timeline)
    window.add(vbox)
    window.show_all()
    Gtk.main()
