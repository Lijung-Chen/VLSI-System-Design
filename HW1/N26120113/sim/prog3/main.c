int GCD (int D1, int D2) {
	D1 = D1 % D2;
	if (D1 == 0) 
		return D2;
	else 
		return GCD(D2, D1);
}

int main () {
	extern int div1;
	extern int div2;
	extern int _test_start;

	if (div1 < div2) {
		int temp = div1;
			div1 = div2;
			div2 = temp;
	}

	*(&_test_start) = GCD(div1, div2);
	
	return 0;
}