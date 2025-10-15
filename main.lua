minesweeper = require("minesweeper")

function dPrint(msg, isBoard)
	if not Debug then
		return
	end

	os.execute("clear")

	if isBoard then
		minesweeper.printBoard(msg)
	else
		print(msg)
	end
end

function rgb255to1(r, g, b, a)
	a = a or 1 

	return {r/255, g/255, b/255, a}
end

function inRectangle(mx, my, x, y, width, height)
	return (mx >= x and mx <= x + width) and (my >= y and my <= y + height)
end

function contains(value, list)
	for _, item in ipairs(list) do
		if value == item then
			return true
		end
	end

	return false
end

function grayout(msg)
	lg.setColor(0, 0, 0, 0.4)
	lg.rectangle("fill", 0, 0, screenWidth, screenHeight)

	lg.setFont(fontEndScreen)
	lg.setColor(1,1,1)

	local numberOfLines = select(2, msg:gsub('\n', '\n'))

	local width = fontEndScreen:getWidth(msg) 
	local height = fontEndScreen:getHeight(msg)

	local locationX = screenWidth / 2 - width / 2
	local locationY = screenHeight / 2 - height / 2 * numberOfLines

	lg.printf(msg, locationX, locationY, width, "center")
end

function expand(x, y)
	board, action = minesweeper.expand(x, y, board, flags)

	if action == "expanded" then
		popSound:play()

		win = minesweeper.checkWin(mines, board)
	end

	dPrint(action)
	dPrint(board, true)

	love.update(0)
end

function newGame()
	love.audio.pause()

	time = 0
	clockTick = false

	firstClick = true

	action = "new game"
	win = false
	lose = false
	board = {}
	flags = {}
end

function love.load()
	lg = love.graphics
	mouseIsDown = love.mouse.isDown

	--tileSize, boardWidth, boardHeight and headBarSize in conf.lua

	--tile1 = rgb255to1(150, 232, 78)
	--tile2 = rgb255to1(141, 226, 70)
	tile1 = rgb255to1(179, 214, 101)
	tile2 = rgb255to1(172, 208, 94)

	--filledTile1 = rgb255to1(233, 196, 156)
	--filledTile2 = rgb255to1(218, 186, 150)
	filledTile1 = rgb255to1(223, 195, 163)
	filledTile2 = rgb255to1(210, 185, 157)

	highlightColor = {1, 1, 1, 0.25}
	mineHightlight = rgb255to1(11, 11, 22, 0.3)

	numberColor = {
		rgb255to1(35 , 95 , 213),  -- 1
		rgb255to1(81 , 140, 70 ),  -- 2
		rgb255to1(194, 63 , 56 ),  -- 3
		rgb255to1(139, 0  , 163),  -- 4
		rgb255to1(255, 141, 0  ),  -- 5
		rgb255to1(0  , 150, 171),  -- 6
		rgb255to1(68 , 69 , 70 ),  -- 7
		rgb255to1(135, 145, 164),  -- 8
	}

	--headBarColor = rgb255to1(54, 127, 44)
	headBarColor = rgb255to1(84, 116, 54)

	screenWidth = boardWidth * tileSize
	screenHeight = boardHeight * tileSize + headBarSize

	borderless = true
	fpsCounter = false

	close = {
		x = screenWidth - 20,
		y = screenHeight - (screenHeight - 5),
		hitBoxX = 22,
		hitBoxY = 22,
	}
	minimize = {
		x = screenWidth - 45,
		y = screenHeight - (screenHeight - 5),
		hitBoxX = 26,
		hitBoxY = 30,
	}

	fontUI = lg.newFont(20)
	fontTitleDetails = lg.newFont(24)
	fontEndScreen = lg.newFont(36)
	fontNumber = lg.newFont("font/Roboto-Black.ttf", 25)

	flagImg = lg.newImage("assets/flag.png")
	flagSpacingX, flagSpacingY = 5, 5
	flagScale = 0.12

	flagSound = love.audio.newSource("assets/flag.mp3", "static")
	popSound = love.audio.newSource("assets/pop.mp3", "static")

	winSong = love.audio.newSource("assets/win.wav", "static")

	lg.setBackgroundColor(headBarColor)

	newGame()
end

function love.update(dt)
	local x, y = love.mouse.getPosition()

	selectedTile = {
		x = math.floor(x/tileSize),
		y = math.floor((y - headBarSize)/tileSize),
	}

	if clockTick then
		time = math.floor(love.timer.getTime() - startTime)
	end

	if not borderless then
		love.window.setTitle("Minesweeper | " ..
			"Flags: " .. numOfMines - #flags .. " | " ..
			"Time: " .. time
		)
	end

	if action == "mine" then
		lose = true
	end
end

function love.keyreleased(key)
	if key == "r" then
		newGame()
		
	elseif key == "f" then
		fpsCounter = not fpsCounter

	elseif key == "m" then
		if love.audio.getVolume() == 0 then
			love.audio.setVolume(1)
		else
			love.audio.setVolume(0)
		end

	end
end

function love.mousepressed(mx, my, button)
	-- Close Button
	if inRectangle(mx, my, close.x, close.y,
					close.hitBoxX, close.hitBoxY) then

		love.event.quit(0)
	end

	-- Minimize Button
	if inRectangle(mx, my, minimize.x, minimize.y,
					minimize.hitBoxX, minimize.hitBoxY) then

		love.window.minimize()
	end

	if button == 3 and inRectangle(mx, my, 0, 0, screenWidth, headBarSize) then
		borderless = not borderless

		local width, height, settings = love.window.getMode()

		settings.borderless = borderless

		love.window.setMode(width, height, settings)
	end

	if win or lose then
		return
	end

	if firstClick and button == 1 then
		board, mines, e = minesweeper.createBoard(selectedTile.x + 1,
												  selectedTile.y + 1,
												  boardWidth, boardHeight, numOfMines)

		if e then
			dPrint("Error(" .. e.val .. "): " .. e.msg )
		else
			dPrint(board, true)

			firstClick = false
			clockTick = true
			
			startTime = love.timer.getTime()

			popSound:play()
		end

		return
	end

	if firstClick then return end

	if button == 1 then
		expand(selectedTile.x + 1, selectedTile.y + 1)

	elseif button == 2 then
		flags, err = minesweeper.flag(selectedTile.x + 1,
									  selectedTile.y + 1,
									  board, flags)

		if not err then
			flagSound:play()
		end

	end
end

function love.draw()

	if borderless then
		TitleDetails = "Flags: " .. numOfMines-#flags .. "         Time: " .. time

		lg.setFont(fontTitleDetails)

		local width = fontTitleDetails:getWidth(TitleDetails) 
		local height = fontTitleDetails:getHeight(TitleDetails)

		local locationX = screenWidth / 2 - width / 2
		local locationY = headBarSize / 2 - height / 2

		lg.print(TitleDetails, locationX, locationY)
	end

	for i = 0, boardWidth do
		for j = 0, boardHeight do

			if (i + j) % 2 == 0 then
				lg.setColor(tile1)
			else
				lg.setColor(tile2)
			end

			lg.rectangle("fill", i * tileSize,
											headBarSize + (j * tileSize),
											tileSize, tileSize)
		end
	end

	for j, list in ipairs(board) do
		for i, item in ipairs(list) do
			if not contains(item, {"-", "M"}) then
				tileLocationX = (i - 1) * tileSize
				tileLocationY = headBarSize + ((j - 1) * tileSize)

				if (i + j) % 2 == 0 then
					lg.setColor(filledTile1)
				else
					lg.setColor(filledTile2)
				end

				lg.rectangle("fill", tileLocationX, tileLocationY,
											tileSize, tileSize)

				currentNumberColor = numberColor[item]

				if currentNumberColor then
					lg.setColor(currentNumberColor)

					textWidth = fontNumber:getWidth(item)
					textHeight = fontNumber:getHeight(item)

					lg.setFont(fontNumber)
					lg.print(item,
						tileLocationX + (tileSize/2 - textWidth/2),
						tileLocationY + (tileSize/2 - textHeight/2))
				end

			end
		end
	end

	lg.setColor(numberColor[3])
	for _, flag in ipairs(flags) do
		flagLocationX = (flag[1] - 1) * tileSize + flagSpacingX
		flagLocationY = headBarSize + ((flag[2] - 1) * tileSize) + flagSpacingY

		lg.draw(flagImg, flagLocationX , flagLocationY, 0, flagScale)
	end

	if not (selectedTile.y < 0) and not (win or lose) and not firstClick then
		lg.setColor(highlightColor)

		if mouseIsDown(3) or (mouseIsDown(1) and mouseIsDown(2)) then

			local numberOfFlags = 0
			for _, area in ipairs(circularArea) do
				currentX = (selectedTile.x - area[1] + 1)
				currentY = (selectedTile.y - area[2] + 1)

				if currentX >= 0 and currentY >= 0 then
					if containsTable({currentX, currentY}, flags) then
						numberOfFlags = numberOfFlags + 1
					end
				end
			end

			if inRange(selectedTile.x + 1, 1, #board[1])
			and inRange(selectedTile.y + 1, 1, #board) then
				press = ( -- Used () to split into multiple lines
					board[selectedTile.y + 1][selectedTile.x + 1] == numberOfFlags
				)
			end

			for _, area in ipairs(circularArea) do

				highlightX = (selectedTile.x - area[1])
				highlightY = (selectedTile.y - area[2])

				if press then
					expand(highlightX + 1, highlightY + 1)

				elseif highlightX >= 0 and highlightY >= 0 then
					

					if inRange(highlightX + 1, 1, #board[1]) 
					and inRange(highlightY + 1, 1, #board) then
						currentSpace = board[highlightY + 1][highlightX + 1]

					else currentSpace = "" end

					if currentSpace == "-" or currentSpace == "M" and 
					not containsTable({highlightX + 1, highlightY + 1}, flags) then

						lg.rectangle("fill", highlightX * tileSize,
											 highlightY * tileSize + headBarSize,
											 tileSize, tileSize)
					end

				end
			end
		end

		lg.rectangle("fill", selectedTile.x * tileSize,
					selectedTile.y * tileSize + headBarSize,
					tileSize, tileSize)
	end
	
	if win or lose then
		clockTick = false

		if lose then
			textWidth = fontNumber:getWidth("M")
			textHeight = fontNumber:getHeight("M")

			lg.setColor(mineHightlight)
			lg.setFont(fontNumber)
			for i, mine in ipairs(mines) do

				tileLocationX = (mine[1] - 1) * tileSize
				tileLocationY = headBarSize + ((mine[2] - 1) * tileSize)

				lg.print("M",
					tileLocationX + (tileSize/2 - textWidth/2),
					tileLocationY + (tileSize/2 - textHeight/2))
			end
		
			grayout("You Lost in " .. time .." seconds\n" ..
			"Press R to Restart")
		elseif win then
			grayout("You Won!!\nIt Took you " .. time .." seconds\n" ..
			"Press R to Restart")

			winSong:play()
		end
	end

	lg.setColor(1, 1, 1)

	if borderless then
		lg.setFont(fontUI)
		lg.print("x", close.x, close.y)
		lg.print("_", minimize.x, minimize.y - 5)
	end

	if fpsCounter then
		lg.setFont(lg.newFont(18))
		lg.print("FPS: " .. love.timer.getFPS(), 1,1)
	end
end