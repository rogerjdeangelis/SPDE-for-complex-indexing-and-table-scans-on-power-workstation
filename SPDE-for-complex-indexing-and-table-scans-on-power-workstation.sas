SPDE for complex indexing and table scans on power workstation                                                                  
                                                                                                                                
Note SPDE handles many more index structures                                                                                    
                                                                                                                                
Benchmarks ( querying a 40gb, 390,000,000 row and 13 column table for 30,000,000 results)                                       
                                                                                                                                
                             $500 (new price)    EG (Linux)                                                                     
                             2007 T7400(2007)    Server (better than 1yr ago)                                                   
Benchmark                        Seconds                   Seconds                                                              
=========                    ================    =============================                                                  
                                                                                                                                
Query (30,000,000 output (where=(state=:"A" or STATE=:"F")))                                                                    
=========================                      Seconds                                                                          
Using SPDE (mix RAID 0 & spin)  21 * writes       NA                                                                            
SASFILE (no index)              52 * no index)    NA                                                                            
No SPDE and RAID 0 Array       104 * writes       NA                                                                            
7200 RPM disk                  183 * writes       NA                                                                            
WORK directories (unix&win 7)  143 * writes       102  * samba on EG server;                                                    
                                                                                                                                
                                                                                                                                
Table Scans (no writes similar performance when < 100,000 output writes)                                                        
========================================================================                                                        
SASFILE table scan(no output)   22 * no writes    NA                                                                            
SPDE Table scan (no output)     46 * no writes    NA                                                                            
No SPDE Raid 0( No output)      81 * no writes    NA                                                                            
7200rpm Table Scan(no output)  295 * no writes    NA                                                                            
WORK (unix and Win 7(RAID )     79 * no writes    93   * samba on EG derver;                                                    
                                                                                                                                
SPDE is part of base workstation.                                                                                               
                                                                                                                                
Taking advantage of SPDE and comples indexing and table scans                                                                   
                                                                                                                                
SAS Forum                                                                                                                       
https://tinyurl.com/y7tns2u4                                                                                                    
https://communities.sas.com/t5/SAS-Programming/Understanding-the-basics-of-how-to-determine-what-hardware/m-p/519618            
                                                                                                                                
Power workstation  (falling prices on EBAY very old hardware)                                                                   
==============================================================                                                                  
Run on a Dell T7400, 64gb ram two RAID 0 Arrays of four 250gb SSDs and three spinning                                           
drives, One 10,000 rpm(160gb c drive) and two 7,200 RPM. I think you can pick one up off lease                                  
on EbAY fully loaded for less than $800. You may have to purchase SSDs separately.                                              
                                                                                                                                
I could grid this with systask.                                                                                                 
                                                                                                                                
Less than 1 second if pulling 20,000 instead of 3 million.                                                                      
                                                                                                                                
                                                                                                                                
INPUT                                                                                                                           
=====                                                                                                                           
                                                                                                                                
This is the SPDE case. Only change the libname for other cases.                                                                 
                                                                                                                                
* this is in my autoexec;                                                                                                       
%let LETTERSQ="A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z";          
                                                                                                                                
options SPDEPARALLELREAD=YES;                                                                                                   
run;quit;                                                                                                                       
                                                                                                                                
libname spde spde                                                                                                               
('c:\spde_c','d:\spde_d','f:\spde_f','g:\spde_g','i:\spde_i')                                                                   
    metapath =('c:\spde_c\metadata')                                                                                            
    indexpath=(                                                                                                                 
          'c:\spde_c'                                                                                                           
          ,'d:\spde_d'                                                                                                          
          ,'f:\spde_f'                                                                                                          
          ,'g:\spde_g'                                                                                                          
          ,'i:\spde_i')                                                                                                         
    datapath=(                                                                                                                  
          'c:\spde_c'                                                                                                           
          ,'d:\spde_d'                                                                                                          
          ,'f:\spde_f'                                                                                                          
          ,'g:\spde_g'                                                                                                          
          ,'i:\spde_i')                                                                                                         
                                                                                                                                
    partsize=500m                                                                                                               
  ;                                                                                                                             
                                                                                                                                
data spde.gb30;                                                                                                                 
  array facs[10] fac1-fac10 ( 10*99);                                                                                           
  retain fac1-fac10;                                                                                                            
  do state=&lettersq;                                                                                                           
     do county=1 to 1500;                                                                                                       
        do pat=1 to 10000;                                                                                                      
           output;                                                                                                              
        end;                                                                                                                    
     end;                                                                                                                       
  end;                                                                                                                          
run;quit;                                                                                                                       
                                                                                                                                
Proc datasets lib=Spde ;                                                                                                        
 modify gb30(ASYNCINDEX=YES);                                                                                                   
 index create stacty = (state county);                                                                                          
Run;Quit;                                                                                                                       
                                                                                                                                
                                                                                                                                
PROCESS                                                                                                                         
=======                                                                                                                         
                                                                                                                                
* Just change the libname for all the cases above;                                                                              
                                                                                                                                
QUERY                                                                                                                           
-----                                                                                                                           
                                                                                                                                
data sta_a_cty_50;                                                                                                              
   set spde.gb30(where=(state=:"A" or STATE=:"F"));                                                                             
run;quit;                                                                                                                       
                                                                                                                                
NOTE: There were 30 000 000 observations read from the data set SPDE.GB30.                                                      
     WHERE (state=:'A') or (STATE=:'F');                                                                                        
NOTE: The data set WORK.STA_A_CTY_50 has 30,000,000 observations and 13 variables.                                              
NOTE: DATA statement used (Total process time):                                                                                 
      real time           17.38 seconds                                                                                         
      cpu time            14.18 seconds                                                                                         
                                                                                                                                
* 1,490,000 writes;                                                                                                             
data sta_a_cty;                                                                                                                 
   set spde.gb30(where=(state=:"A" and  1000<County<1150));                                                                     
run;quit;                                                                                                                       
                                                                                                                                
NOTE: There were 1490000 observations read from the data set SPDE.GB30.                                                         
      WHERE (state=:'A') and (County>1000 and County<1150);                                                                     
NOTE: The data set WORK.STA_A_CTY has 1490000 observations and 13 variables.                                                    
NOTE: DATA statement used (Total process time):                                                                                 
      real time           1.88 seconds                                                                                          
      cpu time            3.05 seconds                                                                                          
                                                                                                                                
                                                                                                                                
TABLE SCAN                                                                                                                      
----------                                                                                                                      
                                                                                                                                
* SPDE TABLE SCAN;                                                                                                              
                                                                                                                                
data _null_;                                                                                                                    
   set spde.gb30;                                                                                                               
run;quit;                                                                                                                       
                                                                                                                                
NOTE: There were 390000000 observations read from the data set SPDE.GB30.                                                       
NOTE: DATA statement used (Total process time):                                                                                 
      real time           46.17 seconds                                                                                         
      cpu time            46.20 seconds                                                                                         
                                                                                                                                
