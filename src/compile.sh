#!/bin/bash -i

valac-0.16 -g gtkwidgetexample.vala --save-temps --pkg gtk+-3.0 --gir=GtkWidgetExample-3.0.gir --library GtkWidgetExample-3.0 -X -fPIC -X --shared -o gtkwidgetexample.so -H gtkwidgetexample.h
g-ir-compiler --shared-library=gtkwidgetexample.so GtkWidgetExample-3.0.gir -o GtkWidgetExample-3.0.typelib
valac-0.16 example.vala --save-temps --pkg gtk+-3.0 --pkg GtkWidgetExample-3.0 -g --girdir=. --vapidir=. -X gtkwidgetexample.so -X -I.
