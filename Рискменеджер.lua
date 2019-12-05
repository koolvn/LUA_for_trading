--/*������������� ���������*/
ACCOUNT='SPBFUT589000';        -- ������������� �����
CLASS_CODE='SPBFUT';             -- ��� ������
R=2; -- ������������ ���� �� ���� � % �� ��������
P=1; -- ������� ������� ������� � % �� ��������

--/*����������*/
ol = getItem("futures_client_limits",0).cbplimit -- ����� ��������, �.�. ����� ����� �� ������ ���
vm = getItem("futures_client_limits",0).varmargin -- ������������ �����
nd = getItem("futures_client_limits",0).accruedint -- ����������� �����
pl = vm+nd -- ������� ������/����
plp = math.ceil(pl/ol*10000)/100 -- P/L � ���������
risk = ol*0.01*R -- ������� ����
opc = getItem("futures_client_holding",0).totalnet -- ���-�� �������� �������
fut = getItem("futures_client_holding",0).sec_code -- ��� ���������

is_run=true
message("���� �� ����: "..risk.." �.".." ������� P/L: "..pl.." �. ("..plp.." %)",2)
function main()
	while is_run do
		if plp<=-R then
			if opc ~= 0 then 
			message ("���������� �������� �����!!! ���� �������� �������!",3)
			KillPos(Type)
			else
			message ("���������� �������� �����!!!",3)
			end
		is_run=false
		else
			if plp>=P then
				if opc ~= 0 then 
				message ("��������� ������� ���� �� �������! ���� �������� �������!",2)
				KillPos(Type)
				else
				message ("��������� ������� ���� �� �������! ����������! ��� �����!",1)
				end
			is_run=false
			else
			end
		end
	end
end
function KillPos(Type)
   -- ������ 10 �������
   local Count = 0; -- ������� �������
   if Type == 'BUY' then
      -- ���� ������ �� ���������� � ������� �� �������
      while Run and not Trade('SELL') do -- ��������� SELL, ��� ����� �������� BUY, ���� Trade('SELL') ������ TRUE, ���� �����������
         Count = Count + 1; -- ����������� �������
         -- ���� �� 10 ������� �� ������� ������� �������
         if Count == 10 then
            -- ���������� NIL
            return nil;
         end;
         sleep(100); -- ����� 100 ��, ����� ���������� �������� �� �������
      end;
   else
      -- ���� ������ �� ���������� � ������� �� �������
      while Run and not Trade('BUY') do -- ��������� BUY, ��� ����� �������� SELL, ���� Trade('BUY') ������ TRUE, ���� �����������
         Count = Count + 1; -- ����������� �������
         -- ���� �� 10 ������� �� ������� ������� �������
         if Count == 10 then
            -- ���������� NIL
            return nil;
         end;
         sleep(100); -- ����� 100 ��, ����� ���������� �������� �� �������
      end;
   end;
   -- ���������� TRUE, ���� ������� ������������� ������� �������
   return true;
end;
function Trade(Type)
   --�������� ID ����������
   trans_id = trans_id + 1;

   local Price = 0;
   local Operation = '';
   --������������� ���� � ��������, � ����������� �� ���� ������ � �� ������ �����������
   if Type == 'BUY' then
      if CLASS_CODE ~= 'QJSIM' and CLASS_CODE ~= 'TQBR' then Price = getParamEx(CLASS_CODE, SEC_CODE, 'offer').param_value + 10*SEC_PRICE_STEP;end; -- �� ����, ���������� �� 10 ���. ����� ����
      Operation = 'B';
   else
      if CLASS_CODE ~= 'QJSIM' and CLASS_CODE ~= 'TQBR' then Price = getParamEx(CLASS_CODE, SEC_CODE, 'bid').param_value - 10*SEC_PRICE_STEP;end; -- �� ����, ���������� �� 10 ���. ����� ����
      Operation = 'S';
   end;
   -- ��������� ��������� ��� �������� ����������
   local Transaction={
      ['TRANS_ID']   = tostring(trans_id),
      ['ACTION']     = 'NEW_ORDER',
      ['CLASSCODE']  = CLASS_CODE,
      ['SECCODE']    = SEC_CODE,
      ['OPERATION']  = Operation, -- �������� ("B" - buy, ��� "S" - sell)
      ['TYPE']       = 'M', -- �� ����� (MARKET)
      ['QUANTITY']   = '1', -- ����������
      ['ACCOUNT']    = ACCOUNT,
      ['PRICE']      = tostring(Price),
      ['COMMENT']    = '������� MA-�����'
   }
   -- ���������� ����������
   sendTransaction(Transaction);
   -- ����, ���� ������� ������ ������� ���������� (���������� "trans_Status" � "trans_result_msg" ����������� � ������� OnTransReply())
   while Run and trans_Status == nil do sleep(1); end;
   -- ���������� ��������
   local Status = trans_Status;
   -- ������� ���������� ����������
   trans_Status = nil;
   -- ���� ���������� �� ��������� �� �����-�� �������
   if Status ~= 3 then
      -- ���� ������ ���������� �������� ��� �������� ����
      if Status == 6 then
         -- ������� ���������
         message('������� MA-�����: ������ ���������� �������� ��� �������� ����!');
         SEC_NO_SHORT = true;
      else
         -- ������� ��������� � �������
         message('������� MA-�����: ���������� �� ������!\n������: '..trans_result_msg);
      end;
      -- ���������� FALSE
      return false;
   else --���������� ����������
      local OrderNum = nil;
      --���� ���� ������ �� �������� ������ ����� ��������� ���������
      --���������� ����� ������ � ��������
      local BeginTime = os.time();
      while Run and OrderNum == nil do
         --���������� ������� ������
         for i=0,getNumberOf('orders')-1 do
            local order = getItem('orders', i);
            --���� ������ �� ������������ ���������� ��������� ���������
            if order.trans_id == trans_id and order.balance == 0 then
               --���������� ����� ������
               OrderNum  = order.order_num;
               --��������� ���� FOR
               break;
            end;
         end;
         --���� ������ 10 ������, � ������ �� ���������, ������ ��������� ������
         if os.time() - BeginTime > 9 then
            -- ������� ��������� � �������
            message('������� MA-�����: ������ 10 ������, � ������ �� ���������, ������ ��������� ������');
            -- ���������� FALSE
            return false;
         end;
         sleep(10); -- ����� 10 ��, ����� �� ����������� ��������� ����������
      end;

      --���� ���� ������ �������� ������� ����� ���������
      --���������� ����� ������ � ��������
      BeginTime = os.time();
      while Run do
         --���������� ������� ������
         for i=0,getNumberOf('trades')-1 do
            local trade = getItem('trades', i);
            --���� ������ �� ������� ������
            if trade.order_num == OrderNum then
               --���������� ����������� ���� �������� ������
               return trade.price;
            end;
         end;
         --���� ������ 10 ������, � ������ �� ���������, ������ �� ����-����� ��������� ������
         if os.time() - BeginTime > 9 then
            -- ������� ��������� � �������
            message('������� MA-�����: ������ 10 ������, � ������ �� ���������, ������ �� ����-����� ��������� ������');
            -- ���������� FALSE
            return false;
         end;
         sleep(10); -- ����� 10 ��, ����� �� ����������� ��������� ����������
      end;
   end;
end;

function OnStop()
is_run = false
 end