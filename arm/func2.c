int func2() {
    int func2_ret = 0x13;

    return func2_ret;
}

int func1()
{
    int func1_ret = 0x12;

    func2();

    return func1_ret;
}


int main(void)
{
    int main_ret = 0x11;

    func1();

    return main_ret;
}
