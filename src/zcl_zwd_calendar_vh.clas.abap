class ZCL_ZWD_CALENDAR_VH definition
  public
  inheriting from CL_WD_COMPONENT_ASSISTANCE
  create public .

public section.

  data MO_PARAM type ref to IF_FPM_PARAMETER .

  methods ON_OK
    importing
      !IV_LOW type DATUM
      !IV_HIGH type DATUM optional .
  class-methods FPM_DATE_POPUP
    importing
      !IV_CALLBACK_EVENT_ID type FPM_EVENT_ID default 'ZDATE_POPUP' .
  class-methods FPM_DATE_RANGE_POPUP
    importing
      !IV_CALLBACK_EVENT_ID type FPM_EVENT_ID default 'ZDATE_POPUP' .
  class-methods WD_DATE_POPUP
    importing
      !IV_CALLBACK_ACTION type STRING
      !IO_VIEW type ref to IF_WD_VIEW_CONTROLLER .
  class-methods WD_DATE_RANGE_POPUP
    importing
      !IV_CALLBACK_ACTION type STRING
      !IO_VIEW type ref to IF_WD_VIEW_CONTROLLER .
  class-methods OPEN_POPUP
    importing
      !IO_PARAM type ref to IF_FPM_PARAMETER optional .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZWD_CALENDAR_VH IMPLEMENTATION.


  METHOD fpm_date_popup.
    DATA: lo_param TYPE REF TO if_fpm_parameter.

    CREATE OBJECT lo_param TYPE cl_fpm_parameter.

    lo_param->set_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_EVENT_ID'
        iv_value = iv_callback_event_id
    ).

    open_popup( lo_param ).
  ENDMETHOD.


  METHOD fpm_date_range_popup.
    DATA: lo_param TYPE REF TO if_fpm_parameter.

    CREATE OBJECT lo_param TYPE cl_fpm_parameter.

    lo_param->set_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_EVENT_ID'
        iv_value = iv_callback_event_id
    ).

    lo_param->set_value(
      EXPORTING
        iv_key   = 'IV_DATE_RANGE'
        iv_value = abap_true
    ).

    open_popup( lo_param ).
  ENDMETHOD.


  METHOD on_ok.
    DATA: lv_event_id   TYPE fpm_event_id,
          lo_fpm        TYPE REF TO if_fpm,
          lo_event      TYPE REF TO cl_fpm_event,
          lv_action     TYPE string,
          lo_view       TYPE REF TO cl_wdr_view,
          lo_action     TYPE REF TO if_wdr_action,
          lt_param      TYPE wdr_name_value_list,
          lv_date_range TYPE flag,
          lt_date_range TYPE date_t_range.

    mo_param->get_value(
      EXPORTING
        iv_key   = 'IV_DATE_RANGE'
      IMPORTING
        ev_value = lv_date_range
    ).
    IF lv_date_range EQ abap_true.
      IF iv_low EQ iv_high.
        lt_date_range = VALUE #( ( sign = 'I' option = 'EQ' low = iv_low ) ).
      ELSE.
        lt_date_range = VALUE #( ( sign = 'I' option = 'BT' low = iv_low high = iv_high ) ).
      ENDIF.
    ENDIF.

**********************************************************************
* FPM
**********************************************************************
    mo_param->get_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_EVENT_ID'
      IMPORTING
        ev_value = lv_event_id
    ).
    IF lv_event_id IS NOT INITIAL.

      lo_fpm = cl_fpm=>get_instance( ).
      CHECK: lo_fpm IS NOT INITIAL.

      CREATE OBJECT lo_event
        EXPORTING
          iv_event_id = lv_event_id         " This defines the ID of the FPM Event
*         iv_is_validating    = iv_is_validating    " Defines, whether checks need to be performed or not
*         iv_is_transactional = iv_is_transactional " Defines, whether IF_FPM_TRANSACTION is to be processed
*         iv_adapts_context   = iv_adapts_context   " Event changes the adaptation context
*         iv_framework_event  = iv_framework_event  " Event is raised by FPM and not by user or appl. code
*         is_source_uibb      = is_source_uibb      " Source UIBB of Event
*         io_event_data       = io_event_data       " Data for processing
        .

      IF lv_date_range EQ abap_true.
        lo_event->mo_event_data->set_value(
          EXPORTING
            iv_key   = 'IT_DATE_RANGE'
            iv_value = lt_date_range
        ).
      ELSE.
        lo_event->mo_event_data->set_value(
          EXPORTING
            iv_key   = 'IV_DATE'
            iv_value = iv_low
        ).
      ENDIF.

      lo_fpm->raise_event( lo_event ).

    ENDIF.

**********************************************************************
* WD
**********************************************************************
    mo_param->get_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_ACTION'
      IMPORTING
        ev_value = lv_action
    ).
    IF lv_action IS NOT INITIAL.

      mo_param->get_value(
        EXPORTING
          iv_key   = 'IO_VIEW'
        IMPORTING
          ev_value = lo_view
      ).
      CHECK: lo_view IS NOT INITIAL.

      TRY.
          lo_action = lo_view->get_action_internal( lv_action ).
        CATCH cx_wdr_runtime INTO DATA(lx_wdr_runtime).
          zcl_abap2xlsx_helper=>message( lx_wdr_runtime->get_text( ) ).
      ENDTRY.
      CHECK: lo_action IS NOT INITIAL.


      IF lv_date_range EQ abap_true.
        lo_action->set_name( 'IT_DATE_RANGE' ).
        lt_param = VALUE #(
          ( name = 'IT_DATE_RANGE' dref = REF #( lt_date_range ) type = 'l' )
        ).
      ELSE.
        lo_action->set_name( 'IV_DATE' ).
        lt_param = VALUE #(
          ( name = 'IV_DATE' dref = REF #( iv_low ) type = 'l' )
        ).
      ENDIF.
      lo_action->set_parameters( lt_param ).
      lo_action->fire( ).


    ENDIF.

  ENDMETHOD.


  METHOD OPEN_POPUP.
    DATA: lo_comp_usage TYPE REF TO if_wd_component_usage,
          lo_wd_comp    TYPE REF TO ziwci_wd_calendar_vh.

    cl_wdr_runtime_services=>get_component_usage(
      EXPORTING
        component            = wdr_task=>application->component
        used_component_name  = 'ZWD_CALENDAR_VH'
        component_usage_name = 'ZWD_CALENDAR_VH'
        create_component     = abap_true
        do_create            = abap_true
      RECEIVING
        component_usage      = lo_comp_usage
    ).

    lo_wd_comp ?= lo_comp_usage->get_interface_controller( ).
    lo_wd_comp->open_popup(
        io_param = io_param
    ).
  ENDMETHOD.


  METHOD WD_DATE_POPUP.
    DATA: lo_param TYPE REF TO if_fpm_parameter.

    CREATE OBJECT lo_param TYPE cl_fpm_parameter.

    lo_param->set_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_ACTION'
        iv_value = iv_callback_action
    ).

    lo_param->set_value(
      EXPORTING
        iv_key   = 'IO_VIEW'
        iv_value = CAST cl_wdr_view( io_view )
    ).

    open_popup( lo_param ).
  ENDMETHOD.


  METHOD wd_date_range_popup.
    DATA: lo_param TYPE REF TO if_fpm_parameter.

    CREATE OBJECT lo_param TYPE cl_fpm_parameter.

    lo_param->set_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_ACTION'
        iv_value = iv_callback_action
    ).

    lo_param->set_value(
      EXPORTING
        iv_key   = 'IO_VIEW'
        iv_value = CAST cl_wdr_view( io_view )
    ).

    lo_param->set_value(
      EXPORTING
        iv_key   = 'IV_DATE_RANGE'
        iv_value = abap_true
    ).

    open_popup( lo_param ).
  ENDMETHOD.
ENDCLASS.
