int main (void) {
	extern	int	array_size;
	extern	int	array_addr;
	extern	int	_test_start;

	int temp, p;
	*(&_test_start) = *(&array_addr);
	for (int i = 1; i < array_size; ++i) {
		*(&_test_start+i) = *(&array_addr+i);
		temp = *(&_test_start+i);
		p = i;
		while ((p >0) && (*(&_test_start+p-1) > temp)) {
			*(&_test_start+p) = *(&_test_start+p-1);
			*(&_test_start+p-1) = temp;
			--p;
		}
	}
	return 0;
}
