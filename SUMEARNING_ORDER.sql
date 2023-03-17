CREATE OR REPLACE EDITIONABLE PROCEDURE  "SUMEARNING_ORDER" as

    l_context     apex_exec.t_context;
    l_parameters  apex_exec.t_parameters;
   
    l_homeearningamt      pls_integer;
    l_output              pls_integer;
    l_payperiodid         pls_integer;
    l_simid               pls_integer;
    l_plancomponentname   pls_integer;
    l_simtype             pls_integer;
    l_credits             pls_integer;

    l_quarter_Q1            pls_integer; --  Order = Quartly Payout
    l_quarter_Q2            pls_integer;
    l_quarter_Q3            pls_integer;
    l_quarter_Q4            pls_integer;

    l_YTD_Q1            pls_integer;  -- Output = YTD Payout
    l_YTD_Q2            pls_integer;
    l_YTD_Q3            pls_integer;
    l_YTD_Q4            pls_integer;

    l_previoud_payout_q3    pls_integer;
begin
    -APEX_DEBUG.ENABL(apex_debug.c_log_level_info);  --  APEX Debug 
    apex_exec.add_parameter (
      p_parameters => l_parameters,
      p_name       => 'SimulationId',
      p_value      => v('P21_SIMULATIONID') ); 
   
   -- Open Web Source
   l_context := apex_exec.open_web_source_query (
      p_module_static_id => 'GetSimulationId_ORDER', 
      p_parameters       => l_parameters);
      
   
     while apex_exec.next_row (l_context) loop
 
       apex_debug.message(p_message => '---------BEGIN NEXT LOOP---------');
            l_homeearningamt := apex_exec.get_column_position (l_context, 'HOMEEARNINGAMOUNT');
            l_output := apex_exec.get_column_position (l_context, 'OUTPUTACHIEVED');
            l_payperiodid := apex_exec.get_column_position (l_context, 'PAYPERIODID');
            l_simtype := apex_exec.get_column_position (l_context, 'SIMULATIONRESULTTYPE');
            l_plancomponentname := apex_exec.get_column_position (l_context, 'PLANCOMPONENTNAME');
            l_simid := apex_exec.get_column_position (l_context, 'SIMULATIONID');
            l_credits := apex_exec.get_column_position (l_context, 'CREDITAMOUNT');

        if apex_exec.get_varchar2 (l_context, l_homeearningamt) is null then 
            APEX_UTIL.SET_SESSION_STATE('P21_ORDERS_Q1', null);
           apex_debug.message(p_message => 'Home Earning Amount Returned NULL');
        else 
            APEX_UTIL.SET_SESSION_STATE('P21_SIMULATIONID_RETURN',   apex_exec.get_varchar2 (l_context, l_simid) ); /*Place holder to return simulation ID is working */
            
            if apex_exec.get_varchar2 (l_context, l_plancomponentname) = 'Order 1' and apex_exec.get_varchar2 (l_context, l_simtype) = 'SIMULATION' then 
               

                if apex_exec.get_varchar2 (l_context, l_payperiodid) = v('P21_FY')|| '001' then ---QUARTER 1
                  
                    l_quarter_Q1 := apex_exec.get_varchar2 (l_context, l_homeearningamt); --FML999G999G999G999G990D00
                    l_YTD_Q1 :=apex_exec.get_varchar2 (l_context, l_output);
                    APEX_UTIL.SET_SESSION_STATE('P21_ORDERS_Q1', l_quarter_q1 ); --TO_CHAR(l_quarter_q1,'FML999G999G999G999G999D00')  ); 
                    APEX_UTIL.SET_SESSION_STATE('P21_CREDIT_ORDER_Q1', apex_exec.get_varchar2 (l_context, l_credits) ); 
                    APEX_UTIL.SET_SESSION_STATE('P21_OUTPUTACHIEVED_Q1', l_YTD_Q1  ); 


                elsif apex_exec.get_varchar2 (l_context, l_payperiodid) = v('P21_FY')|| '002' then  --QUARTER 2
                  
                    l_YTD_Q2 := apex_exec.get_varchar2 (l_context, l_output);
                    l_quarter_Q2 := l_YTD_Q2 - l_quarter_Q1;
                   
                    if l_quarter_Q2 < 0 then
                        APEX_UTIL.SET_SESSION_STATE('P21_ORDERS_Q2',  0   );
                    else
                        APEX_UTIL.SET_SESSION_STATE('P21_ORDERS_Q2',  l_quarter_Q2   );
                    end if;
                    APEX_UTIL.SET_SESSION_STATE('P21_CREDIT_ORDER_Q2', apex_exec.get_varchar2 (l_context, l_credits) );
                    APEX_UTIL.SET_SESSION_STATE('P21_OUTPUTACHIEVED_Q2',  l_YTD_Q2 ); 


                elsif apex_exec.get_varchar2 (l_context, l_payperiodid) = v('P21_FY')|| '003' then --QUARTER 3
                
                    l_YTD_Q3 := apex_exec.get_varchar2 (l_context, l_output);
                    l_quarter_Q3 := l_YTD_Q3 - (l_quarter_Q1 + l_quarter_Q2);
                  
                    if l_quarter_Q3 < 0 or l_quarter_Q3 + l_quarter_Q2 < 0 then
                        APEX_UTIL.SET_SESSION_STATE('P21_ORDERS_Q3',  0  );
                        /*if l_quarter_Q2 < 0 then
                            l_quarter_Q3 := l_quarter_Q3 + l_quarter_Q2;  
                        end if;*/
                    else
                        APEX_UTIL.SET_SESSION_STATE('P21_ORDERS_Q3',  l_quarter_Q3  );
                    end if;
                    APEX_UTIL.SET_SESSION_STATE('P21_CREDIT_ORDER_Q3', apex_exec.get_varchar2 (l_context, l_credits) );
                    APEX_UTIL.SET_SESSION_STATE('P21_OUTPUTACHIEVED_Q3',  TO_CHAR(apex_exec.get_varchar2 (l_context, l_output),'FML999G999G999G999G990D00')    ); 


                elsif apex_exec.get_varchar2 (l_context, l_payperiodid) = v('P21_FY')|| '004' then  --QUARTER 4
                  
                    l_YTD_Q4 := apex_exec.get_varchar2 (l_context, l_output);
                    l_quarter_Q4 := l_YTD_Q4 - (l_quarter_Q1 +l_quarter_Q2 + l_quarter_Q3);
                   
                    if l_quarter_Q3 <0 then
                        l_quarter_Q4 := l_YTD_Q4 - (l_quarter_Q1+l_quarter_Q2); -- Q3 payout holds q2 negative payout as well
                        --APEX_UTIL.SET_SESSION_STATE('P21_ORDERS_Q4',TO_CHAR(l_quarter_Q4,'FML999G999G999G999G990D00')  );
                        if l_quarter_Q2 <0 then
                            l_quarter_Q4 := l_YTD_Q4 - (l_quarter_Q1); -- Q3 payout holds q2 negative payout as well
                            --APEX_UTIL.SET_SESSION_STATE('P21_ORDERS_Q4',TO_CHAR(l_quarter_Q4,'FML999G999G999G999G990D00')  );
                        end if;
                    APEX_UTIL.SET_SESSION_STATE('P21_ORDERS_Q4',l_quarter_Q4  );
                    else

                        APEX_UTIL.SET_SESSION_STATE('P21_ORDERS_Q4', l_quarter_Q4  );
                    end if;
                    APEX_UTIL.SET_SESSION_STATE('P21_CREDIT_ORDER_Q4', apex_exec.get_varchar2 (l_context, l_credits) );
                    APEX_UTIL.SET_SESSION_STATE('P21_OUTPUTACHIEVED_Q4',  l_YTD_Q4  ); 
                  
                end if;
            end if;
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