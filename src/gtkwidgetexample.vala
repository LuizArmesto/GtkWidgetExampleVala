/* gtkwidgetexample.vala
 *
 * Copyright (C) 2012 Luiz Armesto <luiz.armesto@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 *
 * Author:
 *	  Luiz Armesto <luiz.armesto@gmail.com>
 */

namespace GtkWidgetExample
{
	private class WidgetBase : Gtk.Widget
	{
		private bool dragging;
		private Gtk.CssProvider css_provider;
		private Pango.Layout layout;
		private int step = 10;
		private int pos = 0;
		private int margin_size;
		private DateTime today;

		public signal void changed ();

		public WidgetBase ()
		{
			Object ();
		}

		construct
		{
			add_events (Gdk.EventMask.BUTTON_PRESS_MASK
					| Gdk.EventMask.BUTTON_RELEASE_MASK
					| Gdk.EventMask.POINTER_MOTION_MASK
					| Gdk.EventMask.EXPOSURE_MASK
					);

			set_has_window (true);
			css_provider = new Gtk.CssProvider ();
			try {
				css_provider.load_from_path ("./gtkwidgetexample.css");
			} catch (Error e) {
				// TODO
			}

			var style_context = get_style_context ();
			style_context.add_provider (css_provider,
					Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
			style_context.add_class ("widgetexample");
			style_context.add_class (Gtk.STYLE_CLASS_ENTRY);

			var margin = style_context.get_margin (get_state_flags ());
			var border = style_context.get_border (get_state_flags ());

			this.margin_size = margin.left + border.left + 2;
			this.layout = create_pango_layout (null);
			this.today = new DateTime.now_local ();
		}

		public override void size_allocate (Gtk.Allocation allocation) {
			set_allocation(allocation);

			Gdk.Window window = get_window ();
			if (window == null) {
				return;
			}

			window.move_resize (allocation.x, allocation.y,
					allocation.width, allocation.height);
		}

		public override void realize () {
			set_realized (true);
			Gdk.Window window = get_window ();
			if (window == null) {
				Gtk.Allocation allocation;
				get_allocation (out allocation);

				Gdk.WindowAttr attributes = Gdk.WindowAttr ();
				attributes.x = allocation.x;
				attributes.y = allocation.y;
				attributes.width = allocation.width;
				attributes.height = allocation.height;

				attributes.event_mask = get_events ();
				attributes.window_type = Gdk.WindowType.CHILD;
				attributes.wclass = Gdk.WindowWindowClass.INPUT_OUTPUT;

				window = new Gdk.Window (get_parent_window (),
						attributes, Gdk.WindowAttributesType.X |
									Gdk.WindowAttributesType.Y);
				window.set_user_data (this);
				set_window (window);
			}
			//base.realize ();
		}

		public override void unrealize () {
			base.unrealize ();
		}

		public override void get_preferred_width (out int minimum_width,
				out int natural_width) {
			minimum_width = 300;
			natural_width = 400;
		}

		public override void get_preferred_width_for_height (int height,
				out int minimum_width, out int natural_width) {
			minimum_width = 300;
			natural_width = 400;
		}

		public override void get_preferred_height (out int minimum_height,
				out int natural_height) {
			minimum_height = 80;
			natural_height = 100;
		}

		public override void get_preferred_height_for_width (int width,
				out int minimum_height, out int natural_height) {
			minimum_height = 80;
			natural_height = 100;
		}

		public override bool draw (Cairo.Context cr) {
			var context = get_style_context ();

			var parent = get_parent ();
			var parent_context = parent.get_style_context ();

			// Get dimension
			var x0 = this.pos * this.step;
			var width = get_allocated_width ();
			var height = get_allocated_height ();

			// Get the foreground color
			var fg_rgba = context.get_color (get_state_flags ());
			// Get the parent background color
			var parent_bg_rgba = parent_context.get_background_color (
					get_state_flags ());
			cr.set_source_rgba (parent_bg_rgba.red,
								parent_bg_rgba.green,
								parent_bg_rgba.blue,
								parent_bg_rgba.alpha);
			cr.paint ();

			// Draw our styles
			context.render_background (cr, 0, 0, width, height);
			context.render_frame (cr, 0, 0, width, height);

			// Clip the content
			cr.rectangle (this.margin_size, margin_size,
						  width - 2 * margin_size,
						  height - 2 * margin_size);
			cr.clip ();

			// Draw the content
			cr.rectangle (x0 + 20, 20,
						  width - 2 * 20,
						  height - 2 * 20);
			cr.set_line_width (5.0);
			cr.stroke ();

			cr.set_source_rgba (fg_rgba.red, fg_rgba.green, fg_rgba.blue,
								fg_rgba.alpha);
			var text = this.today.format ("%b %d %S");
			this.layout.set_text (text, text.length);int fontw, fonth;
			this.layout.get_pixel_size (out fontw, out fonth);
			cr.move_to (x0 + (width - fontw) / 2, (height - fonth) / 2);
			Pango.cairo_update_layout (cr, this.layout);
			Pango.cairo_show_layout (cr, this.layout);

			return true;
		}

		public override bool button_press_event (Gdk.EventButton event) {
			return false;
		}

		public override bool button_release_event (Gdk.EventButton event) {
			if (this.dragging) {
				this.dragging = false;
				emit_changed_signal ();
			}
			return false;
		}

		public override bool motion_notify_event (Gdk.EventMotion event) {
			if (this.dragging) {
				emit_changed_signal ();
			}
			return false;
		}

		private void emit_changed_signal () {
			redraw_canvas ();
			changed ();
		}

		private void redraw_canvas () {
			var window = get_window ();
			if (window == null) {
				return;
			}

			var region = window.get_clip_region ();
			// redraw the cairo canvas completely by exposing it
			window.invalidate_region (region, true);
			window.process_updates (true);
		}

		public void scroll_left () {
			scroll (this.step);
		}

		public void scroll_right () {
			scroll (-this.step);
		}

		private void scroll (int step) {
			this.pos += step / this.step;

			var window = get_window ();
			var region = window.get_visible_region ();
			window.move_region (region, step, 0);

			var rect = Gdk.Rectangle ();
			int x1, x2;
			if (step > 0) {
				x1 = 0;
				x2 = get_allocated_width () - this.margin_size;
				rect.width = step * 2;
			} else {
				x1 = get_allocated_width () - (int) Math.fabs(step * 2.0);
				x2 = 0;
				rect.width = - step * 2;
			}
			rect.x = x1;
			rect.y = 0;
			rect.height = get_allocated_height ();
			window.invalidate_rect (rect, false);
			rect.x = x2;
			rect.width = this.margin_size;
			window.invalidate_rect (rect, false);
		}
	}

	public class Widget : Gtk.Grid
	{
		private int width;
		private int height;
		private WidgetBase widget;
		private Gtk.Button lbutton;
		private Gtk.Button rbutton;

		public Widget ()
		{
			Object ();
		}

		construct
		{
			set_border_width (3);
			set_size_request (500, 50);

			insert_row(0);
			insert_row(0);
			insert_column(0);
			insert_column(0);

			this.widget = new WidgetBase ();
			this.widget.vexpand = true;
			this.widget.hexpand = true;
			attach (this.widget, 1, 0, 1, 1);

			this.lbutton = new Gtk.Button ();
			this.lbutton.vexpand = true;
			this.lbutton.set_size_request (15, 50);
			this.lbutton.draw.connect_after ((cr) => {
				var width = this.lbutton.get_allocated_width ();
				var height = this.lbutton.get_allocated_height ();
				var size = 8;
				var context = this.lbutton.get_style_context ();
				context.render_arrow (cr, 3 * Math.PI_2,
						width / 2 - size / 2, height / 2 - size / 2,
						size);
				return false;
			});
			this.lbutton.clicked.connect_after ((ev) => {
				this.widget.scroll_left ();
			});
			this.rbutton = new Gtk.Button ();
			this.rbutton.vexpand = true;
			this.rbutton.set_size_request (15, 50);
			this.rbutton.draw.connect_after ((cr) => {
				var width = this.rbutton.get_allocated_width ();
				var height = this.rbutton.get_allocated_height ();
				var size = 8;
				var context = this.lbutton.get_style_context ();
				context.render_arrow (cr, Math.PI_2,
						width / 2 - size / 2, height / 2 - size / 2,
						size);
				return false;
			});
			this.rbutton.clicked.connect_after ((ev) => {
				this.widget.scroll_right ();
			});
			attach (this.lbutton, 0, 0, 1, 2);
			attach (this.rbutton, 2, 0, 1, 2);
		}

		public override void size_allocate (Gtk.Allocation allocation) {
			base.size_allocate (allocation);

			this.width = allocation.width;
			this.height = allocation.height;
		}
	}
}
