-- �������� ������� ���� � ������ "������/������"
   f = io.open(getScriptPath().."\\Result.txt","r+");
   -- ���� ���� �� ����������
   if f == nil then 
      -- ������� ���� � ������ "������"
      f = io.open(getScriptPath().."\\Result.txt","w"); 
      -- ��������� ����
      f:close();
      -- ��������� ��� ������������ ���� � ������ "������/������"
      f = io.open(getScriptPath().."\\Result.txt","r+");
   end;
   -- ���������� � ���� 2 ������
   f:write("!"); -- "\n" ������� ����� ������
   -- ��������� ��������� � �����
   
   function log( str ) --LOG
 local file = io.open(getScriptPath().."\\log.txt", "a")
 local d = os.date("*t")
 file:write( os.date('%Y-%m-%d %H:%M:%S').." "..str.."\n" )
 file:close()
end

function restart() --������� �������
	run=false
	sleep(1000)
	run=true
	str="Script restarted"
	log (str)
	sleep(1000)
end
end

function OpPo() -- ���������� ������ ������� "������� �� ���������� ������ (��������)", ���� ������� ������ �������
for i = 0,getNumberOf("FUTURES_CLIENT_HOLDING") - 1 do
   -- ���� ������ �� ������� ����������� � ������ ������� �� ����� ���� ��
   if getItem("FUTURES_CLIENT_HOLDING",i).totalnet ~= 0 then
      -- ���� ������� ������ ������� > 0, �� ������� ������� ������� (BUY)
      if getItem("FUTURES_CLIENT_HOLDING",i).totalnet > 0 then 
         IsBuy = true;
         BuyVol = getItem("FUTURES_CLIENT_HOLDING",i).totalnet;	-- ���������� ����� � ������� BUY				
      else   -- ����� ������� �������� ������� (SELL)
         IsSell = true;
         SellVol = math.abs(getItem("FUTURES_CLIENT_HOLDING",i).totalnet); -- ���������� ����� � ������� SELL
      end;
   end;
end;