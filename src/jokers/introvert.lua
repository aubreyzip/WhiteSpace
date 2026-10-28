SMODS.Joker({
    key = 'introvert',
    atlas = 'aws_placeholders',
    pos = { x = 0, y = 0 },

    rarity = 1,
    cost = 4,

    loc_txt = {
        name = 'Introvert',
        text = {
            'At {C:attention}first played hand{} each round,',
            'destroy a random',
            '{C:attention}non-scoring card{}'
        }
    },

    config = {
        extra = {
            triggered = false
        }
    },

    calculate = function(self, card, context)
        if context.after
            and context.main_eval
            and not context.blueprint
            and not card.ability.extra.triggered then

            card.ability.extra.triggered = true

            local unscored = {}

            for _, playing_card in ipairs(context.full_hand or {}) do
                local scored = false

                for _, scoring_card in ipairs(context.scoring_hand or {}) do
                    if playing_card == scoring_card then
                        scored = true
                        break
                    end
                end

                if not scored then
                    unscored[#unscored + 1] = playing_card
                end
            end

            if #unscored > 0 then
                local target = pseudorandom_element(
                    unscored,
                    pseudoseed('aws_introvert')
                )

                SMODS.destroy_cards(target, {
                    bypass_eternal = true,
                    delay = 0.2
                })

                return {
                    message = 'Gone!',
                    colour = G.C.RED
                }
            end
        end

        if context.end_of_round and context.main_eval then
            card.ability.extra.triggered = false
        end
    end
})