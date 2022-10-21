BIN = getcpu set_area set_socket

all: $(BIN)

$(all):
	$(CC) -o $@ $<

getcpu:
	$(CC) -o $@ getcpu.c

clean:
	rm -f $(BIN) *.o
