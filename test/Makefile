BIN = main t1

all: $(BIN)

$(all):
	$(CC) -o $@ $<

main:
	$(CC) -c add.c
	$(CC) -m64 -o main -O2 -g -std=gnu99 -pthread -Wall -no-pie -mno-sse -mno-mmx -mno-sse2 -mno-avx main.c add.o


#	gcc -m64 -o main -O2 -g -std=gnu99 -pthread -Wall -no-pie -mno-sse -mno-mmx -mno-sse2 -mno-avx main.c add.c

clean:
	rm -f $(BIN) *.o
