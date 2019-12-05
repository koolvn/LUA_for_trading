--[[
*******************************************************************
 ������ ��������� ���� ������ (�����������, ������, ������ � �.�.)
 �� ���������. ��������� ���� ������ ����������� � ������� ent_list.
 ������ ���������� ��������� ��������� ����� ������ � ������
 ������� getItem � getNumberOf. ����� ������� ������� ���������
 ��� ������ ����������� � ���� all_entity.txt.
 ��� ���������� ����� ��������� ������� ������� tpf.lua.
*******************************************************************
]]


dofile("tpf.lua")

f=nil
stopped = false
function myLog(str)
	if f~=nil then
		f:write(os.date() .. " ".. str .. "\n")
	end
end

function OnInit(path)
	f = io.open("all_entity.txt", "w+t")
	myLog("in OnInit. script path = " .. path)
end
 function OnAllTrade( trade )
 	-- body
 end
function OnStop(signal)
	stopped = true
end

function main( ... )
	ent_list = {"classes", "firms", "securities", "trade_accounts",
				"all_trades", "account_positions", "orders",
				"futures_client_holding","futures_client_limits",
				"money_limits", "depo_limits", "trades", "stop_orders"}

	start_time = os.clock()
	for k,v in pairs(ent_list) do
		t={}
		count = getNumberOf(v)
		if count then
			for i=0,count-1 do
				if stopped then
					break
				end
				t=getItem(v, i)
				if t ~= nil and type(t) == "table" then
					table_save(v.."[" .. i .. "]", f, t)

					f:flush()
				else
					f:write("value " .. v .. " = , index = "..tostring(i) .. "type = " .. type(t) .. "ret_value = " .. tostring(t).. "\n")
				end
			end
		end
		if stopped then
			break
		end
	end
	f:write("\ntook " .. tonumber(os.clock() - start_time))
	f:close()
end
