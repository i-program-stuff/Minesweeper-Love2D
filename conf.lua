function setDiffculty(difficulty)
	-- First Value is the Width of the Board
	-- Second Value is the Height of the Board
	-- Third Value is the Amount of Mines
	custom = {20, 20, 50}

	modes = {
		["easy"] = {12, 10, 15},
		["normal"] = {18, 14, 40},
		["hard"] = {26, 22, 99},
		["custom"] = custom,
	}

	boardWidth, boardHeight, numOfMines = unpack(modes[difficulty])
end

function love.conf(t)
	t.title = "Minesweeper"
	t.version = "11.3"

	-- Used in the main.lua file
	Debug = string.lower(tostring(arg[2])) == "-d"

	setDiffculty(arg[3] or "normal")

	tileSize = 35
	headBarSize = 60
	--

	t.window.width = boardWidth * tileSize
	t.window.height = boardHeight * tileSize + headBarSize
	t.window.borderless = true
	t.window.msaa = 16

	t.window.vsync = 0
end
