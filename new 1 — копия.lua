--/*������������� ���������*/
R=2 								-- ������������ ���� �� ���� � % �� ��������
P=6 								-- ������� ������� ������� � % �� ��������

function VA() 										--/*���������*/
ol = getItem("futures_client_limits",0).cbplimit 	-- ����� ��������, �.�. ����� ����� �� ������ ���
vm = getItem("futures_client_limits",0).varmargin 	-- ������������ �����
nd = getItem("futures_client_limits",0).accruedint 	-- ����������� �����
pl = vm+nd 											-- ������� ������/����
plp = math.ceil(pl/ol*10000)/100 					-- P/L � ���������
risk = ol*0.01*R 									-- ������� ����
opc = getItem("futures_client_holding",0).totalnet 	-- ���-�� �������� �������
fut = getItem("futures_client_holding",0).sec_code 	-- ��� ���������

end

function main()
run=true
VA()
message("���� �� ����: "..risk.." �.".." ������� P/L: "..pl.." �. ("..plp.." %)",2)
str = "Script started"
log(str)
str = "���� �� ����: "..risk.." �.".." ������� P/L: "..pl.." �. ("..plp.." %)"
log(str)
	while run do
	VA()
			if plp<=-R then
			if opc ~= 0 then 
			message ("���������� �������� �����!!! ���� �������� �������!",3)
			str = "���������� �������� �����!!! ���� �������� �������! P/L: "..pl.."( "..plp.." %"
			log(str)
			else
			message ("���������� �������� �����!!! P/L: " ..pl.."( "..plp.." %",3)
			str = "���������� �������� �����!!! P/L: " ..pl.."( "..plp.." %"
			log(str)
			end
		run=false
		else
			if plp>=P then
				if opc ~= 0 then 
				message ("��������� ������� ���� �� �������! ���� �������� �������! P/L: "..pl.." �.( "..plp.." %)",2)
				str = "��������� ������� ���� �� �������! ���� �������� �������! P/L: "..pl.." �.( "..plp.." %)"
				log(str)
				else
				message ("��������� ������� ���� �� �������! ����������! ��� �����! P/L: "..pl.." �.( "..plp.." %)",1)
				str = "��������� ������� ���� �� �������! ����������! ��� �����! P/L: "..pl.." �.( "..plp.." %)"
				log(str)
				end
			run=false
			else
			end
		end
	sleep(1000)
		
	end
end

function OnDisconnected()
str="Disconnected. P/L: "..pl.." �.( "..plp.." %)"
   log(str)
end

function OnConnected()
str="Connected. P/L: "..pl.." �.( "..plp.." %)"
   log(str)
end

function log(str) --LOG
 file = io.open(getScriptPath().."\\RiskManLog.txt", "a")
 d = os.date("*t")
 file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
 file:close()
end

function OnStop()
str="Script stopped by user"
   log(str)
run = false
 end