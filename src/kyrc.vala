/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * main.c
 * Copyright (C) 2015 Kyle Agronick <agronick@gmail.com>
 * 
 * KyRC is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * KyRC is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using GLib;
using Gtk;
using Gee;

public class Main : Object 
{

	/* 
	 * Uncomment this line when you are done testing and building a tarball
	 * or installing
	 */
	//const string UI_FILE = Config.PACKAGE_DATA_DIR + "/ui/" + "kyrc.ui";
	const string UI_FILE = "src/kyrc.ui";
	const string UI_FILE_SERVERS = "src/server_window.ui";

	/* ANJUTA: Widgets declaration for kyrc.ui - DO NOT REMOVE */
 
	Notebook tabs;
	Window window;
	Entry input;
	SqlClient sqlclient = new SqlClient();
	
	Gee.HashMap<int, TextView> outputs = new Gee.HashMap<int, TextView> ();
	Gee.HashMap<int, Client> clients = new Gee.HashMap<int, Client> ();
	

	public Main ()
	{

		try 
		{
			Gtk.Settings.get_default().set("gtk-application-prefer-dark-theme", true);
			
			var builder = new Builder ();
			builder.add_from_file (UI_FILE);
			builder.connect_signals (this);

			var toolbar = new Gtk.HeaderBar (); 
			
			window = builder.get_object ("window") as Window;
			tabs = builder.get_object("tabs") as Notebook;
			input = builder.get_object("input") as Entry;

			input.activate.connect (() => {
				send_text_out(input.get_text ());
				input.set_text("");
			});

			set_up_add_sever(toolbar);

			toolbar.set_title("Kyrc"); 
			toolbar.show_all();
			
            toolbar.show_close_button = true;
			window.set_titlebar(toolbar);
			/* ANJUTA: Widgets initialization for kyrc.ui - DO NOT REMOVE */
			window.show_all ();  

			add_tab("irc.freenode.net");
			
 
		} 
		catch (Error e) {
			stderr.printf ("Could not load UI: %s\n", e.message);
		} 

	}

	public void add_tab(string url)
	{ 
		Gtk.Label title = new Gtk.Label (url);   
		ScrolledWindow scrolled = new Gtk.ScrolledWindow (null, null);
		TextView output = new TextView();
		var close_btn = new Gtk.Image.from_icon_name("window-close", Gtk.IconSize.MENU);
		var eb = new EventBox();
	 
		eb.add(close_btn);
		eb.show(); 
		close_btn.show();
		Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0); 
		title.show(); 
		box.pack_start(title, false, false, 15);
		box.pack_start(eb, true, true, 0);
		output.set_editable(false); 
		output.set_wrap_mode (Gtk.WrapMode.WORD); 
		scrolled.add(output);

		int index = tabs.append_page(scrolled, box); 
		 
		outputs.set(index, output);
		
		tabs.show_all();
		
		var client = new Client();  
		client.username = "kyle123456";
		clients.set(index, client);
		
		client.new_data.connect(add_text);
		client.connect_to_server("irc.freenode.net", index);
 
		eb.button_release_event.connect( (event) => { 
			stderr.printf("clicked");
			remove_tab(index);
			return false;
		});
		eb.enter_notify_event.connect((event) => { 
			eb.get_window().set_cursor(new Gdk.Cursor.for_display(Gdk.Display.get_default(), Gdk.CursorType.HAND1));
			stderr.printf("hover");
			return false;
		});
	}

	public void add_text(int index, string data)
	{
		TextView tv = outputs[index]; 
		TextIter outiter;
		tv.buffer.get_end_iter(out outiter); 
		ScrolledWindow sw = (ScrolledWindow)tv.get_parent();
		Idle.add( () => {   
			string text = data + "\n";  
			tv.buffer.insert(ref outiter, text, text.length);
			Adjustment adj = sw.get_vadjustment(); 
			adj.set_value(adj.get_upper() - adj.get_page_size());
			return false;
		});

		//Sleep for a little bit so the adjustment is updated
		Thread.usleep(5000);
		
		Idle.add( () => { 
			Adjustment adj = sw.get_vadjustment(); 
			adj.set_value(adj.get_upper() - adj.get_page_size());  
			sw.set_vadjustment(adj);  
			return false;
		});
	 
	}

	public void send_text_out(string text)
	{
		int page = tabs.get_current_page();
		clients[page].send_output(text);
		add_text(page, clients[page].username + ": " + text);
	}

	public void set_up_add_sever(Gtk.HeaderBar toolbar)
	{ 
		var add_server_button = new Gtk.Button.from_icon_name("list-add-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
		add_server_button.button_release_event.connect( (event) => { 
			var builder = new Builder();
			builder.add_from_file(UI_FILE_SERVERS);
			var window = builder.get_object ("window") as Window;
			var box = builder.get_object ("port_wrap") as Box;
			var ok = builder.get_object ("ok") as Button;
			var cancel = builder.get_object ("cancel") as Button;
			var add_channel = builder.get_object ("add_channel") as Button;
			var remove_channel = builder.get_object ("remove_channel") as Button;
			var new_channel = builder.get_object ("channel_name") as Entry;
			var channels = builder.get_object ("channel") as ListBox;
			var server_btns = builder.get_object ("server_buttons") as Box;

            var add_server = new Gtk.Button.from_icon_name("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            var remove_server = new Gtk.Button.from_icon_name("list-remove-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
			server_btns.pack_end(add_server, false, false, 0);
			server_btns.pack_end(remove_server, false, false, 0);
			
			channels.set_size_request (100,100);
			var chn_adj = new Adjustment(1, 1, 500, 1, 2, 100); 			
			

			cancel.button_release_event.connect( (event) => {  
				window.close(); 
				stderr.printf("event type: " + event.type.to_string());
				return false;
			});
 
			add_channel.button_release_event.connect( (event) => { 
				string chan_name = new_channel.get_text().strip();
				if(chan_name.length == 0)
					return false;
				var lbr = new ListBoxRow();
				lbr.add(new Label(chan_name));
				channels.add(lbr);  
				channels.set_adjustment(chn_adj);
				channels.show_all();
				return false;
			});
			
			Gtk.SpinButton port = new Gtk.SpinButton.with_range (0, 65535, 1);
			port.set_value(6667);
			box.pack_start(port, false, false, 0); 
			window.show_all ();   
			return false;
		});
        add_server_button.tooltip_text = "Add new server";  
		toolbar.pack_start(add_server_button); 
	}

	private void remove_tab(int index)
	{
		tabs.remove_page(index);
		clients[index].stop(); 
		clients.unset(index);
		outputs.unset(index);
	}
  
	[CCode (instance_pos = -1)]
	public void on_destroy (Widget window) 
	{
		Gtk.main_quit();
	}

	static int main (string[] args) 
	{
		Gtk.init (ref args);
		var app = new Main ();

		Gtk.main ();
		
		return 0;
	}
}

