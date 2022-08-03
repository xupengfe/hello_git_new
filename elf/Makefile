BIN = hello

all: $(BIN)

$(all):
	$(CC) -o $@ $<

hello:
	gcc hello.c
	xxd -p a.out > hello.dmp
	$(CC) -o hello hello.c

clean:
	rm -f $(BIN) *.o *.out
