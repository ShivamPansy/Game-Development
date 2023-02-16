-- love.load, love.update(dt), love.draw(), 
-- love.graphics.printf(text, x, y, [width], [align]) -- draws 
-- love.window.setMode(width, height, params)


-- love.graphics.setDefaultFilter(min, max)
-- love.keypressed(key)
-- love.event.quit()


-- love.graphics.newFont(path, size)
-- love.graphics.setFont(font)
-- love.graphics.clear(r, g, b, a)
-- love.graphics.rectangle()

-- push is a library that allows game to be drawn at a vir
-- rersolution, instead of however large our window is


-- love.keyboard.isDown()
-- love.audio.newSource(path)

Class = require 'class'

require 'Paddle'

require 'Ball'

push = require 'push'

WINDOW_WIDTH = 1200
WINDOW_HEIGHT = 800

VIRTUAL_HEIGHT = 400
VIRTUAL_WIDTH = 450

PADDLE_SPEED = 180

function love.load()
    -- love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
    --     fullscreen = false,
    --     vsync = true
    -- })

    love.window.setTitle('Pong')

    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    sound = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static'),
        ['win'] = love.audio.newSource('win.wav', 'static')
    }

    smallFont = love.graphics.newFont('RatsCollege.ttf', 8)
   
    scoreFont = love.graphics.newFont('RatsCollege.ttf', 22)

    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true
    })

    player1Score = 0
    player2Score = 0

    player1 = Paddle(10, 30, 4, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 4, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = 'start'

end

function love.update(dt)

    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(100, 160)
        else
            ball.dx = -math.random(100, 160)
        end
    end

    -- player1 movement
    
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED--up is negative in lua
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else 
        player1.dy = 0
    end

    -- player2 movement
    if love.keyboard.isDown('p') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('l') then
        player2.dy = PADDLE_SPEED
    else 
        player2.dy = 0
    end

    if gameState == 'play' then
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.06
            ball.x = ball.x + 4
            sound['paddle_hit']:play()

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            player1Score = player1Score + 1
        end


        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.06
            ball.x = ball.x - 4
            sound['paddle_hit']:play()

            if ball.dy <= 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            player2Score = player2Score + 1
        end

        if ball.y >= VIRTUAL_HEIGHT - ball.height - 10 then
            sound['wall_hit']:play()
            ball.y = VIRTUAL_HEIGHT - ball.height - 10
            ball.dy = -ball.dy 
        end 

        if ball.y <= 30 then
            sound['wall_hit']:play()
            ball.y = 30
            ball.dy = -ball.dy
        end

    end 

    if gameState == 'play' then
        ball:update(dt)
    end

    if ball.x < 0 then
        servingPlayer = 1
        gameState = 'serve'
        ball:reset()
        sound['wall_hit']:play()
    end

    if ball.x + ball.width >= VIRTUAL_WIDTH then
        servingPlayer = 2
        ball:reset()
        gameState = 'serve'
        sound['wall_hit']:play()
    end

    if player1Score == 20 then
        gameState = 'done'
        ball:reset()
        player1Score = 0
        player2Score = 0
        winningPlayer = 1
        sound['win']:play()
    end

    if player2Score == 20 then
        gameState = 'done'
        ball:reset()
        player1Score = 0
        player2Score = 0
        winningPlayer = 2
        sound['win']:play()
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
    -- love.graphics.printf(
    --     'You there',
    --     0,
    --     WINDOW_HEIGHT / 2 - 6,
    --     WINDOW_WIDTH,
    --     'right'
    -- )
    --begins rendering at virtual resolution
    push:apply('start')
     
    -- love.graphics.clear(40,45,52,125)

    love.graphics.printf(
        'Welcome to Pong',
        4,
        0,
        VIRTUAL_WIDTH,
        'center'
    )

    love.graphics.setFont(scoreFont)

    -- player1 score
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 150, 5)

    -- player2 score
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 150, 5)

    -- player1 
    player1:render()

    player2:render()

    ball:render()

    if gameState == 'done' then
        love.graphics.printf('Player' .. tostring(winningPlayer) .. ' wins', VIRTUAL_WIDTH / 2 - 200, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press enter to start the game..', VIRTUAL_WIDTH / 2 - 200, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
    end

    

    --ends rendering at virtual resolution
    push:apply('end')
end


