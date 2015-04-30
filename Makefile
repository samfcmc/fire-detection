# Makefile to simplify vagrant usage

HOME_DIR=/vagrant
SRC_DIR=$(HOME_DIR)/src
GOTO_SRC_DIR=cd $(SRC_DIR)
MAKE_TOSSIM=make micaz sim
SIMULATOR=$(SRC_DIR)/simulator.py
SSH=vagrant ssh

tossim:
	$(SSH) -c '$(GOTO_SRC_DIR) && $(MAKE_TOSSIM)'
clean:
	$(SSH) -c '$(GOTO_SRC_DIR) && make clean'
run:
	$(SSH) -c '$(GOTO_SRC_DIR) && python simulator.py'
micaz:
	$(SSH) -c '$(GOTO_SRC_DIR) && make micaz'

all: tossim
