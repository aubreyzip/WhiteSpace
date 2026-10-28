local mod = SMODS.current_mod

SMODS.Sound({
    key = "music_main_theme",
    path = "aws_main_theme.ogg",
    volume = 0.6,
    pitch = 1,
    -- Returning nil hands the main menu back to vanilla's music
    select_music_track = function(self)
        if G.STAGE == G.STAGES.MAIN_MENU and mod.config.custom_menu_music then
            return 100
        end
        return nil
    end
})