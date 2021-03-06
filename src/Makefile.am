## Process this file with automake to produce Makefile.in

## Created by Anjuta

uidir = $(pkgdatadir)/ui
ui_DATA = ui/relay.ui ui/server_window.ui ui/relay.svg ui/settings_window.ui

assetsdir = $(pkgdatadir)/assets
assets_DATA = ui/relay.png \
    assets/connect-server.png \
    assets/help-info-symbolic.svg \
    assets/mail-unread.svg \
    assets/manage-servers.png \
    assets/paste.png \
    assets/saved-server.png \
    assets/server-icon.svg \
    assets/server-icon-light.svg \
    assets/system-users.svg \
    assets/user-idle.svg \
    assets/user-offline.svg \
    assets/list-add-symbolic.svg \
    assets/list-remove-symbolic.svg \
    assets/channel-loading.svg 

appicondir = $(datadir)/icons/hicolor/scalable/apps
appicon_DATA = ui/relay.svg

desktopdir = $(datadir)/applications
desktop_DATA = ../data/relay.desktop

gsettings_SCHEMAS = ../data/org.agronick.relay.gschema.xml
@GSETTINGS_RULES@

AM_CPPFLAGS = \
    -DPACKAGE_LOCALE_DIR=\""$(localedir)"\" \
    -DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
    -DPACKAGE_DATA_DIR=\""$(pkgdatadir)"\" \
    -DGETTEXT_PACKAGE=\""relay"\"\
    $(RELAY_CFLAGS)

AM_CFLAGS =\
     -Wall\
     -g

bin_PROGRAMS = relay

relay_SOURCES = \
    config.vapi \
    main_window.vala \
    sqlclient.vala \
    server_manager.vala \
    channel_tab.vala \
    message.vala \
    irc.vala \
    relay.vala \
    connection.vala \
    rich_text.vala \
    drag_file.vala \
    org.github.agronick.relay \
    settings.vala \
    main_entry.vala

relay_VALAFLAGS =  \
    -X -DGETTEXT_PACKAGE="relay" --target-glib 2.32 --pkg unity --pkg gee-0.8 --pkg x11 --pkg gtk+-3.0 --pkg glib-2.0 --pkg granite --pkg sqlite3

relay_LDFLAGS = \
	 -lm -lX11 -lglib-2.0

relay_LDADD = $(RELAY_LIBS)

EXTRA_DIST = $(ui_DATA) $(assets_DATA)

UPDATE_DESKTOP = sudo update-desktop-database $(desktopdir) || :

install-data-hook: 
	$(UPDATE_DESKTOP) || :; \
    sudo rm $(datadir)/icons/hicolor/scalable/apps/relay.png || :; \
    sudo rm $(pkgdatadir)/ui/relay.png || :; \
    sudo gtk-update-icon-cache -f -t $(datadir)/icons/hicolor || :

uninstall-local:
	-rm -r $(uidir)
	-rm -r $(imagedir)
	-rm -r $(pkgdatadir)

