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
