BIN = getcpu

all: $(BIN)

$(all):
	$(CC) -o $@ $<

getcpu:
	$(CC) -o $@ getcpu.c

clean:
	rm -f $(BIN) *.o
