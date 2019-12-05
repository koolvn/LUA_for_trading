function main()
run=true
trans_id = os.time()      							-- ������� ���� � ����� � �������� ������ �������� ��� ���������� ������� ����������
ACCOUNT = "SPBFUT00740" 							-- ��� �����
CC = "SPBFUT"      									-- ��� ������
SC = "BRH6"        									-- ��� �����������
LP=tonumber(getParamEx(CC, SC, "LAST").param_value) -- ���� ��������� ������
OpPo()
end

function OpPo() 					-- ���������� ������ ������� "������� �� ���������� ������ (��������)", ���� ������� ������ �������
BuyVol=0
SellVol=0
	for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do 
		if getItem("FUTURES_CLIENT_HOLDING",i).totalnet ~= 0 then -- ���� ������ ������� �� ����� ���� ��
			if getItem("FUTURES_CLIENT_HOLDING",i).totalnet > 0 then -- ���� ������� ������ ������� > 0, �� ������� ������� ������� (BUY)
				IsBuy = true;
				BuyVol = getItem("FUTURES_CLIENT_HOLDING",i).totalnet	-- ���������� ����� � ������� BUY				
				SC = getItem("FUTURES_CLIENT_HOLDING",i).sec_code		-- ��� ����������� ���������
				message("���� � "..SC.." ������� "..BuyVol.." ���")
			else   -- ����� ������� �������� ������� (SELL)
				IsSell = true;
				SellVol = math.abs(getItem("FUTURES_CLIENT_HOLDING",i).totalnet) 	-- ���������� ����� � ������� SELL
				SC = getItem("FUTURES_CLIENT_HOLDING",i).sec_code					-- ��� ����������� ���������
				message("���� � "..SC.." ������� "..SellVol.." ���")
			end
		end
	end
end

function Trade(Type)
   --�������� ID ����������
   trans_id = trans_id + 1;
 -- �������� ��� ���� �����������
   SEC_PRICE_STEP = getParamEx(CLASS_CODE, SEC_CODE, "SEC_PRICE_STEP").param_value
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
   end
   