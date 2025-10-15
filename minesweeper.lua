minesweeper = {}

circularArea = {{-1, -1}, { 0, -1}, { 1, -1},
				{-1,  0},           { 1,  0},
				{-1,  1}, { 0,  1}, { 1,  1}}

math.randomseed(os.time() + os.clock())

-- Error Messages
local err = {
	e1 = {val = 1, msg = "X or Y is out of the board's range."},
	e2 = {val = 2, msg = "Too many mines for this board."},
	e3 = {val = 3, msg = "Area is filled, can't flag it."},
}

minesweeper.err = err

function tableEq(tab1, tab2)
	return table.concat(tab1, "-") == table.concat(tab2, "-")
end

function containsTable(value, list)
	for _, item in ipairs(list) do
		if tableEq(item, value) then
			return true
		end
	end

	return false
end

function inRange(num, min, max)
	return not (num > max or num < min)
end

function minesweeper.expand(x, y, board, flags)
	local height = #board
	local width  = #board[1]

	--   X   Y
	-- [-1, -1] [ 0, -1] [ 1, -1]
	-- [-1,  0] [ 0,  0] [ 1,  0]
	-- [-1,  1] [ 0,  1] [ 1,  1]

	if not (inRange(x, 1, width) and inRange(y, 1, height)) then
		return board, "Out of board's range"
	end

	if flags and containsTable({x, y}, flags) then
		return board, "Clicked on a flag"
	end

	if board[y][x] == "M" then
		return board, "mine"
	end

	if board[y][x] ~= "-" then
		return board, "Clicked on a non-empty space"
	end

	local tileNumber = 0 

	for _, area in ipairs(circularArea) do
		currentX = x + area[1]
		currentY = y + area[2]

		if inRange(currentX, 1, width) and inRange(currentY, 1, height) then
			if board[currentY][currentX] == "M" then
				tileNumber = tileNumber + 1
			end
		end
	end

	board[y][x] = tileNumber

	if tileNumber == 0 then
		for _, area in ipairs(circularArea) do
			board, _ = minesweeper.expand(x + area[1], y + area[2], board, flags)
		end
	end

	return board, "expanded"
end


function minesweeper.createMines(x, y, board, amountOfMines)
	local height = #board
	local width  = #board[1]

	local mines = {}
	local invalidAreas = {{x, y}}

	for _, area in ipairs(circularArea) do
		invalidAreas[#invalidAreas + 1] = {x + area[1], y + area[2]} 
	end

	if amountOfMines >= ((height * width) - #invalidAreas) then
		return nil, err.e2
	end

	for _ = 1, amountOfMines do
		::continue::

		local mineLocation = {math.random(width), math.random(height)}

		if containsTable(mineLocation, invalidAreas) then
			goto continue
		end

		mines[#mines + 1] = mineLocation
		invalidAreas[#invalidAreas + 1] = mineLocation
	end

	return mines
end


function minesweeper.createBoard(x, y, width, height, amountOfMines)
	local board = {}

	for h = 1, height do
		board[h] = {}
		for w = 1, width do
			board[h][w] = "-"
		end
	end

	if not (inRange(x, 1, width) and inRange(y, 1, height)) then
		return {}, {}, err.e1
	end

	local mines, err = minesweeper.createMines(x, y, board, amountOfMines)

	if err then
		return {}, {}, err
	end

	for _, mine in ipairs(mines) do
		board[mine[2]][mine[1]] = "M"
	end 

	board, _ = minesweeper.expand(x, y, board, {})
	return board, mines, nil
end


function minesweeper.flag(x, y, board, flags)
	local height = #board
	local width  = #board[1]

	if not (inRange(x, 1, width) and inRange(y, 1, height)) then
		return flags, err.e1
	end

	local tile = board[y][x]

	if not (tile == "-" or tile == "M") then
		return flags, err.e3
	end

	for i, flag in ipairs(flags) do
		if tableEq(flag, {x, y}) then
			table.remove(flags, i)

			return flags
		end
	end

	flags[#flags + 1] = {x, y}

	return flags
end

function minesweeper.checkWin(mines, board)
	for _, row in ipairs(board) do
		for _, tile in ipairs(row) do
			if tile == "-" then 
				return false 
			end
		end
		
	end

	return true
end

function minesweeper.printBoard(board)
	for _, l in ipairs(board) do
		for _, v in ipairs(l) do
			io.write(v)
		end
		print()
	end
end

return minesweeper