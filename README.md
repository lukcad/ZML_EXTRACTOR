# ZML_EXTRACTOR
Example of very old approach for extracting data by SAP extractor RSA3 with example and with absolutely foolish code but idea to let you understand how it is working and you can easily change it for your own needs as it is required.

Happy programming!

Yours sincirely,

Mikhail.

## way to create such simple extractor

1-- create package `ZML_EXTRACTOR`

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/2c4bbb86-90b2-4087-b0ae-08305a434168)

2-- create structure which is required for customer

    	@EndUserText.label : 'ZML_TEST_STRUCT'
    	@AbapCatalog.enhancementCategory : #NOT_EXTENSIBLE
    	define structure zml_test_struct {
    	  product_id      : /bobf/epm_product_id;
    	  type_code       : snwd_product_type_code;
    	  category        : snwd_product_category;
    	  product_pic_url : snwd_product_pic_url;
    	  supplier_id     : /bobf/epm_bp_id;
    	  measure_unit    : snwd_quantity_unit;
    	  @Semantics.quantity.unitOfMeasure : '/bobf/s_epm_product_root_d.weight_unit'
    	  weight_measure  : snwd_weight_measure;
    	  weight_unit     : snwd_quantity_unit;
    	  admin_data      : include /bobf/s_lib_admin_data;
    	
    }

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/1d7624b9-65a2-4f78-891a-e37896f2981c)

3-- Create ABAP Function group `ZML_EXTRACTOR_FUNC`

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/9d7777d1-ed2e-449d-b86b-784643eac65d)


4-- Create interface ABAP Function Module `ZML_EXT_TEST` 

	Notice: parameters for extractor if it is for BW are the same, difference only is  a type of E_T_DATA

    	FUNCTION ZML_EXT_TEST
    	  IMPORTING
    	    I_REQUNR TYPE SBIWA_S_INTERFACE-REQUNR
    	    I_DSOURCE TYPE SBIWA_S_INTERFACE-ISOURCE
    	    I_MAXSIZE TYPE SBIWA_S_INTERFACE-MAXSIZE
    	    I_INITFLAG TYPE SBIWA_S_INTERFACE-INITFLAG
    	  TABLES
    	    I_T_SELECT TYPE SBIWA_T_SELECT OPTIONAL
    	    I_T_FIELDS TYPE SBIWA_T_FIELDS OPTIONAL
    	    E_T_DATA TYPE ZML_TEST_STRUCT OPTIONAL
    	  EXCEPTIONS
    	    NO_MORE_DATA
    	    ERROR_PASSED_TO_MESS_HANDLER.
    	
    	
    	
    ENDFUNCTION.

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/13dbf08d-5101-4826-b76e-c52e486cea6f)

5-- Create Application component `ZMLAPPS` by RSA6

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/e00db546-a441-4f9f-851f-ed9b6f3d16a3)


6-- Create datasource `ZML_DS_TEST` using RSO2 transaction

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/d5e2a80f-e405-4adb-b896-2841d5e5966c)

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/067b5f0e-20f8-4b20-9ed0-10e5a457860b)

Choose required selection fields in datasource:

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/2dc5aaa2-2dbe-4ad0-8727-bd18d8aa7d2a)

7-- Create implementation of ABAP FM `ZML_EXTRACTOR_FUNC`

This is simple example of implementation and it can't be considered as the best practice, just for understanding how extractor can be created and let you test this extractor using the next steps.


      		FUNCTION zml_ext_test
      		  IMPORTING
      		    i_requnr TYPE sbiwa_s_interface-requnr
      		    i_dsource TYPE sbiwa_s_interface-isource
      		    i_maxsize TYPE sbiwa_s_interface-maxsize
      		    i_initflag TYPE sbiwa_s_interface-initflag
      		  TABLES
      		    i_t_select TYPE sbiwa_t_select OPTIONAL
      		    i_t_fields TYPE sbiwa_t_fields OPTIONAL
      		    e_t_data TYPE zml_test_struct OPTIONAL
      		  EXCEPTIONS
      		    no_more_data
      		    error_passed_to_mess_handler.
      		
      		
      		
      		* Structure for request parameters
      		  STATICS: s_s_if TYPE srsc_s_if_simple.
      		
      		* Statics variables counter and table for storage data between  calls
      		  STATICS: s_counter_datapakid LIKE sy-tabix,
      		           t_data_temp         LIKE /bobf/d_pr_root OCCURS 0 WITH HEADER LINE,
      		           tab                 TYPE /bobf/d_pr_root OCCURS 0.
      		
      		* Ranges for  selections
      		  RANGES: l_r_category  FOR /bobf/d_pr_root-category,
      		          l_r_type_code FOR /bobf/d_pr_root-type_code.
      		
      		  DATA: l_s_select  LIKE i_t_select,
      		        idx         LIKE sy-tabix,
      		        wa_E_T_DATA LIKE e_t_data,
      		        n           TYPE i,
      		        category    TYPE snwd_product_category.
      		
      		* >>>>>>>>>> 1. Initialization and identifying restrictions
      		  IF i_initflag = 'X'.
      		    CLEAR s_counter_datapakid.
      		
      		* Check DataSource validity
      		    CASE i_dsource.
      		      WHEN 'ZML_DS_TEST'.
      		      WHEN OTHERS.
      		        RAISE error_passed_to_mess_handler.
      		    ENDCASE.
      		  ELSE.
      		
      		* >> Read data only in first call
      		    IF s_counter_datapakid = 0.
      		
      		* >>>>>> Select data
      		      LOOP AT i_t_select INTO l_s_select
      		                  WHERE fieldnm = 'CATEGORY'.
      		        MOVE-CORRESPONDING l_s_select TO l_r_category.
      		        APPEND l_r_category.
      		      ENDLOOP.
      		
      		      LOOP AT i_t_select INTO l_s_select
      		                  WHERE fieldnm = 'TYPE_CODE'.
      		        MOVE-CORRESPONDING l_s_select TO l_r_type_code.
      		        APPEND l_r_type_code.
      		      ENDLOOP.
      		
      		* <<<<<< Select data
      		*>>>>> 2.Operations with selected data  restrictions
      		* From table select  data according restrictions to the table  (L_R_CATEGORY and L_R_TYPE_CODE)
      		
      		      SELECT * INTO CORRESPONDING FIELDS OF TABLE tab FROM /bobf/d_pr_root WHERE category IN l_r_category AND type_code IN l_r_type_code.
      		
      		    ENDIF.
      		
      		*<<<  IF S_COUNTER_DATAPAKID = 0.
      		*<<<<< 2. Operations with selected data  restrictions
      		*>>>>> 3. Data processing
      		* Refresh table between calls
      		
      		    REFRESH e_t_data.
      		
      		    DO i_maxsize TIMES. " reading in the amount of max size of records
      		      idx = s_counter_datapakid * i_maxsize + sy-index. " set index to the untreated record in table
      		      READ TABLE tab INTO t_data_temp INDEX idx. " read record from table to the hader line
      		      IF sy-subrc <> 0. " index NOT table - exit!
      		        EXIT.
      		      ELSE.
      		        wa_E_T_DATA-category = t_data_temp-category.
      		        wa_E_T_DATA-type_code = t_data_temp-type_code.
      		        wa_E_T_DATA-product_id  = t_data_temp-product_id.
      		        wa_E_T_DATA-product_pic_url  = t_data_temp-product_pic_url.
      		        wa_E_T_DATA-supplier_id  = t_data_temp-supplier_id.
      		        wa_E_T_DATA-measure_unit  = t_data_temp-measure_unit.
      		        wa_E_T_DATA-weight_measure  = t_data_temp-weight_measure.
      		        wa_E_T_DATA-weight_unit  = t_data_temp-weight_unit.
      		        wa_E_T_DATA-crea_date_time  = t_data_temp-crea_date_time.
      		        wa_E_T_DATA-crea_uname  = t_data_temp-crea_uname.
      		        wa_E_T_DATA-lchg_date_time  = t_data_temp-lchg_date_time.
      		        wa_E_T_DATA-lchg_uname  = t_data_temp-lchg_uname.
      		        APPEND wa_E_T_DATA TO e_t_data.
      		
      		      ENDIF.
      		    ENDDO.
      		    DESCRIBE TABLE e_t_data LINES n. " Count records in out table. If n = 0 - NO MORE DATA!
      		    IF sy-subrc <> 0 AND n = 0.
      		      RAISE no_more_data.
      		    ENDIF.
      		
      		* Increase the counter before next call
      		    s_counter_datapakid = s_counter_datapakid + 1.
      		
      		  ENDIF.
      		
      ENDFUNCTION.

save this code and activate FM.

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/84e44676-04b9-49df-8513-290d2acc8c8a)


8-- Test extractor using RSA3 transaction

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/36c8beb3-b3ee-4276-9b21-f647014baf52)

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/846db929-6784-433a-a2ca-b0c59b99d0aa)

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/1f169701-5876-4220-aca1-214a6211eccb)

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/877e5a47-139c-48f0-bab5-2f787275d9d6)

Change selection and test extraction of particular data.

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/4180750e-fd05-40fc-935e-f002f243ef5b)

![image](https://github.com/lukcad/ZML_EXTRACTOR/assets/22641302/cf7926d3-d083-4f2a-891f-f84ebe3fc5d8)







