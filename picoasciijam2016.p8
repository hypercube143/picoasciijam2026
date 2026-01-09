pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--1337 420 8)
-- vorp

-- notes
--[[
screen is 128 px hence 16 by 16 no, 5,6, 20 25
glyph is 6x5
--]]


-- TEMP THINGS


-- DEBUG THINGS
debug = "debug: "
debugCollisions = true

-- GAME THINGS
t = 0
--entities = {} -- eg collidable
map_tiles = {} -- eg collidable

function _init()
    t = 0
    CURR_SCENE = startMenu()
end

function _update60()
   CURR_SCENE.update()
   print(debug, 2, 2, 7)
end

function _draw()
    cls()
    debug = "debug: "
    
    CURR_SCENE.draw()

    --- DEBUG PRINT
    --debug = debug .. "aaa"
    print(debug, 2, 2, 7)

end

----- PLAYER
function newPlayer(x, y)
    local texture = {
            s("🐱", 7, 0, 0, 0, 4, "head"),
            s("웃", 7, 0, 1, 0, 0, "body"),
            s("L", 6, 0, 1, -1, -1, "tail")
        }
    return{
        -- str = " 🐱\n(웃",
        -- col = 7,
        spr = co(x, y, 8, 8, texture, "player"),
        x = x,
        y = y,
        speed = 1,
        draw = function() 
            p.spr.draw(p.x, p.y)
        end,
        update = function()
            movePlayer()
            -- check if player colliding - potentially make this a list and for loop later? DONE IN LEVEL_ONE
            p.spr.collisionCheck(weed_tree)
        end,

        
    }
end


function movePlayer()
    if btn(⬅️) then 
        p.x -= p.speed 
    end
    if btn(➡️) then 
        p.x += p.speed 
    end
    if btn(⬆️) then 
        p.y -= p.speed 
    end
    if btn(⬇️) then 
        p.y += p.speed 
    end
end

---- LEVELS
function startMenu()
    return{
        update = function()
            if btn(❎) then CURR_SCENE = levelOne() end
        end,
        draw = function() 
            print("press x")
        end
    }
end


function levelOne()
    -- init occurs once level is loaded, hence no funciton:
    p = newPlayer(50, 50)
    bar = newBar()
    t = 0
    entities = initEntities()
    return{
        update = function()
            p.update()
            t += 1
            -- generate platform every 100 ticks
            if (t + 99) % 100 == 0 then
                x = flr(rnd(16)) * 8
                newPlatform = platformCo(x, 20, 3, 11)
                map_tiles[#map_tiles + 1] = newPlatform 
            end

            checkPlayerCollision(map_tiles)
            checkPlayerCollision(entities)

        end,
        draw = function()
            drawGrid("❎", "♥")
            
            

            p.draw()
            --weed_tree.draw(90, 90)
            bar.draw()
            toCorrupt()
            ---
            --debug = debug .."tick: " .. t

            
            -- draw corruption every frame, update every 10th
            -- if t % 10 == 0 then
            --     updateCorruption(t * 0.0025)
            -- end
            -- drawCorruption()

            -- draw all map tile collidables
            for collidable in all(map_tiles) do
                collidable.draw(collidable.x, collidable.y)
            end

            drawEntities()
            debug = debug .. tostr(#entities)           
        end
    }
end

function initEntities()
    return {weed(60, 60)}
end

function drawEntities()
    for e in all(entities) do
        e.draw(e.x, e.y)
    end
end

function weed(x, y)
    --str, colour, x, y, offX, offY, id
    w = {s("★", 11, 0, 0, 0, 0, "weed")}
    --x, y, w, h, texture, id
    return co(x, y, -1, -1, w, "weed")
end


function checkPlayerCollision(collidables)
-- check every collidable collisions against the player's from a list of collidables
    for collidable in all(collidables) do
        debug = tostr(p.spr.collisionCheck(collidable))
        if p.spr.collisionCheck(collidable) then
            -- if debug collisions, sprites turn yellow and pink when collision happens
            if debugCollisions then
                p.spr.colour = 10
                collidable.colour = 14
                sfx(0)
                --
                if collidable.id == "weed" then
                    del(entities, collidable)
                    bar.increaseHighness()
                end
                --
            end
            debug = debug .. "PLAYER COLLIDED WITH '" .. collidable.id .. "'!"
        else
            debug = "PLAYER NOT COLLIDED WITH ANYTHING"
        end
    end
end


-- draw corruption every frame, update every 10th
-- should only happen on threshold reached
function toCorrupt()
    -- 5 weeds to bar and flash
    if bar.level <= 2 then 
        if t % 10 == 0 then
            updateCorruption(t * 0.0025)
         end
        drawCorruption()
    end
end

function newBar()
    return{
        x = 120,
        y = 0,
        level = 2,
        max_level = 10,
        update = function() end,
        draw = function() 
            -- grey background
            pad = 10
            for i = 0, 9 do
                -- should be grey as default
                if bar.max_level-i > bar.level then
                    drawGlyphWithBorder("★", 6, "★", 5, bar.x, 2 + bar.y + i*pad)
                else
                -- and green up to bar level
                    drawGlyphWithBorder("★", 3, "★", 11, bar.x, 2 + bar.y + i*pad)
                end
            end
        end,

        increaseHighness = function()
            if bar.level < bar.max_level then
                bar.level += 1
            end
        end

    }
end

-- FOR STRINGS
function drawGlyphWithBorder(border, col1, inner, col2, x, y)
    for xOff = -1, 1 do
        for yOff = -1, 1 do
            print(border, x + xOff, y + yOff, col1)
        end
    end
    print(inner, x, y, col2)
end

-- FOR COs
function drawBorder(borderShape, innerShape)
    local b = borderShape
    local i = innerShape
    for xOff = -1, 1 do
        for yOff = -1, 1 do
            b.draw(b.x + xOff, b.y + yOff)
        end
    end
    i.draw(i.x, i.y)
end



function drawGrid(border, fill)
    -- this for loop makes the game super laggy!???
    -- print(border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. "\n", 0, 0, 7)
    -- for i = 0, 14 do
    --     print(border .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. border .. "\n")
    -- end
    -- print(border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. "\n")

    outer_row = border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. border .. "\n"
    inner_row = border .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. fill .. border .. "\n"
    
    print(outer_row ..
    inner_row ..
    inner_row .. 
    inner_row ..
    inner_row .. 
    inner_row ..
    inner_row .. 
    inner_row ..
    inner_row .. 
    inner_row ..
    inner_row .. 
    inner_row ..
    inner_row .. 
    inner_row ..
    inner_row ..    
    --
    inner_row ..
    inner_row .. 
    inner_row ..
    inner_row ..
    inner_row ..
    --
    outer_row
    , 0, 0, 5)

end
-----

function s(str, colour, x, y, offX, offY, id)
    return {
        str = str, colour = colour,
        w = 8, h = 8,
        x = x, y = y,
        offX = offX, offY = offY,
        globalX = x, globalY = y,
        id = id,
    }
end


-- texture
-- function t(sprite, pos)
--     return {
--         sprite = sprite, pos = pos
--     }
-- end


-- collisionObject
function co(x, y, w, h, texture, id) 
    return {
        x = x, y = y, w = w, h = h,
        texture = texture,
        id = id,
        -- draw texture to screen based on x, y pos
        draw = function(x, y)
            x = x
            y = y
            for sprite in all(texture) do
                sprite_x = x + sprite.w * sprite.x
                sprite_y = y + sprite.h * sprite.y
                sprite.globalX = sprite_x
                sprite.globalY = sprite_y
                -- display red box around collisions if debugging mode active
                if debugCollisions then
                    rect(sprite_x, sprite_y, sprite_x + sprite.w, sprite_y + sprite.h, 8)
                end
                -- +2 is just to center sprite texture with collision box
                print(sprite.str, sprite_x + sprite.offX, sprite_y + sprite.offY, sprite.colour)
            end

        end,
        -- update collisions
        collisionCheck = function(other)
            collides = false
            for sprite in all(texture) do 
                for otherSprite in all(other.texture) do

                    l1 = sprite.globalX
                    t1 = sprite.globalY
                    r1 = sprite.globalX + sprite.w
                    b1 = sprite.globalY + sprite.h

                    l2 = otherSprite.globalX
                    t2 = otherSprite.globalY
                    r2 = otherSprite.globalX + otherSprite.w
                    b2 = otherSprite.globalY + otherSprite.h

                    collides = (l1<r2 and r1>l2) and (t1<b2 and b1>t2)
                    
                    if collides then
                        -- if debugCollisions then
                        --     sprite.colour = 10
                        --     otherSprite.colour = 14
                        -- end
                        return true
                    end
                end
            end
            return false
        end,
        update = function() end
    }
end



-- COLLISION OBJECTS
weed_tree = co(0, 0, 0, 0,
    {
        s("★", 11, 1, 1, 1, -2, "weed"),
        s("★", 11, 0, 1, 3, 3, "weed"),
        s("★", 11, 1, 1, 1, 3, "weed"),
        s("★", 11, 2, 1, -1, 3, "weed"),
        s("★", 11, 1, 2, 1, 2, "weed"),
    },
    "weed_tree"
)

function platformCo(x, y, length, colour)
    -- add left platform edge
    texture = {s("▒", colour, 0, 0, 1, 2, "platform_edge_left")}
    -- length of a platform must be at least 1
    if length == 1 then
        return co(x, y, 0, 0, texture, "platform")
    end
    -- add middle section
    i = 1
    for i = 1, length - 2, 1 do
        texture[#texture + 1] = s("▤", colour, i, 0, 1, 2, "platform_middle")
    end
    -- add right platform edge
    texture[#texture + 1] = s("▒", colour, i + 1, 0, 1, 2, "platform_edge_right")
    return co(x, y, 0, 0, texture, "platform")
end





corrWidth = 21
corrHeight = 26
corrGlyphArray = {}
-- overlay that obscures player's vision
-- level from 0-1
function updateCorruption(level)

    if level > 1.0 then
        level = 1.0
    end
    
    corrGlyphArray = {}
    totalGlyphs = corrWidth * corrHeight
    glyphCount = flr(((totalGlyphs) * level) + 0.5)
    chars = "▒░●◆▤▥🐱✽♥☉웃⌂😐♪★⧗"
    --chars = "😐🐱"

    corrGlyphArray = {}

    -- add glyphs
    for i = 1, glyphCount do
        corrGlyphArray[#corrGlyphArray + 1] = chars[flr(rnd(#chars)) + 1]
    end

    -- add empty
    for i = 1, totalGlyphs - glyphCount do
        corrGlyphArray[#corrGlyphArray + 1] = ""
    end

    -- shuffle
    for i = #corrGlyphArray, 2, -1 do
        j = flr(rnd(i)) + 1
        corrGlyphArray[i], corrGlyphArray[j] = corrGlyphArray[j], corrGlyphArray[i]
    end
end

function drawCorruption()
    xMod = 0
    yMod = 0
    spacer = 6
    spacerY = 5
    n = 1
    -- draw grid of glyphs
    for i = 1, corrHeight, 1 do
        for j = 1, corrWidth, 1 do
            char = corrGlyphArray[n]
            -- print only if non empty glyph
            if char != "" then
                print(char, xMod, yMod, 7)
            end
            n += 1
            xMod += spacer
        end
        xMod = 0
        yMod += spacerY
    end
end

-- function AABB(t1, t2)
--     l1, t1, r1, b1 = unpack(t1)
--     l2, t2, r2, b2 = unpack(t2)
--     return (l1<r2 and r1>l2) and (t1<b2 and b1>t2)
-- end

--[[
Buttons
\code - symbol - name

\131 - ⬇️ - Down Key
\139 - ⬅️ - Left Key
\145 - ➡️ - Right Key
\148 - ⬆️ - Up Key
\142 - 🅾️ - O Key
\151 - ❎ - X Key
Symbols
\code - symbol - name

\16 - ▮ - Vertical rectangle
\17 - ヌ∧て - Horizontal rectangle
\18 - Horizontal half filled rectangle?
\22 - ◀ - Back
\23 - ▶ - Forward
\24 -「 - Japanese starting quote
\25 - 」- Japanese ending quote
\28 - 、- Japanese comma
\29 - ヌ∧ち - Small square (bigger than a pixel)
\31 - ⁘ - Four dots
\128 - ■ - Square
\129 - ▒ - Checkerboard
\132 - ░ - Dot pattern
\134 - ● - Ball
\143 - ◆ - Diamond
\144 - .... - Ellipsis
\152 - ▤ - Horizontal lines
\153 - ▥ - Vertical lines
Emojis
\code - symbol - name

\130 - 🐱 - Cat
\133 - ✽ - Throwing star
\135 - ♥ - Heart
\136 - ☉ - Eye (kinda)
\137 - 웃 - Man
\138 - ⌂ - House
\140 - 😐 - Face
\141 - ♪ - Musical note
\146 - ★ - Star
\147 - ⧗ - Hourglass
\149 - ˇˇ - Birds
\150 - ∧∧ - Sawtooth
--]]

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000d0500f05010050120501405017050190501d0501f050210503405024050250502705028050290502a0502b0502d0502d0502e0502e0502e050070500605005050050500605009050150500000000000
