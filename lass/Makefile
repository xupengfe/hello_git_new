BIN = t1 t2 t3 t4 test test_vsyscall sigsetjump lass_test \
        clflush sig_lass_check ori_sig_lass chocobo_root

all: $(BIN)

$(all):
	$(CC) -o $@ $<

test_vsyscall:
	$(CC) -m64 -o test_vsyscall test_vsyscall.c -ldl

chocobo_root:
	$(CC) -lpthread -o chocobo_root chocobo_root.c

clean:
	rm -f $(BIN)
