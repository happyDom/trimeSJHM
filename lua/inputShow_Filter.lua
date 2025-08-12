-- inputShow_Filter.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>

--引入 utf8String 处理字符串相关操作
local utf8StringEnable, utf8String = pcall(require, 'utf8String')

local logEnable, log = pcall(require, "runLog")
if logEnable then
	log.writeLog('')
	log.writeLog('log from inputShow_Filter.lua')
	log.writeLog('utf8StringEnable:'..tostring(utf8StringEnable))
end

local candsCnt = 0
local candsIdx = -1
local cands = {}

local function _inputShow(input, env)
	local inputStr = tostring(env.engine.context.input)
	local inputStrLen = string.len(inputStr)
	
	candsCnt = 0
	candsIdx = -1
	cands = {}
	for cand in input:iter() do
		candsIdx = candsIdx + 1
		
		if inputStrLen > 3 or '/' == inputStr:sub(1,1) then
			-- 3码以上，或者以 / 引导的输入，不做处理
			yield(cand)
		elseif utf8String.utf8Len(cand.text) < 2 then
			-- 3码以内，只出字
			if '*' == inputStr:sub(1,1) then
			-- 如果以 * 开头，则1码只出 5 个字，2码只出 20 个字
				yield(cand)
				candsCnt = candsCnt + 1
				if 1 == inputStrLen then
					if candsCnt >= 5 then
						break
					end
				elseif 2 == inputStrLen then
					if candsCnt >= 20 then
						break
					end
				end
			elseif inputStrLen < 3 then
				-- 1码只出一简字，或二简字
				if '~' == cand.comment:sub(1,1) then
					break
				else
					-- yield(cand)
					table.insert(cands, cand)
					candsCnt = candsCnt + 1
				end
			else
				yield(cand)
				candsCnt = candsCnt + 1
			end
		end
	end
	
	-- 一简字，二简字排序，以便保持固定的次序
	if 0 < #cands then
		table.sort(cands, function(a,b)
			if a.text > b.text then
				return false
			else
				return true
			end
		end)
		for idx = 1, #cands do
			yield(cands[idx])
		end
	end
end

local function inputShow(input, env)
	_inputShow(input,env)
end

return inputShow
