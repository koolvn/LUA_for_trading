function main()
ol = getItem("futures_client_limits",0).cbplimit 			-- ����� ��������, �.�. ����� ����� �� ������ ���
GO = getParamEx("SPBFUT","BRH6","BUYDEPO").param_value 		-- �� ����������
katleta = math.floor(ol/GO)									-- ����. ���-�� ��� �� ��� �������
DC="160402" 												-- ����� �������� ��������
EC="210002" 												-- ����� ��������� ��������
MC="120002"													-- ����� ��������� ��������

message("�� ��� ������� ����� ������  "..katleta.." ����� BRH6",1)
run=true

while run do
	OnClearing()
	sleep(1000)
end

end
function log(str) --LOG
		file = io.open(getScriptPath().."\\������.txt", "a")
		d = os.date("*t")
		file:write( os.date('%Y/%m/%d %H:%M:%S').." "..str.."\n" )
		file:close()
end

function OnClearing()
	if (os.date("%H%M%S")== DC or os.date("%H%M%S")== EC or os.date("%H%M%S")==MC) then
		message("�� ��� ������� ����� ������  "..katleta.." ����� �� BRH6",1)
		str="�� ��� ������� ����� ������  "..katleta.." ����� �� BRH6"
		log(str)
	end
end
	
function OnStop()
	run=false
end