int main(void) 
{
	extern unsigned char _binary_image_bmp_start;
	extern unsigned char _binary_image_bmp_end;
	extern unsigned int _binary_image_bmp_size;
	extern unsigned char _test_start;
    int i, j;
	
	unsigned char byte_size0 = *(&_binary_image_bmp_start + 2);
	unsigned char byte_size1 = *(&_binary_image_bmp_start + 3);
	unsigned char byte_size2 = *(&_binary_image_bmp_start + 4);
	unsigned char byte_size3 = *(&_binary_image_bmp_start + 5);
	unsigned int bmp_byte_size = (byte_size3 << 24) + (byte_size2 << 16) + (byte_size1 << 8) + byte_size0;

	for (i=0; i<=53; i++)
    {
		*(&_test_start + i) = *(&_binary_image_bmp_start + i);
    }

	for (j=54; j < bmp_byte_size-1; j+=3) 
    {
		unsigned char gray;
		if ((*(&_binary_image_bmp_start + j) == 0xff) && (*(&_binary_image_bmp_start + j + 1) == 0xff) && (*(&_binary_image_bmp_start + j + 2) == 0xff))
        {
			gray = 0xff;
        }
		else 
        {
			unsigned char blue = *(&_binary_image_bmp_start + j);
			unsigned char green = *(&_binary_image_bmp_start + j + 1);
			unsigned char red = *(&_binary_image_bmp_start + j + 2);
			gray = ((blue * 11) + (green * 59) + (red * 30)) / 100;
		}
		*(&_test_start + j) = gray;
		*(&_test_start + j + 1) = gray;
		*(&_test_start + j + 2) = gray;
	}

	return 0;
}

// int main(void) 
// {
//     extern unsigned char _binary_image_bmp_start;
// 	extern unsigned char _binary_image_bmp_end;
// 	extern unsigned int _binary_image_bmp_size;
// 	extern unsigned char _test_start;
//     unsigned char gray, blue, green, red;


//     for(int i=0; i<54; i++)
//     {
//         *(&_test_start + i) = *(&_binary_image_bmp_start + i);
//     }

//     for(int j=54; j<_binary_image_bmp_size; j+=3)
//     {
//         blue = *(&_binary_image_bmp_start + j);
// 		green = *(&_binary_image_bmp_start + j + 1);
// 		red = *(&_binary_image_bmp_start + j + 2);
// 		gray = ((blue * 11) + (green * 59) + (red * 30)) / 100;

//         *(&_test_start + j) = gray;
// 		*(&_test_start + j + 1) = gray;
// 		*(&_test_start + j + 2) = gray;
//     }
// 	return 0;
// }