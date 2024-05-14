FUNCTION zml_ext_test.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_REQUNR) TYPE  SBIWA_S_INTERFACE-REQUNR
*"     REFERENCE(I_DSOURCE) TYPE  SBIWA_S_INTERFACE-ISOURCE
*"     REFERENCE(I_MAXSIZE) TYPE  SBIWA_S_INTERFACE-MAXSIZE
*"     REFERENCE(I_INITFLAG) TYPE  SBIWA_S_INTERFACE-INITFLAG
*"  TABLES
*"      I_T_SELECT TYPE  SBIWA_T_SELECT OPTIONAL
*"      I_T_FIELDS TYPE  SBIWA_T_FIELDS OPTIONAL
*"      E_T_DATA STRUCTURE  ZML_TEST_STRUCT OPTIONAL
*"  EXCEPTIONS
*"      NO_MORE_DATA
*"      ERROR_PASSED_TO_MESS_HANDLER
*"----------------------------------------------------------------------
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
