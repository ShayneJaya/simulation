CREATE OR REPLACE EDITIONABLE PROCEDURE  "SIMID_FULL_ORDER" as

   l_context     apex_exec.t_context;
   l_parameters  apex_exec.t_parameters;
   
   l_gainsum             pls_integer;
   l_currentearn         pls_integer;
   l_simulationtype      pls_integer; 
   l_simulationid        pls_integer; 
   l_homecurrencycode    pls_integer; 
begin
-APEX_DEBUG.ENABL(apex_debug.c_log_level_info);  --  APEX Debug
apex_debug.message(p_message => 'Participant ID = ' || v('P21_PARTICIPANT_ID'));
apex_exec.add_parameter (
      p_parameters => l_parameters,
      p_name       => 'CREDITAMOUNTQ4', --POST Request Variable
      p_value      => v('P21_CREDITAMOUNT_ORDER_Q4')); -- Page Item Credit Amount

    apex_exec.add_parameter( l_parameters, 'Q1_DATE',  v('P21_DATE_Q1'));
    apex_exec.add_parameter( l_parameters, 'Q2_DATE',  v('P21_DATE_Q2'));
    apex_exec.add_parameter( l_parameters, 'Q3_DATE',  v('P21_DATE_Q3'));
    apex_exec.add_parameter( l_parameters, 'Q4_DATE',  v('P21_DATE_Q4'));
    apex_exec.add_parameter( l_parameters, 'CREDITAMOUNTQ1',  v('P21_CREDITAMOUNT_ORDER_Q1'));
    apex_exec.add_parameter( l_parameters, 'CREDITAMOUNTQ2',  v('P21_CREDITAMOUNT_ORDER_Q2'));
    apex_exec.add_parameter( l_parameters, 'CREDITAMOUNTQ3',  v('P21_CREDITAMOUNT_ORDER_Q3')); 
    apex_exec.add_parameter( l_parameters, 'PARTICIPANTID',  v('P21_PARTICIPANT_ID'));
   -- Open Web Source
   l_context := apex_exec.open_web_source_query (
      p_module_static_id => 'Order1_All_Quarters',
      p_parameters       => l_parameters);
      
   l_gainsum := apex_exec.get_column_position (l_context, 'GAINSUMCALCULATION');
   l_currentearn := apex_exec.get_column_position (l_context, 'CURRENTEARNINGSSUMCALCULATION');
   l_simulationtype := apex_exec.get_column_position (l_context, 'SIMULATIONTYPE');
   l_simulationid := apex_exec.get_column_position (l_context, 'SIMULATIONID');
   l_homecurrencycode := apex_exec.get_column_position (l_context, 'HOMECURRENCYCODE');

   while apex_exec.next_row (l_context) loop
   apex_debug.message(p_message => 'Next Itteration for below:');
      if apex_exec.get_varchar2 (l_context, l_gainsum) is null or 
         apex_exec.get_varchar2 (l_context, l_currentearn) is null then
        APEX_UTIL.SET_SESSION_STATE( 'P21_GAINSUMCALCULATION', null );
        APEX_UTIL.SET_SESSION_STATE( 'P21_CURRENTEARNINGSSUMCALCULATION', null );
        APEX_UTIL.SET_SESSION_STATE( 'P21_SIMULATIONID', apex_exec.get_varchar2 (l_context,l_simulationid) );
    
      else
        APEX_UTIL.SET_SESSION_STATE('P21_GAINSUMCALCULATION', TO_CHAR(apex_exec.get_varchar2 (l_context, l_gainsum),'fmL99G999G999D00')  ); -- TO_CHAR(12345, 'fmL99G999D00')
        APEX_UTIL.SET_SESSION_STATE('P21_SIMULATIONTYPE', apex_exec.get_varchar2 (l_context,l_simulationtype)  );
        APEX_UTIL.SET_SESSION_STATE('P21_SIMULATIONID', apex_exec.get_varchar2 (l_context,l_simulationid) );
        APEX_UTIL.SET_SESSION_STATE('P21_HOMECURRENCYCODE', apex_exec.get_varchar2 (l_context,l_homecurrencycode)  ); 
      end if;
      
   end loop;
   
   -- Close Web Source
   apex_exec.close (l_context);
exception
   when others then
      -- Close Web Source
      apex_exec.close (l_context);
end;
/









