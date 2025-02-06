# SPDX-License-Identifier: GPL-2.0-only

BIN := d2d_mem_cp

all: $(BIN)

$(all):
	gcc $^ -o $@

d2d_mem_cp:
	gcc d2d_mem_cp.c -o $@ -lnuma -pthread

clean:
	rm -rf $(BIN)

