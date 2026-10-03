FUNCTION dd_domvalues_get.

* The fixed values of domain DOMNAME, in DD07V_TAB, with texts in LANGU when
* TEXT is set. A LANGU of space means the logon language.
*
* The runtime does not carry domains on their own: the transpiler copies a
* domain's fixed values onto every data element that refers to it, so the
* values are found through the first data element with DOMNAME as its domain.
* A domain that no data element refers to has no values here. Only the texts
* of the original language reach the runtime, translations do not, so a text
* in any other language is left empty, as it is for a value without a text.
*
* VALPOS counts the values in the order the domain lists them. DOMVAL_LD,
* DOMVAL_HD and APPVAL stay empty. RC is 4 when the domain has no values.
* BYPASS_BUFFER has no meaning here, there is no buffer.

  DATA ls_dd07v      LIKE LINE OF dd07v_tab.
  DATA lv_langu      TYPE sy-langu.
  DATA lv_text_langu TYPE sy-langu.
  DATA lv_text       TYPE dd07v-ddtext.

  CLEAR dd07v_tab[].
  CLEAR rc.

  IF text <> abap_true AND text <> space.
    RAISE wrong_textflag.
  ENDIF.

  lv_langu = langu.
  IF lv_langu IS INITIAL.
    lv_langu = sy-langu.
  ENDIF.

  WRITE '@KERNEL const name = domname.get().trim().toUpperCase();'.
  WRITE '@KERNEL const dtel = Object.values(abap.DDIC).find(d => d.objectType === "DTEL" && d.domain?.toUpperCase() === name);'.
  WRITE '@KERNEL for (const f of dtel?.fixedValues || []) {'.
  CLEAR ls_dd07v.
  ls_dd07v-domname = domname.
  ls_dd07v-valpos = lines( dd07v_tab ) + 1.
  WRITE '@KERNEL   ls_dd07v.get().domvalue_l.set(f.low || "");'.
  WRITE '@KERNEL   ls_dd07v.get().domvalue_h.set(f.high || "");'.
  WRITE '@KERNEL   lv_text_langu.set(f.language || "");'.
  WRITE '@KERNEL   lv_text.set(f.description || "");'.
  IF text = abap_true AND lv_text_langu = lv_langu.
    ls_dd07v-ddlanguage = lv_langu.
    ls_dd07v-ddtext = lv_text.
  ENDIF.
  APPEND ls_dd07v TO dd07v_tab.
  WRITE '@KERNEL }'.

  IF lines( dd07v_tab ) = 0.
    rc = 4.
  ENDIF.

ENDFUNCTION.
