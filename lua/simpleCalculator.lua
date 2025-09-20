-- 简单计算器 translator，仅支持 + - * / 四则运算，不支持任何非[0-9+\-*/]内的符号
-- 触发方式：输入 /算式 例如 /1+2*3

-- 数字转上标映射表
local superscripts = {
    ["0"]="⁰", ["1"]="¹", ["2"]="²", ["3"]="³", ["4"]="⁴",
    ["5"]="⁵", ["6"]="⁶", ["7"]="⁷", ["8"]="⁸", ["9"]="⁹",
    ["-"]="⁻"  -- 支持负指数
}

-- 把数字转成上标
local function to_superscript(s)
    return s:gsub("[0-9%-]", superscripts)
end

-- 美化表达式显示
local function beautify_expr(expr)
	-- 幂运算美化：把 ^number 替换成上标
    expr = expr:gsub("%^(%-?[%d%.]+)", function(num)
		if num:match("%.") then
			-- 如果指数中有小米点，则不做美化处理
			return "^"..num
		else
			return to_superscript(num)
		end
    end)
	
	expr = expr:gsub("%*", "×"):gsub("/", "÷"):gsub("%-", "−"):gsub("%+", "＋")
	
	return expr
end

-- 保留指定小数位数，并去掉末尾无用的 0
local function format_number(n, decimals)
    decimals = decimals or 6  -- 默认保留6位小数
    local s = string.format("%." .. decimals .. "f", n)
    -- 去掉末尾的 0 和可能残留的小数点
    s = s:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
    return s
end



-- 检查非法表达式
local function check_invalid_expr(expr)
    if expr:match("%.%d*%.") then
		-- 例如 4.5.3
        return "多重小数点"
    elseif expr:match("%^%d*%^") then
		-- 例如 4^5^3
        return "多重幂"
    elseif expr:match("[+%-*/%^][+%-*/%^]") then
		-- 例如 5+-3
        return "运算符连续"
    end
    return nil
end

-- 该函数参考 wanxiang，并由 GPT生成
local function simple_calculator(input, seg, env)
    -- 必须以 / 开头
    if not input:match("^/") then
        return
    end

    -- 去掉开头的 /
    local expr = input:sub(2)
	
	-- 把 , ， 。 全部替换成小数点
    expr = expr:gsub("[,，。]", ".")
	
	-- 处理隐式乘法
	expr = expr
		:gsub("(%d)%(", "%1*(")   -- 12(3) → 12*(3)
		:gsub("%)%(", ")*(")      -- (2)(3) → (2)*(3)
		:gsub("%)(%d)", ")*%1")   -- (3)4 → (3)*4

    -- 必须以数字开头和结尾
    if not expr:match("^[%-%(%d]") or not expr:match("[%d%)]$") then
        return
    end
	
    -- 必须包含至少一个运算符
    if not expr:match("[+%-*/%^]") then
        return
    end

    -- 只允许数字、小数点和运算符
    if not expr:match("^[%d%.%+%-*/%(%)%^]+$") then
        return
    end
	
	-- 防错检查
    local err_msg = check_invalid_expr(expr)
    if err_msg then
        yield(Candidate("calc", seg.start, seg._end, err_msg, ""))
        return
    end
	
    -- 编译表达式
    local func, err = load("return " .. expr, "calc", "t", {})

    if not func then
        yield(Candidate("calc", seg.start, seg._end, "错误: " .. err, ""))
        return
    end

    -- 安全执行
    local ok, result = pcall(func)
    if ok and type(result) == "number" then
        local display = format_number(result)
        yield(Candidate("calc", seg.start, seg._end, display, "计算结果"))
        yield(Candidate("calc", seg.start, seg._end, beautify_expr(expr) .. "=" .. display, ""))
    else
        yield(Candidate("calc", seg.start, seg._end, "执行错误", ""))
    end
end

return simple_calculator
