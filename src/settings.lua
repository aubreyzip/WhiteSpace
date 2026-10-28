local mod = SMODS.current_mod

-- Uses original_mod so a Joker another mod takes ownership of still counts as ours
local function is_white_space_joker(center)
    return center.set == 'Joker' and (center.original_mod or center.mod) == mod
end

-- Jokers stay registered either way. Shops, packs, Judgement, Riff-raff, The Soul,
-- tags and other pool rolls all check in_pool, so disabling only stops new copies
-- from being generated; owned Jokers keep working
for _, center in pairs(SMODS.Centers) do
    if is_white_space_joker(center) and not center.aws_pool_gated then
        local in_pool = center.in_pool
        center.in_pool = function(self, args)
            if not mod.config.jokers_enabled then return false end
            if in_pool then return in_pool(self, args) end
            return true
        end
        center.aws_pool_gated = true
    end
end

local discover_status = { text = '' }

-- Mirrors vanilla discover_card, minus its seeded run check and run stats
G.FUNCS.aws_discover_jokers = function(e)
    local total, discovered = 0, 0
    for _, center in pairs(G.P_CENTERS) do
        if is_white_space_joker(center) and not center.wip then
            total = total + 1
            if not center.discovered then
                center.discovered = true
                center.alert = true
                discovered = discovered + 1
            end
        end
    end

    if discovered > 0 then
        set_discover_tallies()
        G:save_progress()
    end

    discover_status.text = localize({
        type = 'variable',
        key = discovered > 0 and 'aws_discover_done' or 'aws_discover_none',
        vars = { discovered, total }
    })
    play_sound('holo1', 1.2)
end

local function save_and(func)
    return function()
        SMODS.save_mod_config(mod)
        if func then func() end
    end
end

mod.config_tab = function()
    discover_status.text = ''
    return {
        n = G.UIT.ROOT,
        config = { emboss = 0.05, minh = 6, r = 0.1, minw = 6, align = 'cm', padding = 0.2, colour = G.C.BLACK },
        nodes = {
            create_toggle({
                label = localize('aws_config_menu_theme'),
                info = localize('aws_config_menu_theme_info'),
                ref_table = mod.config,
                ref_value = 'custom_menu_theme',
                callback = save_and(mod.refresh_main_menu)
            }),
            create_toggle({
                label = localize('aws_config_menu_animation'),
                info = localize('aws_config_menu_animation_info'),
                ref_table = mod.config,
                ref_value = 'menu_animation',
                callback = save_and(mod.refresh_main_menu)
            }),
            create_toggle({
                label = localize('aws_config_menu_music'),
                info = localize('aws_config_menu_music_info'),
                ref_table = mod.config,
                ref_value = 'custom_menu_music',
                callback = save_and()
            }),
            create_toggle({
                label = localize('aws_config_jokers'),
                info = localize('aws_config_jokers_info'),
                ref_table = mod.config,
                ref_value = 'jokers_enabled',
                callback = save_and()
            }),
            UIBox_button({
                label = { localize('aws_config_discover') },
                button = 'aws_discover_jokers',
                colour = G.C.BLUE,
                minw = 5,
                scale = 0.4
            }),
            {
                n = G.UIT.R,
                config = { align = 'cm', minh = 0.3 },
                nodes = {
                    { n = G.UIT.T, config = { ref_table = discover_status, ref_value = 'text', scale = 0.3, colour = G.C.UI.TEXT_LIGHT } }
                }
            }
        }
    }
end
