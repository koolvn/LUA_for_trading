function main()
run=true

while run do
for i=0,getNumberOf("stop_orders")-1 do
  stop_order = getItem("stop_orders", i)
	if CheckBit(stop_order.flags,0)==1 then
	str=stop_order.brokerref 
	log(str)
		if stop_order.brokerref =="RiskMan" then
			message("���� �������� ����")
			run=false			
		end
	end
end
sleep (10)
end


end

function OnStop()
run=false
end

function log(str) 					-- LOG
 file = io.open(getScriptPath().."\\TransREPLY.txt", "a")
 d = os.date("*t")
 file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
 file:close()
end

function CheckBit(flags, bit)
   -- ���������, ��� ���������� ��������� �������� �������
   if type(flags) ~= "number" then error("��������������!!! Checkbit: 1-� �������� �� �����!"); end;
   if type(bit) ~= "number" then error("��������������!!! Checkbit: 2-� �������� �� �����!"); end;
   local RevBitsStr  = ""; -- ������������ (����� �������) ��������� ������������� ��������� ������������� ����������� ����������� ����� (flags)
   local Fmod = 0; -- ������� �� �������
   local Go = true; -- ���� ������ �����
   while Go do
      Fmod = math.fmod(flags, 2); -- ������� �� �������
      flags = math.floor(flags/2); -- ��������� ��� ��������� �������� ����� ������ ����� ����� �� �������
      RevBitsStr = RevBitsStr ..tostring(Fmod); -- ��������� ������ ������� �� �������
      if flags == 0 then Go = false; end; -- ���� ��� ��������� ���, ��������� ����
   end;
   -- ���������� �������� ����
   local Result = RevBitsStr :sub(bit+1,bit+1);
   if Result == "0" then return 0;
   elseif Result == "1" then return 1;
   else return nil;
   end;
end;