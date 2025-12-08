-- base on github.com/amzxyz
-- update by github.com/happyDom
--[[
首先，把本脚本放在你的方案下的lua文件夹内

※：如果你的脚本名称为 input_statistics ₂₀₂₅1208・A.lua，你需要把文件名改为 input_statistics.lua后再用

※：如果你第一次使用不早于 ₂₀₂₅1208・B 版本的本脚本，请把你原来lua文件夹下的 input_stats.lua删除

其次，在你的方案补丁文件中，在translators节点加入 input_statistics 的引用，如下的第二项
  engine/translators/+:				#定制translator如下
	- lua_translator@*input_statistics				# 统计输入速度等信息

最后，重新部署你的rime/同文

再最后，为了让统计数据在输入 /01 时有响应，你需要在方案补丁文件中加入以下补丁（让方案捕捉/xx [xx为数字] 这类输入):
  recognizer/patterns/punct: '^/([0-9]+|[A-Za-z]+)$'

使用提示：
/01 /rtj	 查看日统计
/02 /ztj	 查看周统计
/03 /ytj	 查看月统计
/04 /ntj	 查看年统计
/05 /sz		 查看生字/词
/009 /qctj	 清除统计数据
]]

-- 输入方案名称
local schema_name = "四角号码"
-- 卡壳时间门限(单位：s)，当上屏的字/词距离前一次上屏时间大于该门限时，该字/词被记录为生字/词组数据
local boggleThd_s = 3

-- 分配一个变量，用于字符串拼接
local strTable = {}

-- 下面的信息是自动获取的
local software_name = rime_api.get_distribution_code_name()
local software_version = rime_api.get_distribution_version()

-- 一个数据结构体，用于处理平均速度统计临时数据
avgSpdInfo = {logSts = 0,		-- 统计状态，0：未统计，1:正在统计，2:统计结束
				startTime=0,	-- 如果正在记录，这里是开始的时间
				commitTime=0,	-- 这是最近一次上屏的时间
				gapThd=5,		-- 如果此次上屏距离前一次上屏时间大于此门限值，则重新开始计时
				count=0			-- 记录期间，上屏的字数
				}

-- 初始化统计表（若未加载）
input_stats = input_stats or {
	daily = {count = 0, length = 0, fastest = 0, ts = 0, lengths = {}, avgGaps={}, avgCnts={}},
	weekly = {count = 0, length = 0, fastest = 0, ts = 0, lengths = {}, avgGaps={}, avgCnts={}},
	monthly = {count = 0, length = 0, fastest = 0, ts = 0, lengths = {}, avgGaps={}, avgCnts={}},
	yearly = {count = 0, length = 0, fastest = 0, ts = 0, lengths = {}, avgGaps={}, avgCnts={}},
	daily_max = 0,
	newWords = {}
}

-- 定义一个求和函数，用于求取一个table内的数字的和
local function tableSum(tb)
	local sum = 0
	for i=1, #tb do
		sum = sum + tb[i]
	end
	return sum
end

-- 定义一个求和函数，用于求取一个table内尾部指定数量项的和
local function tableTailSum(tb,n)
	if type(tb) ~= "table" then return 0 end
    local len = #tb
	local n = tonumber(n) or 0  -- 非数字转 0
	if n < 1 or len < 1 then return 0 end
	
	local sum = 0
	local takeCount = math.min(n, len)
	for i = 1, takeCount do
        sum = sum + (tb[len - takeCount + i] or 0)
    end
	return sum
end

-- 时间戳工具函数
local function start_of_day(t)
	return os.time{year=t.year, month=t.month, day=t.day, hour=0}
end
local function start_of_week(t)
	local d = t.wday == 1 and 6 or (t.wday - 2)
	return os.time{year=t.year, month=t.month, day=t.day - d, hour=0}
end
local function start_of_month(t)
	return os.time{year=t.year, month=t.month, day=1, hour=0}
end
local function start_of_year(t)
	return os.time{year=t.year, month=1, day=1, hour=0}
end

-- 更新统计数据
local function update_stats(input_length)
	local now = os.date("*t")
	local now_ts = os.time(now)

	local day_ts = start_of_day(now)
	local week_ts = start_of_week(now)
	local month_ts = start_of_month(now)
	local year_ts = start_of_year(now)

	if input_stats.daily.ts ~= day_ts then
		input_stats.daily = {count = 0, length = 0, fastest = 0, ts = day_ts, lengths = {}, avgGaps={}, avgCnts={}}
		input_stats.daily_max = 0
	end
	if input_stats.weekly.ts ~= week_ts then
		input_stats.weekly = {count = 0, length = 0, fastest = 0, ts = week_ts, lengths = {}, avgGaps={}, avgCnts={}}
	end
	if input_stats.monthly.ts ~= month_ts then
		input_stats.monthly = {count = 0, length = 0, fastest = 0, ts = month_ts, lengths = {}, avgGaps={}, avgCnts={}}
	end
	if input_stats.yearly.ts ~= year_ts then
		input_stats.yearly = {count = 0, length = 0, fastest = 0, ts = year_ts, lengths = {}, avgGaps={}, avgCnts={}}
	end

	-- 更新记录
	local update = function(stat)
		stat.count = stat.count + 1
		stat.length = stat.length + input_length
	end
	update(input_stats.daily)
	update(input_stats.weekly)
	update(input_stats.monthly)
	update(input_stats.yearly)

	if input_length > input_stats.daily_max then
		input_stats.daily_max = input_length
	end
	
	-- 更新输入字/词组数据
	input_stats.daily.lengths[input_length] = (input_stats.daily.lengths[input_length] or 0) + 1
	input_stats.weekly.lengths[input_length] = (input_stats.weekly.lengths[input_length] or 0) + 1
	input_stats.monthly.lengths[input_length] = (input_stats.monthly.lengths[input_length] or 0) + 1
	input_stats.yearly.lengths[input_length] = (input_stats.yearly.lengths[input_length] or 0) + 1
	
	-- 更新平均分速统计数据
	if 2 == avgSpdInfo.logSts then
		local delt = avgSpdInfo.commitTime - avgSpdInfo.startTime
		table.insert(input_stats.daily.avgGaps, delt)
		table.insert(input_stats.weekly.avgGaps, delt)
		table.insert(input_stats.monthly.avgGaps, delt)
		table.insert(input_stats.yearly.avgGaps, delt)
		table.insert(input_stats.daily.avgCnts, avgSpdInfo.count)
		table.insert(input_stats.weekly.avgCnts, avgSpdInfo.count)
		table.insert(input_stats.monthly.avgCnts, avgSpdInfo.count)
		table.insert(input_stats.yearly.avgCnts, avgSpdInfo.count)
		
		avgSpdInfo.logSts = 0
	end

	-- 最后累计10s的提交数据，计算平均速度做为最大分速的参考
	local latestGapsSum = 0
	local latestCntsSum = 0
	local latestSpd = 0
	local len = #input_stats.daily.avgGaps
	for i=0,len - 1 do
		latestGapsSum = latestGapsSum + input_stats.daily.avgGaps[len - i]
		latestCntsSum = latestCntsSum + input_stats.daily.avgCnts[len - i]
		if latestGapsSum >= 10 then  -- 最后10s的平均速度做为瞬时速度
			break
		end
	end
	if latestGapsSum >= 10 then	-- 如果数据的时长小于10s，则不计算最大速度，避免瞬时偏差过大
		latestSpd = latestCntsSum / latestGapsSum * 60
	end
	
	if latestSpd > input_stats.daily.fastest then input_stats.daily.fastest = latestSpd end
	if latestSpd > input_stats.weekly.fastest then input_stats.weekly.fastest = latestSpd end
	if latestSpd > input_stats.monthly.fastest then input_stats.monthly.fastest = latestSpd end
	if latestSpd > input_stats.yearly.fastest then input_stats.yearly.fastest = latestSpd end
end

-- 表序列化工具（请自行根据实际添加到环境中）
table.serialize = function(tbl)
	local lines = {"{"}
	for k, v in pairs(tbl) do
		local key = (type(k) == "string") and ("[\"" .. k .. "\"]") or ("[" .. k .. "]")
		local val
		if type(v) == "table" then
			val = table.serialize(v)
		elseif type(v) == "string" then
			val = '"' .. v .. '"'
		else
			val = tostring(v)
		end
		table.insert(lines, string.format("	%s = %s,", key, val))
	end
	table.insert(lines, "}")
	return table.concat(lines, "\n")
end

-- 保存至文件
local function save_stats()
	local path = rime_api.get_user_data_dir() .. "/lua/input_stats.lua"
	local file = io.open(path, "w")
	if not file then return end
	file:write("input_stats = " .. table.serialize(input_stats) .. "\n")
	file:close()
end

-- 显示函数（日统计）
local function format_daily_summary()
	local s = input_stats.daily
	if s.count == 0 then return "※ 今天没有任何记录。" end
	
	-- 统计各类输入组合的占比
	local val1 = s.lengths[1] or 0  -- 防止索引不存在时报错，默认0
	local val2 = (s.lengths[2] or 0) * 2
	local val3 = 0
	local total = 0
	for key, value in pairs(s.lengths) do
		total = total + key * value  -- 累加所有值
	end
	if total == 0 then total = 1 end  -- 防止除以0报错
	val3 = total - val1 - val2
	local ratio1 = (val1 / total) * 100
	local ratio2 = (val2 / total) * 100
	local ratio3 = (val3 / total) * 100
	
	-- 计算平均分速
	local avgV = tableSum(input_stats.daily.avgGaps)
	if avgV > 1 then
		avgV = tableSum(input_stats.daily.avgCnts) / avgV * 60
	end
	
	strTable[1] = '※ 日统计：'
	strTable[3] = string.format('上屏 %d 次',s.count)
	strTable[4] = string.format('输入 %d 字',s.length)
	strTable[5] = string.format('最大分速 %.1f 字',s.fastest)
	strTable[6] = string.format('平均分速 %.1f 字',avgV)
	strTable[8] = string.format('单字占比：%.0f％',ratio1)
	strTable[9] = string.format('2字词占比：%.0f％',ratio2)
	strTable[10] = string.format('>2字词占比：%.0f％',ratio3)

	return table.concat(strTable, '\n')
end

-- 显示函数（周统计）
local function format_weekly_summary()
	local s = input_stats.weekly
	if s.count == 0 then return "※ 本周没有任何记录。" end
	
	-- 统计各类输入组合的占比
	local val1 = s.lengths[1] or 0  -- 防止索引不存在时报错，默认0
	local val2 = (s.lengths[2] or 0) * 2
	local val3 = 0
	local total = 0
	for key, value in pairs(s.lengths) do
		total = total + key * value  -- 累加所有值
	end
	if total == 0 then total = 1 end  -- 防止除以0报错
	val3 = total - val1 - val2
	local ratio1 = (val1 / total) * 100
	local ratio2 = (val2 / total) * 100
	local ratio3 = (val3 / total) * 100
	
	-- 计算平均分速
	local avgV = tableSum(input_stats.weekly.avgGaps)
	if avgV > 1 then
		avgV = tableSum(input_stats.weekly.avgCnts) / avgV * 60
	end
	
	strTable[1] = '※ 周统计：'
	strTable[3] = string.format('上屏 %d 次',s.count)
	strTable[4] = string.format('输入 %d 字',s.length)
	strTable[5] = string.format('最大分速 %.1f 字',s.fastest)
	strTable[6] = string.format('平均分速 %.1f 字',avgV)
	strTable[8] = string.format('单字占比：%.0f％',ratio1)
	strTable[9] = string.format('2字词占比：%.0f％',ratio2)
	strTable[10] = string.format('>2字词占比：%.0f％',ratio3)
	return table.concat(strTable, '\n')
end

-- 显示函数（月统计）
local function format_monthly_summary()
	local s = input_stats.monthly
	if s.count == 0 then return "※ 本月没有任何记录。" end
	
	-- 统计各类输入组合的占比
	local val1 = s.lengths[1] or 0  -- 防止索引不存在时报错，默认0
	local val2 = (s.lengths[2] or 0) * 2
	local val3 = 0
	local total = 0
	for key, value in pairs(s.lengths) do
		total = total + key * value  -- 累加所有值
	end
	if total == 0 then total = 1 end  -- 防止除以0报错
	val3 = total - val1 - val2
	local ratio1 = (val1 / total) * 100
	local ratio2 = (val2 / total) * 100
	local ratio3 = (val3 / total) * 100
	
	-- 计算平均分速
	local avgV = tableSum(input_stats.monthly.avgGaps)
	if avgV > 1 then
		avgV = tableSum(input_stats.monthly.avgCnts) / avgV * 60
	end
	
	strTable[1] = '※ 月统计：'
	strTable[3] = string.format('上屏 %d 次',s.count)
	strTable[4] = string.format('输入 %d 字',s.length)
	strTable[5] = string.format('最大分速 %.1f 字',s.fastest)
	strTable[6] = string.format('平均分速 %.1f 字',avgV)
	strTable[8] = string.format('单字占比：%.0f％',ratio1)
	strTable[9] = string.format('2字词占比：%.0f％',ratio2)
	strTable[10] = string.format('>2字词占比：%.0f％',ratio3)
	return table.concat(strTable, '\n')
end

-- 显示函数（年统计）
local function format_yearly_summary()
	local s = input_stats.yearly
	if s.count == 0 then return "※ 本年没有任何记录。" end
	
	-- 统计各类输入组合的占比
	local val1 = s.lengths[1] or 0  -- 防止索引不存在时报错，默认0
	local val2 = (s.lengths[2] or 0) * 2
	local val3 = 0
	local total = 0
	for key, value in pairs(s.lengths) do
		total = total + key * value  -- 累加所有值
	end
	if total == 0 then total = 1 end  -- 防止除以0报错
	val3 = total - val1 - val2
	local ratio1 = (val1 / total) * 100
	local ratio2 = (val2 / total) * 100
	local ratio3 = (val3 / total) * 100
	
	-- 计算平均分速
	local avgV = tableSum(input_stats.yearly.avgGaps)
	if avgV > 1 then
		avgV = tableSum(input_stats.yearly.avgCnts) / avgV * 60
	end
	
	strTable[1] = '※ 年统计：'
	strTable[3] = string.format('上屏 %d 次',s.count)
	strTable[4] = string.format('输入 %d 字',s.length)
	strTable[5] = string.format('最大分速 %.1f 字',s.fastest)
	strTable[6] = string.format('平均分速 %.1f 字',avgV)
	strTable[8] = string.format('单字占比：%.0f％',ratio1)
	strTable[9] = string.format('2字词占比：%.0f％',ratio2)
	strTable[10] = string.format('>2字词占比：%.0f％',ratio3)
	return table.concat(strTable, '\n')
end

-- 显示记录的生字/词
local function format_shengzi()
	if input_stats.newWords == nil then
		return string.format("※ 未发现生字/词记录。")
	end
	
	local tmpTable = {}
	local newWords = {}
	local cnt = 0
	local i = 1
	tmpTable[1] = ""
	for k, v in pairs(input_stats.newWords) do
		i = i + 1
		cnt = #v
		tmpTable[i] = string.format("%s：%d次，ⱦ = %0.1fs", k, cnt, tableSum(v)/cnt)
		table.insert(newWords, k)
	end
	tmpTable[1] = string.format("共有 %d 个生字/词：", i - 1)	-- 设置表头
	
	tmpTable[i + 1] = strTable[14]	-- 分隔线
	tmpTable[i + 2] = table.concat(newWords, '，')
	tmpTable[i + 3] = strTable[14]	-- 分隔线
	tmpTable[i + 4] = strTable[15]	-- 版本信息
	
	if i < 2 then
		return string.format("※ 未发现生字/词记录。")
	else
		return table.concat(tmpTable, '\n')
	end
end

-- 转换器函数：处理命令 /rtj /ztj /ytj /ntj
local function translator(input, seg, env)
	if input:sub(1, 1) ~= "/" then return end
	local summary = ""
	if input == "/01" or input == "/rtj" then
		summary = format_daily_summary()
	elseif input == "/02" or input == "/ztj" then
		summary = format_weekly_summary()
	elseif input == "/03" or input == "/ytj" then
		summary = format_monthly_summary()
	elseif input == "/04" or input == "/ntj" then
		summary = format_yearly_summary()
	elseif input == "/05" or input == "/sz" then
		summary = format_shengzi()
	elseif input == "/009" or input == "/qctj" then
		input_stats = {
			daily = {count = 0, length = 0, fastest = 0, ts = 0, lengths = {}, avgGaps={}, avgCnts={}},
			weekly = {count = 0, length = 0, fastest = 0, ts = 0, lengths = {}, avgGaps={}, avgCnts={}},
			monthly = {count = 0, length = 0, fastest = 0, ts = 0, lengths = {}, avgGaps={}, avgCnts={}},
			yearly = {count = 0, length = 0, fastest = 0, ts = 0, lengths = {}, avgGaps={}, avgCnts={}},
			daily_max = 0,
			newWords = {}
		}
		save_stats()
		summary = "※ 所有统计数据已清空。"
	end

	if summary ~= "" then
		yield(Candidate("stat", seg.start, seg._end, summary, ""))
	end
end
-- 加载保存的统计数据（input_stats.lua）
local function load_stats_from_lua_file()
	local path = rime_api.get_user_data_dir() .. "/lua/input_stats.lua"
	local ok, result = pcall(function()
		local env = {}
		local f = loadfile(path, "t", env)
		if f then f() end
		return env.input_stats
	end)
	if ok and type(result) == "table" then
		input_stats = result
	else
		-- 保底初始化，防止错误
		input_stats = {
			daily = {count = 0, length = 0, fastest = 0, ts = 0, lengths = {}},
			weekly = {count = 0, length = 0, fastest = 0, ts = 0, lengths = {}},
			monthly = {count = 0, length = 0, fastest = 0, ts = 0, lengths = {}},
			yearly = {count = 0, length = 0, fastest = 0, ts = 0, lengths = {}},
			daily_max = 0,
			newWords = {}
		}
	end
end
local function init(env)
	local ctx = env.engine.context
	local splitor = string.rep("─", 14)

	-- 加载历史统计数据
	load_stats_from_lua_file()
	
	-- 初始化统计字符串
	strTable[2] = splitor
	strTable[7] = splitor
	strTable[11] = splitor
	strTable[12] = '◉ 方案：'..schema_name
	strTable[13] = '◉ 平台：'..software_name..' '..software_version
	strTable[14] = splitor
	strTable[15] = '脚本：₂₀₂₅1208・C'

	-- 注册提交通知回调
	ctx.commit_notifier:connect(function()
		local commit_text = ctx:get_commit_text()
		if not commit_text or commit_text == "" then return end
		
		-- 如果输入与上屏内容一致，例如编码上屏，则不统计此项
		if ctx.input == commit_text then return end
		
		-- 如果输入是以 / 引导的，则不统计这个输入项
		if ctx.input:find("^/") then return end

		-- 如果是标点符号，则不进行统计
		if commit_text:match("^[！!@#$％^&?,.;？，。；/0123456789]+$") then return end
		
		local timeNow = os.time()
		local input_length = utf8.len(commit_text) or string.len(commit_text)
		local delt = timeNow - avgSpdInfo.commitTime
		-- 统计平均分速
		if 1 == avgSpdInfo.logSts then	-- 如果当前正在统计中
			if delt > avgSpdInfo.gapThd then	-- 如果超时了
				if avgSpdInfo.commitTime - avgSpdInfo.startTime >= 1 and avgSpdInfo.count > 0 then
					avgSpdInfo.logSts = 2	-- 统计结束，后面会将统计结果记录起来
				else
					avgSpdInfo.logSts = 0	-- 统计恢复到初始状态
				end
			else
				-- 更新上屏时间
				avgSpdInfo.commitTime = timeNow
				-- 记录输入字数
				avgSpdInfo.count = avgSpdInfo.count + input_length
			end
		end
		
		-- 如果卡壳了(但是间隔时间小于60s)，记录这个字/词
		if delt > boggleThd_s and delt < 60 then
			if input_stats.newWords[commit_text] ~= nil then
				table.insert(input_stats.newWords[commit_text], delt)
			else
				input_stats.newWords[commit_text] = {delt}
			end
		elseif delt < boggleThd_s then
			-- 没有卡壳，但这是一个生字，则记录上屏时间，并尝试消除该记录
			if input_stats.newWords[commit_text] ~= nil then
				table.insert(input_stats.newWords[commit_text], 0)
				local len = #input_stats.newWords[commit_text]
				if len > 3 then
					-- 如果该字/词最后三次的输入都没有超时，则消除该字/词的记录
					if tableTailSum(input_stats.newWords[commit_text], 3) < 1 then
						input_stats.newWords[commit_text] = nil
					end
				end
			end
		end
		
		-- 上屏统计
		update_stats(input_length)
		save_stats()
		
		-- 启动平均分速统计
		if 0 == avgSpdInfo.logSts then	-- 如果当前没有进行统计，则此次上屏事件会触发统计启动
			avgSpdInfo.logSts = 1
			avgSpdInfo.startTime = timeNow
			avgSpdInfo.commitTime = timeNow
			avgSpdInfo.count = 0
		end
	end)
end
return { init = init, func = translator }