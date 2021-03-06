# Makefile to simplify vagrant usage

HOME_DIR=/vagrant
SRC_DIR=$(HOME_DIR)/src
GOTO_SRC_DIR=cd $(SRC_DIR)
MAKE_TOSSIM=make micaz sim
MAKE_CLEAN=make clean
MAKE_MICAZ=make micaz
RUN_SIMULATOR=python simulator.py
SSH=vagrant ssh
ZIP_NAME=fire-detection-wsn.zip
TO_ZIP=LICENSE Makefile noise/ README.md report.pdf scripts/ src/ topologies/ Vagrantfile

tossim:
	$(SSH) -c '$(GOTO_SRC_DIR) && $(MAKE_TOSSIM)'
clean:
	$(SSH) -c '$(GOTO_SRC_DIR) && $(MAKE_CLEAN)'
run:
	$(SSH) -c '$(GOTO_SRC_DIR) && $(MAKE_TOSSIM) && $(RUN_SIMULATOR)'
micaz:
	$(SSH) -c '$(GOTO_SRC_DIR) && $(MAKE_MICAZ)'
zip: clean
	zip $(ZIP_NAME) -r $(TO_ZIP)

all: tossim
