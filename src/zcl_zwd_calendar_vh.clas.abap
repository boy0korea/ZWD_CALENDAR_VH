class ZCL_ZWD_CALENDAR_VH definition
  public
  inheriting from CL_WD_COMPONENT_ASSISTANCE
  create public .

public section.

  data MO_PARAM type ref to IF_FPM_PARAMETER .
  class-data GV_WD_COMP_ID type STRING read-only .
  class-data GO_WD_COMP type ref to ZIWCI_WD_CALENDAR_VH read-only .

  class-methods CLASS_CONSTRUCTOR .
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
  class-methods FPM_SET_VH_TO_ALL
    importing
      !IO_FIELD_CATALOG type ref to CL_ABAP_TYPEDESCR
    changing
      !CT_FIELD_DESCR_FORM type FPMGB_T_FORMFIELD_DESCR optional
      !CT_FIELD_DESCR_LIST type FPMGB_T_LISTFIELD_DESCR optional
      !CT_FIELD_DESCR_TREE type FPMGB_T_TREEFIELD_DESCR optional
      !CT_FIELD_DESCR_SEARCH type FPMGB_T_SEARCHFIELD_DESCR optional .
  class-methods WD_SET_VH_TO_ALL
    importing
      !IO_COMPONENT type ref to IF_WD_COMPONENT
      !IO_CONTEXT type ref to IF_WD_CONTEXT_NODE .
  PROTECTED SECTION.

    CLASS-METHODS wd_set_vh_recur
      IMPORTING
        !io_node_info TYPE REF TO if_wd_context_node_info .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZWD_CALENDAR_VH IMPLEMENTATION.


  METHOD class_constructor.
    gv_wd_comp_id = CAST cl_abap_refdescr( cl_abap_typedescr=>describe_by_data( go_wd_comp ) )->get_referenced_type( )->get_relative_name( ).
    REPLACE 'IWCI_' IN gv_wd_comp_id WITH ''.
  ENDMETHOD.


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


  METHOD FPM_SET_VH_TO_ALL.
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
        io_param = io_param
    ).
  ENDMETHOD.


  METHOD wd_date_popup.
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
