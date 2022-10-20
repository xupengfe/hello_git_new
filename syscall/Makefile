BIN = getcpu set_area

all: $(BIN)

$(all):
	$(CC) -o $@ $<

getcpu:
	$(CC) -o $@ getcpu.c

clean:
	rm -f $(BIN) *.o
