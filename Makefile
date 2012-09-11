B ?= build

CFLAGS = -pthread -Wall -Wextra -Wno-unused-parameter -Ideps/http_parser -Ideps/libuv/include -I/usr/local/include/luajit-2.0
LDFLAGS = -lpthread

LUA_DIR ?= /usr
LUA_LIBDIR = $(LUA_DIR)/lib/lua/5.1
LUA_SHAREDIR = $(LUA_DIR)/share/lua/5.1

OS_NAME=$(shell uname -s)
MH_NAME=$(shell uname -m)

ifeq ($(OS_NAME), Darwin)
ENV=MACOSX_DEPLOYMENT_TARGET=10.4
DLLFLAGS=-bundle -undefined dynamic_lookup
else
DLLFLAGS=-shared
ENV= 
endif


SOURCES = \
	src/lua_uv.c \
	src/core.c \
	src/tcp.c \

.PHONY:	prereqs clean install

OBJECTS = $(patsubst src/%.c,$(B)/%.o,$(SOURCES))

$(B)/uv.so:	prereqs $(OBJECTS) $(B)/http_parser.o deps/libuv/uv.a
	$(CC) $(DLLFLAGS) -o $@ $(OBJECTS) deps/libuv/uv.a $(LDFLAGS)

$(B)/http_parser.o:	deps/http_parser/http_parser.c deps/http_parser/http_parser.h
	$(CC) -c $(CFLAGS) -fPIC $< -o $@

$(OBJECTS): $(B)/%.o: src/%.c src/lua_uv.h Makefile
	$(CC) -c $(CFLAGS) -fPIC $< -o $@

prereqs:
	[ -d $(B) ] || mkdir $(B)

clean:
	rm -rf $(B)

install:	$(B)/uv.so
	mkdir -p $(LUA_LIBDIR)
	cp $(B)/uv.so $(LUA_LIBDIR)

deps/libuv/uv.a:
	$(MAKE) -C deps/libuv CFLAGS+=-fPIC
