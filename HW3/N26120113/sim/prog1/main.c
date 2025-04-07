// Insertion Sort
#include <stdint.h>
extern unsigned int array_size;
extern short array_addr;
const short* array = &array_addr;
extern short _test_start;
short* dest = &_test_start;


int main(void) 
{
	int temp, sort_idx, i;
	*(&_test_start) = *(&array_addr);

	for(i=1; i<array_size; i++)
    {
        *(&_test_start+i) = *(&array_addr+i);
		temp = *(&_test_start+i);
        sort_idx=i;

        while((*(&_test_start+sort_idx-1) > temp) && sort_idx>0)
        {
            *(&_test_start+sort_idx) = *(&_test_start+sort_idx-1);
			*(&_test_start+sort_idx-1) = temp;
            sort_idx--;
        }
    }

    return 0;
}


// void sort_ins(int *array, int size)
// {
//     int temp, sort_idx;

//     for(int i=1; i<size; i++)
//     {
//         temp=array[i];
//         sort_idx=i-1;

//         while(temp<array[sort_idx] && sort_idx>=0)
//         {
//             array[sort_idx+1] = array[sort_idx];
//             sort_idx--;
//         }

//         array[sort_idx]=temp;
//     }
// }

//---------------2022-----------------//
/*
 int main (void) 
 {
 	// extern	int	array_size;
 	// extern	short	array_addr;
 	// extern	short	_test_start;

 	int temp, point;
 	*(&_test_start) = *(&array_addr);
 	for (int count = 1; count < array_size; ++count) 
     {
 		*(&_test_start+count) = *(&array_addr+count);
 		temp = *(&_test_start+count);
 		point = count;
 		while ((point >0) && (*(&_test_start+point-1) > temp)) {
 			*(&_test_start+point) = *(&_test_start+point-1);
 			*(&_test_start+point-1) = temp;
 			--point;
 		}
 	}
 	return 0;
 }
 */