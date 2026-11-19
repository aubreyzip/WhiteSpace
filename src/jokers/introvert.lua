SMODS.Joker({
    key = 'introvert',
    atlas = 'aws_placeholders',
    pos = { x = 0, y = 0 },

    rarity = 1,
    cost = 4,

    blueprint_compat = true,

    calculate = function(self, card, context)
        if context.blueprint or G.GAME.current_round.hands_played ~= 0 then
            return
        end

        if context.before and not context.retrigger_joker then
            local unscored = {}
            for _, playing_card in ipairs(context.full_hand or {}) do
                if not SMODS.in_scoring(playing_card, context.scoring_hand) then
                    unscored[#unscored + 1] = playing_card
                end
            end

            card.aws_introvert_target = (#unscored > 0)
                and pseudorandom_element(unscored, pseudoseed('aws_introvert'))
                or nil
        end

        if context.destroy_card
            and context.cardarea == 'unscored'
            and context.destroy_card == card.aws_introvert_target then

            card.aws_introvert_target = nil
            return {
                remove = true,
                message = 'Gone!',
                colour = G.C.RED
            }
        end
    end
})
