local mod = SMODS.current_mod

-- The theme only swaps inputs of vanilla's splash shader, so turning it off
-- (even while on the main menu) leaves vanilla's background exactly as it was
local function refresh_background()
    local back = G.SPLASH_BACK
    local vanilla = back and back.aws_vanilla_step
    if not vanilla then return end

    local themed = mod.config.custom_menu_theme
    local static = themed and not mod.config.menu_animation

    local send = {}
    for i, v in ipairs(vanilla.send) do
        if themed and v.name == 'colour_1' then
            v = { name = 'colour_1', ref_table = G.C, ref_value = 'WHITE' }
        elseif themed and v.name == 'colour_2' then
            v = { name = 'colour_2', ref_table = G.C, ref_value = 'BLACK' }
        elseif static and v.name == 'time' then
            -- Same frozen time vanilla uses for its Reduced Motion setting
            v = { name = 'time', val = 300 }
        end
        send[i] = v
    end
    back:define_draw_steps({ { shader = vanilla.shader, send = send } })
end

-- Freezes the animated title card (added through menu_cards) on its first frame
function mod.refresh_title_card()
    if not G.title_top then return end
    for _, card in ipairs(G.title_top.cards) do
        local sprite = card.mod_flag == mod.id and card.children.center
        if sprite and sprite.current_animation then
            if mod.config.menu_animation then
                sprite.animate = nil
            elseif not rawget(sprite, 'animate') then
                sprite:set_sprite_pos(sprite.sprite_pos)
                sprite.animate = function() end
            end
        end
    end
end

-- Applies the current settings to the main menu that is already on screen
function mod.refresh_main_menu()
    if G.STAGE ~= G.STAGES.MAIN_MENU then return end
    refresh_background()
    mod.refresh_title_card()
end

local original_main_menu = Game.main_menu

function Game:main_menu(change_context)
    -- Create the normal Balatro main menu first
    original_main_menu(self, change_context)

    -- Remember vanilla's background so the theme can be turned off again
    local step = G.SPLASH_BACK and G.SPLASH_BACK.draw_steps and G.SPLASH_BACK.draw_steps[1]
    if step and step.shader == 'splash' then
        G.SPLASH_BACK.aws_vanilla_step = { shader = step.shader, send = step.send }
        refresh_background()
    end
end
