int boot(void) 
{
    extern unsigned int _dram_i_start;
    extern unsigned int _dram_i_end;
    extern unsigned int _imem_start;

    extern unsigned int __sdata_start;
    extern unsigned int __sdata_end;
    extern unsigned int __sdata_paddr_start;

    extern unsigned int __data_start;
    extern unsigned int __data_end;
    extern unsigned int __data_paddr_start;
  
    for (int i=0; i<(&_dram_i_end-&_dram_i_start+1); i++)
    {
        *(&_imem_start+i) = *(&_dram_i_start+i);
    }
        
    for (int j=0; j<(&__sdata_end-&__sdata_start+1); j++)
    {
        *(&__sdata_start+j) = *(&__sdata_paddr_start+j);
    }
        
    for (int k=0; k<(&__data_end-&__data_start+1); k++)
    {
        *(&__data_start+k) = *(&__data_paddr_start+k);
    }
    
	return 0;
}
