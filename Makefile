.PHONY: build lint test

IVERILOG ?= iverilog
VVP ?= vvp
SOURCES := tic_tac_toe.v tic_tac_toe_game_tb.v
BUILD_DIR := build
SIM := $(BUILD_DIR)/tic_tac_toe

build:
	@mkdir -p $(BUILD_DIR)
	$(IVERILOG) -g2012 -Wall -s tb_tik_tac_toe -o $(SIM) $(SOURCES)

lint: build
	@echo "Icarus warning check completed during build."

test: build
	$(VVP) $(SIM)
