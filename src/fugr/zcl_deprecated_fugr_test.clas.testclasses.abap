CLASS ltcl_random DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS random_int_zero FOR TESTING RAISING cx_static_check.
    METHODS random_int_one FOR TESTING RAISING cx_static_check.
    METHODS random_int_six FOR TESTING RAISING cx_static_check.
    METHODS random_int_negative FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_random IMPLEMENTATION.

  METHOD random_int_zero.
* the span is RANGE + 1 values, so a range of zero has exactly one
    DATA lv_random TYPE i.

    CALL FUNCTION 'GENERAL_GET_RANDOM_INT'
      EXPORTING
        range  = 0
      IMPORTING
        random = lv_random.

    cl_abap_unit_assert=>assert_equals(
      act = lv_random
      exp = 0 ).
  ENDMETHOD.

  METHOD random_int_one.
* zero is a legal answer and the distinguishing one: a generator over
* 1..RANGE would never produce it. Two hundred draws of a fair coin land on
* each side at least once with a certainty no test needs to worry about.
    DATA lv_random TYPE i.
    DATA lv_zeroes TYPE i.
    DATA lv_ones   TYPE i.

    DO 200 TIMES.
      CALL FUNCTION 'GENERAL_GET_RANDOM_INT'
        EXPORTING
          range  = 1
        IMPORTING
          random = lv_random.
      CASE lv_random.
        WHEN 0.
          lv_zeroes = lv_zeroes + 1.
        WHEN 1.
          lv_ones = lv_ones + 1.
        WHEN OTHERS.
          cl_abap_unit_assert=>fail( msg = |out of range: { lv_random }| ).
      ENDCASE.
    ENDDO.

    cl_abap_unit_assert=>assert_differs(
      act = lv_zeroes
      exp = 0
      msg = 'zero must be reachable' ).
    cl_abap_unit_assert=>assert_differs(
      act = lv_ones
      exp = 0
      msg = 'the range itself must be reachable' ).
  ENDMETHOD.

  METHOD random_int_six.
    DATA lv_random TYPE i.

    DO 200 TIMES.
      CALL FUNCTION 'GENERAL_GET_RANDOM_INT'
        EXPORTING
          range  = 6
        IMPORTING
          random = lv_random.
      IF lv_random < 0 OR lv_random > 6.
        cl_abap_unit_assert=>fail( msg = |out of range: { lv_random }| ).
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD random_int_negative.
* a negative range is not an error: the span runs towards RANGE
    DATA lv_random TYPE i.

    DO 200 TIMES.
      CALL FUNCTION 'GENERAL_GET_RANDOM_INT'
        EXPORTING
          range  = -5
        IMPORTING
          random = lv_random.
      IF lv_random < -5 OR lv_random > 0.
        cl_abap_unit_assert=>fail( msg = |out of range: { lv_random }| ).
      ENDIF.
    ENDDO.
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_domvalues DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS with_text FOR TESTING RAISING cx_static_check.
    METHODS without_text FOR TESTING RAISING cx_static_check.
    METHODS other_language FOR TESTING RAISING cx_static_check.
    METHODS unknown_domain FOR TESTING RAISING cx_static_check.
    METHODS wrong_textflag FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_domvalues IMPLEMENTATION.

  METHOD with_text.
* ABAP_BOOLEAN from open-abap-core: space False, X True, maintained in English
    DATA lt_dd07v TYPE STANDARD TABLE OF dd07v WITH DEFAULT KEY.
    DATA ls_dd07v LIKE LINE OF lt_dd07v.
    DATA lv_rc    TYPE sy-subrc.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname   = 'ABAP_BOOLEAN'
        text      = abap_true
        langu     = 'E'
      IMPORTING
        rc        = lv_rc
      TABLES
        dd07v_tab = lt_dd07v.

    cl_abap_unit_assert=>assert_equals(
      act = lv_rc
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_dd07v )
      exp = 2 ).

    READ TABLE lt_dd07v INDEX 2 INTO ls_dd07v.
    cl_abap_unit_assert=>assert_equals(
      act = ls_dd07v-domname
      exp = 'ABAP_BOOLEAN' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_dd07v-valpos
      exp = '0002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_dd07v-domvalue_l
      exp = 'X' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_dd07v-ddlanguage
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_dd07v-ddtext
      exp = 'True' ).
  ENDMETHOD.

  METHOD without_text.
    DATA lt_dd07v TYPE STANDARD TABLE OF dd07v WITH DEFAULT KEY.
    DATA ls_dd07v LIKE LINE OF lt_dd07v.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname   = 'ABAP_BOOLEAN'
      TABLES
        dd07v_tab = lt_dd07v.

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_dd07v )
      exp = 2 ).
    LOOP AT lt_dd07v INTO ls_dd07v.
      cl_abap_unit_assert=>assert_initial( ls_dd07v-ddtext ).
      cl_abap_unit_assert=>assert_initial( ls_dd07v-ddlanguage ).
    ENDLOOP.
  ENDMETHOD.

  METHOD other_language.
* the values are there, the texts are not
    DATA lt_dd07v TYPE STANDARD TABLE OF dd07v WITH DEFAULT KEY.
    DATA ls_dd07v LIKE LINE OF lt_dd07v.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname   = 'ABAP_BOOLEAN'
        text      = abap_true
        langu     = 'D'
      TABLES
        dd07v_tab = lt_dd07v.

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_dd07v )
      exp = 2 ).
    READ TABLE lt_dd07v INDEX 2 INTO ls_dd07v.
    cl_abap_unit_assert=>assert_equals(
      act = ls_dd07v-domvalue_l
      exp = 'X' ).
    cl_abap_unit_assert=>assert_initial( ls_dd07v-ddtext ).
  ENDMETHOD.

  METHOD unknown_domain.
* the table is cleared before it is filled
    DATA lt_dd07v TYPE STANDARD TABLE OF dd07v WITH DEFAULT KEY.
    DATA ls_dd07v LIKE LINE OF lt_dd07v.
    DATA lv_rc    TYPE sy-subrc.

    APPEND ls_dd07v TO lt_dd07v.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname   = 'ZDOES_NOT_EXIST'
      IMPORTING
        rc        = lv_rc
      TABLES
        dd07v_tab = lt_dd07v.

    cl_abap_unit_assert=>assert_equals(
      act = lv_rc
      exp = 4 ).
    cl_abap_unit_assert=>assert_initial( lt_dd07v ).
  ENDMETHOD.

  METHOD wrong_textflag.
    DATA lt_dd07v TYPE STANDARD TABLE OF dd07v WITH DEFAULT KEY.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname        = 'ABAP_BOOLEAN'
        text           = 'Y'
      TABLES
        dd07v_tab      = lt_dd07v
      EXCEPTIONS
        wrong_textflag = 1
        OTHERS         = 2.

    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 1 ).
  ENDMETHOD.

ENDCLASS.
