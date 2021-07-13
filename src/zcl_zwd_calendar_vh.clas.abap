CLASS zcl_zwd_calendar_vh DEFINITION
  PUBLIC
  INHERITING FROM cl_wd_component_assistance
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA mo_event_data TYPE REF TO if_fpm_parameter .
    CLASS-DATA gv_wd_comp_id TYPE string READ-ONLY .
    CLASS-DATA go_wd_comp TYPE REF TO ziwci_wd_calendar_vh READ-ONLY .

    CLASS-METHODS class_constructor .
    METHODS on_ok
      IMPORTING
        !iv_low  TYPE datum
        !iv_high TYPE datum OPTIONAL .
    CLASS-METHODS fpm_date_popup
      IMPORTING
        !iv_callback_event_id TYPE fpm_event_id DEFAULT 'ZDATE_POPUP' .
    CLASS-METHODS fpm_date_range_popup
      IMPORTING
        !iv_callback_event_id TYPE fpm_event_id DEFAULT 'ZDATE_POPUP' .
    CLASS-METHODS wd_date_popup
      IMPORTING
        !iv_callback_action TYPE string
        !io_view            TYPE REF TO if_wd_view_controller .
    CLASS-METHODS wd_date_range_popup
      IMPORTING
        !iv_callback_action TYPE string
        !io_view            TYPE REF TO if_wd_view_controller .
    CLASS-METHODS open_popup
      IMPORTING
        !io_event_data TYPE REF TO if_fpm_parameter OPTIONAL .
    CLASS-METHODS fpm_set_vh_to_all
      IMPORTING
        !io_field_catalog      TYPE REF TO cl_abap_typedescr
      CHANGING
        !ct_field_descr_form   TYPE fpmgb_t_formfield_descr OPTIONAL
        !ct_field_descr_list   TYPE fpmgb_t_listfield_descr OPTIONAL
        !ct_field_descr_tree   TYPE fpmgb_t_treefield_descr OPTIONAL
        !ct_field_descr_search TYPE fpmgb_t_searchfield_descr OPTIONAL .
    CLASS-METHODS wd_set_vh_to_all
      IMPORTING
        !io_component TYPE REF TO if_wd_component
        !io_context   TYPE REF TO if_wd_context_node .
  PROTECTED SECTION.

    CLASS-METHODS wd_set_vh_recur
      IMPORTING
        !io_node_info TYPE REF TO if_wd_context_node_info .
    METHODS do_callback .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZWD_CALENDAR_VH IMPLEMENTATION.


  METHOD class_constructor.
    gv_wd_comp_id = CAST cl_abap_refdescr( cl_abap_typedescr=>describe_by_data( go_wd_comp ) )->get_referenced_type( )->get_relative_name( ).
    REPLACE 'IWCI_' IN gv_wd_comp_id WITH ''.
  ENDMETHOD.


  METHOD do_callback.
    DATA: lv_event_id TYPE fpm_event_id,
          lo_fpm      TYPE REF TO if_fpm,
          lo_event    TYPE REF TO cl_fpm_event,
          lt_key      TYPE TABLE OF string,
          lv_key      TYPE string,
          lr_value    TYPE REF TO data,
          lv_action   TYPE string,
          lo_view     TYPE REF TO cl_wdr_view,
          lo_action   TYPE REF TO if_wdr_action,
          lt_param    TYPE wdr_name_value_list,
          ls_param    TYPE wdr_name_value.


**********************************************************************
* FPM
**********************************************************************
    mo_event_data->get_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_EVENT_ID'
      IMPORTING
        ev_value = lv_event_id
    ).
    IF lv_event_id IS NOT INITIAL.

      lo_fpm = cl_fpm=>get_instance( ).
      CHECK: lo_fpm IS NOT INITIAL.

      lo_fpm->raise_event_by_id(
        EXPORTING
          iv_event_id   = lv_event_id   " This defines the ID of the FPM Event
          io_event_data = mo_event_data " Property Bag
      ).

    ENDIF.

**********************************************************************
* WD
**********************************************************************
    mo_event_data->get_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_ACTION'
      IMPORTING
        ev_value = lv_action
    ).
    IF lv_action IS NOT INITIAL.

      mo_event_data->get_value(
        EXPORTING
          iv_key   = 'IO_VIEW'
        IMPORTING
          ev_value = lo_view
      ).
      CHECK: lo_view IS NOT INITIAL.

      TRY.
          lo_action = lo_view->get_action_internal( lv_action ).
        CATCH cx_wdr_runtime INTO DATA(lx_wdr_runtime).
          wdr_task=>application->component->if_wd_controller~get_message_manager( )->report_error_message( lx_wdr_runtime->get_text( ) ).
      ENDTRY.
      CHECK: lo_action IS NOT INITIAL.

      CLEAR: ls_param.
      ls_param-name = 'MO_EVENT_DATA'.
      ls_param-object = mo_event_data.
      ls_param-type = cl_abap_typedescr=>typekind_oref.
      APPEND ls_param TO lt_param.

      lt_key = mo_event_data->get_keys( ).
      LOOP AT lt_key INTO lv_key.
        mo_event_data->get_value(
          EXPORTING
            iv_key   = lv_key
          IMPORTING
            er_value = lr_value
        ).
        CLEAR: ls_param.
        ls_param-name = lv_key.
        ls_param-dref = lr_value.
        ls_param-type = cl_abap_typedescr=>typekind_dref.
        APPEND ls_param TO lt_param.
      ENDLOOP.

      lo_action->set_parameters( lt_param ).
      lo_action->fire( ).

    ENDIF.
  ENDMETHOD.


  METHOD fpm_date_popup.
    DATA: lo_event_data TYPE REF TO if_fpm_parameter.

    CREATE OBJECT lo_event_data TYPE cl_fpm_parameter.

    lo_event_data->set_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_EVENT_ID'
        iv_value = iv_callback_event_id
    ).

    open_popup( lo_event_data ).
  ENDMETHOD.


  METHOD fpm_date_range_popup.
    DATA: lo_event_data TYPE REF TO if_fpm_parameter.

    CREATE OBJECT lo_event_data TYPE cl_fpm_parameter.

    lo_event_data->set_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_EVENT_ID'
        iv_value = iv_callback_event_id
    ).

    lo_event_data->set_value(
      EXPORTING
        iv_key   = 'IV_DATE_RANGE'
        iv_value = abap_true
    ).

    open_popup( lo_event_data ).
  ENDMETHOD.


  METHOD fpm_set_vh_to_all.
    DATA: lo_rtti               TYPE REF TO cl_abap_structdescr,
          lt_field_descr_form	  TYPE fpmgb_t_formfield_descr,
          lt_field_descr_list	  TYPE fpmgb_t_listfield_descr,
          lt_field_descr_tree	  TYPE fpmgb_t_treefield_descr,
          lt_field_descr_search	TYPE fpmgb_t_searchfield_descr.

    " rtti
    CASE io_field_catalog->type_kind.
      WHEN cl_abap_typedescr=>typekind_struct1
        OR cl_abap_typedescr=>typekind_struct2.
        lo_rtti ?= io_field_catalog.
      WHEN cl_abap_typedescr=>typekind_table.
        lo_rtti ?= CAST cl_abap_tabledescr( io_field_catalog )->get_table_line_type( ).
      WHEN OTHERS.
    ENDCASE.


    " loop comp
    LOOP AT lo_rtti->components INTO DATA(ls_comp) WHERE type_kind = cl_abap_typedescr=>typekind_date.
      IF ct_field_descr_form IS SUPPLIED.
        READ TABLE ct_field_descr_form ASSIGNING FIELD-SYMBOL(<ls_fd_form>) WITH KEY primary_key COMPONENTS name = ls_comp-name.
        IF sy-subrc EQ 0.
          <ls_fd_form>-wd_value_help = gv_wd_comp_id.
        ELSE.
          APPEND INITIAL LINE TO lt_field_descr_form ASSIGNING <ls_fd_form>.
          <ls_fd_form>-name = ls_comp-name.
          <ls_fd_form>-wd_value_help = gv_wd_comp_id.
        ENDIF.
      ENDIF.
      IF ct_field_descr_list IS SUPPLIED.
        READ TABLE ct_field_descr_list ASSIGNING FIELD-SYMBOL(<ls_fd_list>) WITH KEY primary_key COMPONENTS name = ls_comp-name.
        IF sy-subrc EQ 0.
          <ls_fd_list>-wd_value_help = gv_wd_comp_id.
        ELSE.
          APPEND INITIAL LINE TO lt_field_descr_list ASSIGNING <ls_fd_list>.
          <ls_fd_list>-name = ls_comp-name.
          <ls_fd_list>-wd_value_help = gv_wd_comp_id.
        ENDIF.
      ENDIF.
      IF ct_field_descr_tree IS SUPPLIED.
        READ TABLE ct_field_descr_tree ASSIGNING FIELD-SYMBOL(<ls_fd_tree>) WITH KEY primary_key COMPONENTS name = ls_comp-name.
        IF sy-subrc EQ 0.
          <ls_fd_tree>-wd_value_help = gv_wd_comp_id.
        ELSE.
          APPEND INITIAL LINE TO lt_field_descr_tree ASSIGNING <ls_fd_tree>.
          <ls_fd_tree>-name = ls_comp-name.
          <ls_fd_tree>-wd_value_help = gv_wd_comp_id.
        ENDIF.
      ENDIF.
      IF ct_field_descr_search IS SUPPLIED.
        READ TABLE ct_field_descr_search ASSIGNING FIELD-SYMBOL(<ls_fd_search>) WITH KEY primary_key COMPONENTS name = ls_comp-name.
        IF sy-subrc EQ 0.
          <ls_fd_search>-wd_value_help = gv_wd_comp_id.
        ELSE.
          APPEND INITIAL LINE TO lt_field_descr_search ASSIGNING <ls_fd_search>.
          <ls_fd_search>-name = ls_comp-name.
          <ls_fd_search>-wd_value_help = gv_wd_comp_id.
        ENDIF.
      ENDIF.
    ENDLOOP.


    " append
    IF lt_field_descr_form IS NOT INITIAL.
      APPEND LINES OF lt_field_descr_form TO ct_field_descr_form.
    ENDIF.
    IF lt_field_descr_list IS NOT INITIAL.
      APPEND LINES OF lt_field_descr_list TO ct_field_descr_list.
    ENDIF.
    IF lt_field_descr_tree IS NOT INITIAL.
      APPEND LINES OF lt_field_descr_tree TO ct_field_descr_tree.
    ENDIF.
    IF lt_field_descr_search IS NOT INITIAL.
      APPEND LINES OF lt_field_descr_search TO ct_field_descr_search.
    ENDIF.

  ENDMETHOD.


  METHOD on_ok.
    DATA: lv_date_range TYPE flag,
          lt_date_range TYPE date_t_range.


    mo_event_data->get_value(
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
      mo_event_data->set_value(
        EXPORTING
          iv_key   = 'IT_DATE_RANGE'
          iv_value = lt_date_range
      ).
    ELSE.
      mo_event_data->set_value(
        EXPORTING
          iv_key   = 'IV_DATE'
          iv_value = iv_low
      ).
    ENDIF.



    DATA: lt_callstack   TYPE abap_callstack,
          ls_callstack   TYPE abap_callstack_line,
          lo_class_desc  TYPE REF TO cl_abap_classdescr,
          ls_method_desc TYPE abap_methdescr,
          ls_param_desc  TYPE abap_parmdescr.
    FIELD-SYMBOLS: <lv_value> TYPE any.

    CALL FUNCTION 'SYSTEM_CALLSTACK'
      EXPORTING
        max_level = 1
      IMPORTING
        callstack = lt_callstack.
    READ TABLE lt_callstack INTO ls_callstack INDEX 1.
    lo_class_desc ?= cl_abap_classdescr=>describe_by_name( cl_oo_classname_service=>get_clsname_by_include( ls_callstack-include ) ).
    READ TABLE lo_class_desc->methods INTO ls_method_desc WITH KEY name = ls_callstack-blockname.
    LOOP AT ls_method_desc-parameters INTO ls_param_desc WHERE parm_kind = cl_abap_classdescr=>importing.
      ASSIGN (ls_param_desc-name) TO <lv_value>.
      mo_event_data->set_value(
        EXPORTING
          iv_key   = CONV #( ls_param_desc-name )
          iv_value = <lv_value>
      ).
    ENDLOOP.

    do_callback( ).

  ENDMETHOD.


  METHOD open_popup.
    DATA: lo_comp_usage TYPE REF TO if_wd_component_usage.

    IF go_wd_comp IS INITIAL.
      cl_wdr_runtime_services=>get_component_usage(
        EXPORTING
          component            = wdr_task=>application->component
          used_component_name  = gv_wd_comp_id
          component_usage_name = gv_wd_comp_id
          create_component     = abap_true
          do_create            = abap_true
        RECEIVING
          component_usage      = lo_comp_usage
      ).
      go_wd_comp ?= lo_comp_usage->get_interface_controller( ).
    ENDIF.

    go_wd_comp->open_popup(
        io_event_data = io_event_data
    ).
  ENDMETHOD.


  METHOD wd_date_popup.
    DATA: lo_event_data TYPE REF TO if_fpm_parameter.

    CREATE OBJECT lo_event_data TYPE cl_fpm_parameter.

    lo_event_data->set_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_ACTION'
        iv_value = iv_callback_action
    ).

    lo_event_data->set_value(
      EXPORTING
        iv_key   = 'IO_VIEW'
        iv_value = CAST cl_wdr_view( io_view )
    ).

    open_popup( lo_event_data ).
  ENDMETHOD.


  METHOD wd_date_range_popup.
    DATA: lo_event_data TYPE REF TO if_fpm_parameter.

    CREATE OBJECT lo_event_data TYPE cl_fpm_parameter.

    lo_event_data->set_value(
      EXPORTING
        iv_key   = 'IV_CALLBACK_ACTION'
        iv_value = iv_callback_action
    ).

    lo_event_data->set_value(
      EXPORTING
        iv_key   = 'IO_VIEW'
        iv_value = CAST cl_wdr_view( io_view )
    ).

    lo_event_data->set_value(
      EXPORTING
        iv_key   = 'IV_DATE_RANGE'
        iv_value = abap_true
    ).

    open_popup( lo_event_data ).
  ENDMETHOD.


  METHOD wd_set_vh_recur.
    DATA: lt_attr_info       TYPE wdr_context_attr_info_map,
          ls_attr_info       TYPE wdr_context_attribute_info,
          lt_child_node_info TYPE wdr_context_child_info_map,
          ls_child_node_info TYPE wdr_context_child_info.

    lt_attr_info = io_node_info->get_attributes( ).
    LOOP AT lt_attr_info INTO ls_attr_info.
      IF ls_attr_info-rtti->type_kind EQ cl_abap_typedescr=>typekind_date AND
         ls_attr_info-value_help_mode EQ if_wd_context_node_info=>c_value_help_mode-automatic.
        io_node_info->set_attribute_value_help(
          EXPORTING
            name            = ls_attr_info-name
            value_help_mode = if_wd_context_node_info=>c_value_help_mode-application_defined
            value_help      = gv_wd_comp_id
        ).
      ENDIF.
    ENDLOOP.

    lt_child_node_info = io_node_info->get_child_nodes( ).
    LOOP AT lt_child_node_info INTO ls_child_node_info.
      wd_set_vh_recur( ls_child_node_info-node_info ).
    ENDLOOP.
  ENDMETHOD.


  METHOD wd_set_vh_to_all.
    DATA: lo_node_info TYPE REF TO if_wd_context_node_info,
          lt_attr_info TYPE wdr_context_attr_info_map,
          ls_attr_info TYPE wdr_context_attribute_info.

    " regist comp usage
    cl_wdr_runtime_services=>get_component_usage(
      EXPORTING
        component            = io_component
        used_component_name  = gv_wd_comp_id
        component_usage_name = gv_wd_comp_id
        create_component     = abap_true
        do_create            = abap_true
    ).

    " set value help
*    wd_context->get_node_info( )->set_attribute_value_help(
*      EXPORTING
*        name            = 'DATE'
*        value_help_mode = if_wd_context_node_info=>c_value_help_mode-application_defined
*        value_help      = gv_wd_comp_id
*    ).
    wd_set_vh_recur( io_node_info = io_context->get_node_info( ) ).
  ENDMETHOD.
ENDCLASS.
