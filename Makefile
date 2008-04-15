WALL_REALLY = -Wall -Wextra -Wmost -Wformat-security -Wlong-long -Winline -Wnested-externs -Wunreachable-code -Wstrict-prototypes 
CC=gcc
ARCHITECTURE_FLAGS := $(foreach arch,$(RC_ARCHS),-arch $(arch))
CFLAGS = -g3 -Os $(WALL_REALLY) -D_FORTIFY_SOURCE=2 -pipe $(ARCHITECTURE_FLAGS)
LDFLAGS = $(CFLAGS)

XINIT_DIR=/usr/X11/lib/X11/xinit

MKDIR = /bin/mkdir -p
INSTALL = /usr/bin/install -c

all: privileged_startx

privileged_startx.h privileged_startxServer.c privileged_startxUser.c privileged_startxServer.h: privileged_startx.defs
	mig -sheader privileged_startxServer.h privileged_startx.defs

server.o: privileged_startx.h

client.o: privileged_startx.h

privileged_startx: privileged_startx.o server.o client.o privileged_startxServer.o privileged_startxUser.o

clean:
	-rm -f *.o privileged_startx privileged_startx.h privileged_startxServer.c privileged_startxUser.c privileged_startxServer.h

install: all
	$(MKDIR) $(DSTROOT)$(XINIT_DIR)/privileged_startx.d
	$(INSTALL) -m 755 privileged_startx $(DSTROOT)$(XINIT_DIR)
	$(INSTALL) -m 755 10-tmpdirs.sh $(DSTROOT)$(XINIT_DIR)/privileged_startx.d/10-tmpdirs
	$(INSTALL) -m 755 20-font_cache.sh $(DSTROOT)$(XINIT_DIR)/privileged_startx.d/20-font_cache
	
	$(MKDIR) $(DSTROOT)/System/Library/LaunchDaemons
	$(INSTALL) -m 644 org.x.privileged_startx.plist $(DSTROOT)/System/Library/LaunchDaemons
	
	# font_cache.sh is pending license approval, so don't install it yet
	#$(MKDIR) $(DSTROOT)/usr/X11/bin
	#$(INSTALL) -m 755 font_cache.sh $(DSTROOT)/usr/X11/bin/font_cache
