# Makefile to simplify vagrant usage

HOME_DIR=/vagrant
SRC_DIR=$(HOME_DIR)/src
GOTO_SRC_DIR=cd $(SRC_DIR)
MAKE_TOSSIM=make micaz sim
SSH=vagrant ssh

tossim:
	$(SSH) -c '$(GOTO_SRC_DIR) && $(MAKE_TOSSIM)'
clean:
	$(SSH) -c '$(GOTO_SRC_DIR) && make clean'

all: tossim
