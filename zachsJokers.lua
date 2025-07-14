--- STEAMODDED HEADER
--- MOD_NAME: Zachs Jokers
--- MOD_ID: zachs_jokers
--- MOD_AUTHOR: [zach]
--- MOD_DESCRIPTION: Jokers finished and not finished (art credit mooshe10)
--- BADGE_COLOUR: c20000

----------------------------------------------
------------MOD CODE -------------------------

--- Config ---
local config = {
    j_zach_steak = true,
    j_zach_lessMore = true,
    j_zach_luckier = true,
    j_zach_oneWizard = true,
    j_zach_arch = true,
    j_zach_gamble = true,
    j_zach_dogTag = true,
    j_zach_gameShow = true,
    j_zach_emptyHand = true,
    j_zach_callIt = true,
    j_zach_overkill = true,
    j_zach_TAC = true,
    j_zach_ducky = true,
    j_zach_CR45H = true,
    j_zach_clown = true,
    j_zach_DON = true,
    j_zach_offhand = true,

    j_zach_chaos = false, --Works but needs a major change
    
    j_zach_trash = true,
    j_zach_trashCan = true,


    j_zach_jimbo = false,
    --j_zach_carAccident = true,
    --j_zach_loanShark = true,
}

--- Functions ---

    

--- Registering modded Jokers ---
function register_elem(id, no_sprite)
    new_id_slug = id.slug

    if new_id_slug:sub(1, 1) == "j" and not no_sprite then
        local sprite = SMODS.Sprite:new(
            id.slug,
            SMODS.findModByID("zachs_jokers").path,
            new_id_slug .. ".png",
            71,
            95,
            "asset_atli"
        )

        id:register()
        sprite:register()
    else
        id:register()
    end
end



function SMODS.INIT.zachs_jokers() 

    init_localization()

    local Backapply_to_runRef = Back.apply_to_run
    function Back.apply_to_run(arg_56_0)
        Backapply_to_runRef(arg_56_0)

        if arg_56_0.effect.config.polystone then
            G.E_MANAGER:add_event(Event({
                func = function()
                    for iter_57_0 = #G.playing_cards, 1, -1 do
                        sendDebugMessage(G.playing_cards[iter_57_0].base.id)

                        G.playing_cards[iter_57_0]:set_ability(G.P_CENTERS.m_stone)
                        G.playing_cards[iter_57_0]:set_edition({
                            polychrome = true
                        }, true, true)
                        G.playing_cards[iter_57_0]:set_seal("Red", true, true)
                    end

                    return true
                end
            }))
        end
    end

    local loc_def = {
        ["name"]="The Mountain Deck",
        ["text"]={
            [1]="Start with a Deck",
            [2]="full of",
            [3]="{C:attention,T:e_polychrome}Poly{}{C:red,T:m_stone}stone{} cards"
        },
    }

    local mountain = SMODS.Deck:new("The Mountain", "mountain", {polystone = true}, {x = 0, y = 3}, loc_def)
    mountain:register()

    --- Steak

    if config.j_zach_steak then

        local j_zach_steak = SMODS.Joker:new(
            "Steak", "zach_steak",
            {extra = {Xmult=4, decay=.5}}, {x=0, y=0},
            {
                name = "Steak",
                text = {
                    "{X:mult,C:white}X#1#{} Mult",
                    "{X:mult,C:white}-#2#{} per round",
                    "played",
                }
            }, 3, 6, true, true, true, false
        )

        register_elem(j_zach_steak)

        SMODS.Jokers.j_zach_steak.loc_def = function(card)
            return {card.ability.extra.Xmult, card.ability.extra.decay}
        end

        SMODS.Jokers.j_zach_steak.calculate = function(card, context)
            if context.end_of_round and not (context.individual or context.repetition or context.blueprint) then
                if card.ability.extra.Xmult - card.ability.extra.decay <= 1 then 
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('tarot1')
                            card.T.r = -0.2
                            card:juice_up(0.3, 0.4)
                            card.states.drag.is = true
                            card.children.center.pinch.x = true
                            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                                func = function()
                                        G.jokers:remove_card(card)
                                        card:remove()
                                        card = nil
                                    return true; end})) 
                            return true
                        end
                    })) 
                    return {
                        message = localize('k_eaten_ex'),
                        colour = G.C.RED
                    }
                else
                    card.ability.extra.Xmult = card.ability.extra.Xmult - card.ability.extra.decay
                    return {
                        message = localize{type='variable',key='a_xmult_minus',vars={card.ability.extra.decay}},
                        --message = card.ability.extra.decay..'',
                        colour = G.C.RED
                    }
                end
            elseif SMODS.end_calculate_context(context) then
                return {
                    ---localize{type='variable',key='a_xmult',vars={self.ability.extra.Xmult}},
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.Xmult}},
                    Xmult_mod = card.ability.extra.Xmult
                }
            end
        end
    end

    --- Less is More

    if config.j_zach_lessMore then

        local j_zach_lessMore = SMODS.Joker:new(
            "lessMore", "zach_lessMore",
            {h_size = -2, extra = {Xmult = 2}}, {x=0, y=0},
            {
                name = "Less is More",
                text = {
                    "{C:attention}#1#{} hand size, {X:mult,C:white}X#2#{} Mult",
                }
            }, 2, 4, true, true, true, false
        )

        register_elem(j_zach_lessMore)

        SMODS.Jokers.j_zach_lessMore.loc_def = function(card)
            return {card.ability.h_size, card.ability.extra.Xmult}
        end

        SMODS.Jokers.j_zach_lessMore.calculate = function(card, context)
            if SMODS.end_calculate_context(context) then
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.Xmult}},
                    Xmult_mod = card.ability.extra.Xmult
                }
            end
        end
    end

    --- Luckier Cards

    if config.j_zach_luckier then

        local j_zach_luckier = SMODS.Joker:new(
            "luckier", "zach_luckier",
            {extra = {odds=4, Xmult=2}}, {x=0, y=0},
            {
                name = "Luckier Cards",
                text = {
                    "Lucky cards have a",
                    "{C:green}#1# in #2#{} chance",
                    "for {X:mult,C:white}X#3#{} Mult",
                }
            }, 2, 4, true, true, true, false
        )

        register_elem(j_zach_luckier)

        SMODS.Jokers.j_zach_luckier.loc_def = function(card)
            return {''..(G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odds, card.ability.extra.Xmult}
        end

        SMODS.Jokers.j_zach_luckier.calculate = function(card, context)
            if context.cardarea == G.play then
                if context.individual then
                    if context.other_card.ability.effect == "Lucky Card" and pseudorandom(pseudoseed('lucky')) < G.GAME.probabilities.normal/card.ability.extra.odds then
                        return {
                            x_mult = card.ability.extra.Xmult,
                            card = card
                        }
                    end
                end
            end
        end
    end

    --- oneWizard

    if config.j_zach_oneWizard then

        local j_zach_oneWizard = SMODS.Joker:new(
            "oneWizard", "zach_oneWizard",
            {extra = 3}, {x=0, y=0},
            {
                name = "One Card Wizard",
                text = {
                    "If hand scores as {C:attention}High Card{}",
                    "replay the {C:attention}first{} card",
                    "{C:attention}#1#{} times",
                }
            }, 2, 4, true, true, true, false
        )

        register_elem(j_zach_oneWizard)

        SMODS.Jokers.j_zach_oneWizard.loc_def = function(card)
            return {card.ability.extra}
        end

        SMODS.Jokers.j_zach_oneWizard.calculate = function(card, context)
            if context.repetition and not context.individual and context.cardarea == G.play then
                if context.scoring_name == 'High Card' then
                    if (context.other_card == context.scoring_hand[1]) then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = card.ability.extra,
                        card = card
                    }
                end
                end
            end
        end
    end


    --- Archaeologist

    if config.j_zach_arch then

        local j_zach_arch = SMODS.Joker:new(
            "arch", "zach_arch",
            {extra = 0.1,x_mult=1}, {x=0, y=0},
            {
                name = "Archaeologist",
                text = {
                    "Turns {C:attention}Stone{} cards",
                    "into {C:attention}Rank{} cards",
                    "with a random {C:attention}Edition{}",
                }
            }, 2, 4, true, true, true, false
        )

        register_elem(j_zach_arch)

        SMODS.Jokers.j_zach_arch.loc_def = function(card)
            return {card.ability.x_mult}
        end

        SMODS.Jokers.j_zach_arch.calculate = function(card, context)
            if SMODS.end_calculate_context(context) then
                        for k, v in ipairs(context.scoring_hand) do
                            if v.ability.name == 'Stone Card' and not v.debuff and not v.vampired then 
                                v.vampired = true
                                v:set_ability(G.P_CENTERS.c_base, nil, true)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        local over = false
                                        local edition = poll_edition('aura', nil, true, true)
                                        v:set_edition(edition, true)
                                        v:juice_up(0.3, 0.5)
                                        v.vampired = nil
                                        return true
                                    end
                                }))
                                return{
                                    message = 'Converted!',
                                    colour = G.C.PURPLE,
                                    card = card
                                } 
                            end
                        end
            end
        end
    end
    
    --- Gamble

    if config.j_zach_gamble then

        local j_zach_gamble = SMODS.Joker:new(
            "gamble", "zach_gamble",
            {extra = {odds=2, high=3, low=.5}}, {x=0, y=0},
            {
                name = "Gamble",
                text = {
                    "{C:green}#1# in #2#{} chance",
                    "for {X:mult,C:white}X#3#{} Mult",
                    "or {X:mult,C:white}X#4#{} Mult",
                    "per card scored."
                }
            }, 2, 5, true, true, true, false
        )

        register_elem(j_zach_gamble)

        SMODS.Jokers.j_zach_gamble.loc_def = function(card)
            return {''..(G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odds, card.ability.extra.low, card.ability.extra.high}
        end

        SMODS.Jokers.j_zach_gamble.calculate = function(card, context)
            if context.cardarea == G.play then
                if context.individual then
                    if pseudorandom(pseudoseed('gable')) < G.GAME.probabilities.normal/card.ability.extra.odds then
                        return {
                            x_mult = card.ability.extra.low,
                            card = card,
                        }
                    else
                        return {
                            x_mult = card.ability.extra.high,
                            card = card,
                        }
                    end
                end
            end
        end
    end


    --- Dog Tag

    if config.j_zach_dogTag then

        local j_zach_dogTag = SMODS.Joker:new(
            "dogTag", "zach_dogTag",
            {extra = {hand_p = 0, handsToHit=3}}, {x=0, y=0},
            {
                name = "Dog Tag",
                text = {
                    "If {C:attention}Blind{} is cleared in",
                    "{C:attention}#2#{} {C:blue}Hands{} create",
                    "a {C:purple}Spectral{} card",
                    "{C:inactive}(must have room){}",
                }
            }, 3, 4, true, true, true, false
        )

        register_elem(j_zach_dogTag)

        SMODS.Jokers.j_zach_dogTag.loc_def = function(card)
            return {card.ability.extra.hand_p, card.ability.extra.handsToHit}
        end

        SMODS.Jokers.j_zach_dogTag.calculate = function(card, context)
            if context.setting_blind and not card.getting_sliced then
                card.ability.extra.hand_p = 0
            elseif context.end_of_round and not (context.individual or context.repetition or context.blueprint) then
                if card.ability.extra.hand_p==card.ability.extra.handsToHit then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.0,
                            func = (function()
                                    local card = create_card('Spectral',G.consumeables, nil, nil, nil, nil, nil, 'sixth')
                                    card:add_to_deck()
                                    G.consumeables:emplace(card)
                                    G.GAME.consumeable_buffer = 0
                                return true
                            end)}))
                        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral})
                    end
                end
            elseif SMODS.end_calculate_context(context) then
                card.ability.extra.hand_p = card.ability.extra.hand_p + 1
            end
        end

        
        --- Game Show

    if config.j_zach_gameShow then

        local j_zach_gameShow = SMODS.Joker:new(
            "gameShow", "zach_gameShow",
            {extra = {oddsWin = 3, odds=4}}, {x=0, y=0},
            {
                name = "Game Show",
                text = {
                    "{C:green}#1# in #2#{} chance",
                    "when clearing a blind",
                    "to create a {C:attention}Wheel of fortune{}",
                }
            }, 2, 4, true, true, false, false
        )

        register_elem(j_zach_gameShow)

        SMODS.Jokers.j_zach_gameShow.loc_def = function(card)
            return {''..(G.GAME and card.ability.extra.oddsWin), card.ability.extra.odds}
        end

        SMODS.Jokers.j_zach_gameShow.calculate = function(card, context)
            if context.end_of_round and not (context.individual or context.repetition or context.blueprint) then
                if pseudorandom(pseudoseed('gameShow')) < card.ability.extra.oddsWin/card.ability.extra.odds then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'before',
                                    delay = 0.0,
                                    func = (function()
                                            local card = create_card('Tarrot',G.consumeable, nil, nil, nil, nil, "c_wheel_of_fortune", 'vag')
                                            card:add_to_deck()
                                            G.consumeables:emplace(card)
                                            G.GAME.consumeable_buffer = 0
                                        return true
                                    end)}))
                                return {
                                    message = 'Wheel!',
                                    card = card
                                }
                end
            end
        end
                
    end

    --- emptyHand

    if config.j_zach_emptyHand then

        local j_zach_emptyHand = SMODS.Joker:new(
            "emptyHand", "zach_emptyHand",
            {extra = {CPH = 25}}, {x=0, y=0},
            {
                name = "Empty Handed",
                text = {
                    "Give's {C:blue}+#1#{} Chips,",
                    "{C:blue}-#2#{} Chips per card played",
                    "in hand"
                }
            }, 1, 3, true, true, true, false
        )

        register_elem(j_zach_emptyHand)

        SMODS.Jokers.j_zach_emptyHand.loc_def = function(card)
            return {card.ability.extra.CPH*5,card.ability.extra.CPH}
        end

        SMODS.Jokers.j_zach_emptyHand.calculate = function(card, context)
            if SMODS.end_calculate_context(context) then
                return {
                    message = localize{type='variable',key='a_chips',vars={card.ability.extra.CPH*5-card.ability.extra.CPH*#context.full_hand}},
                    chip_mod = card.ability.extra.CPH*5 - #context.full_hand*card.ability.extra.CPH,
                    colour = G.C.CHIPS
                }
            end
        end
    end

    end

    --- Call It

    if config.j_zach_callIt then
        local j_zach_callIt = SMODS.Joker:new(
            "callIt", "zach_callIt",
            {call= "",extra={ciMult=0, multAdd=1.5}}, {x=0, y=0},
            {
                name = "Call it",
                text = {
                    "This joker gains {C:red}+#4#{} Mult",
                    "per consecutive {C:attention}hand{}",
                    "played where a scoring",
                    "card is {C:attention}#2#{} or {C:attention}#1#{}",
                    "{C:inactive}(Currently{} {C:red}+#3#{} {C:inactive}Mult){}"
                }
            }, 1, 4, true, true, true, false
        )

        register_elem(j_zach_callIt)

        call="higher" 

        SMODS.Jokers.j_zach_callIt.loc_def = function(card)
            test = localize(G.GAME.current_round.mail_card.rank, 'ranks')
            return {call, test, card.ability.extra.ciMult, card.ability.extra.multAdd}
        end

        SMODS.Jokers.j_zach_callIt.calculate = function(card, context)
            --Reset code
            if context.cardarea == G.jokers then
                if context.before then
                    cardGot=false
                    for i = 1, #context.scoring_hand do
                        if call =="higher" then
                            if context.scoring_hand[i]:get_id() >= G.GAME.current_round.mail_card.id then
                                cardGot=true
                            end
                        else
                            if context.scoring_hand[i]:get_id() <= G.GAME.current_round.mail_card.id then
                                cardGot=true
                            end
                        end
                    end
                    if not cardGot then
                        card.ability.extra.ciMult=0
                        return {
                            card = card,
                            message = localize('k_reset')
                        }
                    end
                end
            end

            if context.setting_blind and not card.getting_sliced then
                test = localize(G.GAME.current_round.mail_card.rank, 'ranks')
                if pseudorandom(pseudoseed('gameShow')) < .5 then
                    call="higher" 
                else
                    call="lower"
                end
                SMODS.Jokers.j_zach_callIt.loc_def = function(card)
                    test = localize(G.GAME.current_round.mail_card.rank, 'ranks')
                    return {call, test, card.ability.extra.ciMult,card.ability.extra.multAdd}
                end
                return {
                    card = card,
                    message = call .. " than " .. tostring(G.GAME.current_round.mail_card.rank)
                }
            end


            if SMODS.end_calculate_context(context) then
                if cardGot then
                    card.ability.extra.ciMult=card.ability.extra.ciMult+card.ability.extra.multAdd
                    return {
                        ---localize{type='variable',key='a_xmult',vars={self.ability.extra.Xmult}},
                        message = localize{type='variable',key='a_mult',vars={card.ability.extra.ciMult}},
                        mult_mod = card.ability.extra.ciMult
                    }
                end   
            end
        end
    end

    --- overkill

    if config.j_zach_overkill then

        to_big = to_big or function(num)
            return num
        end

        local j_zach_overkill = SMODS.Joker:new(
            "overkill", "zach_overkill",
            {extra = {dollars=0}}, {x=0, y=0},
            {
                name = "Overchip",
                text = {
                    "Gives {C:money}money{} for going",
                    "over the blind amount",
                    "{C:inactive}(Doubling blind gives {}{C:money}$5{}{C:inactive}){}",
                }
            }, 2, 5, true, true, true, false
        )

        register_elem(j_zach_overkill)

        SMODS.Jokers.j_zach_overkill.loc_def = function(card)
            return {card.ability.extra.dollars}
        end

        SMODS.Jokers.j_zach_overkill.calculate = function(card, context)
            if context.end_of_round and not (context.individual or context.repetition or context.blueprint) then
                if to_big(G.GAME.chips)/to_big(G.GAME.blind.chips) >= to_big(1) then
                    card.ability.extra.dollars = math.floor(math.sqrt(25*((G.GAME.chips/G.GAME.blind.chips)-1)))
                end
            end
        end
        
    end

    local calculate_dollar_bonusref = Card.calculate_dollar_bonus
    function Card.calculate_dollar_bonus(self)
        if self.debuff then return end
        if self.ability.set == "Joker" then
            --overkill
            if self.config.center_key == 'j_zach_overkill' then
                return self.ability.extra.dollars
            end
        end
    end


    --- Three's A Crowd

    if config.j_zach_TAC then

        local j_zach_TAC = SMODS.Joker:new(
            "TAC", "zach_TAC",
            {extra = {nonscore={}}}, {x=0, y=0},
            {
                name = "Three's a crowd",
                text = {
                    "If hand scores as",
                    "{C:attention}Three of a Kind{}, any cards not",
                    "scored get destroyed",
                }
            }, 3, 6, true, true, true, false
        )

        register_elem(j_zach_TAC)

        SMODS.Jokers.j_zach_TAC.loc_def = function(card)
            return {card.ability.extra.Xmult, card.ability.extra.decay}
        end



        SMODS.Jokers.j_zach_TAC.calculate = function(card, context)
            if context.full_hand ~= nil and context.full_hand[1] and not context.other_card and not context.blueprint then
                card.ability.extra.nonscore = {}
                if context.scoring_name == 'Three of a Kind' and #context.full_hand>3 then
                    --gets the cards that are played but not scored
                    for k, v in ipairs(context.full_hand) do
                        card.ability.extra.nonscore[#card.ability.extra.nonscore+1] = v
                    end
                    for k, v in ipairs(context.scoring_hand) do
                        for i = #card.ability.extra.nonscore, 1, -1 do
                            if card.ability.extra.nonscore[i] == v then
                                table.remove(card.ability.extra.nonscore, i)
                                break
                            end
                        end
                    end
                    --destroys those cards
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = function()
                            for i = 1, #card.ability.extra.nonscore do
                                card.ability.extra.nonscore[i]:start_dissolve(nil, #card.ability.extra.nonscore)
                                card.ability.extra.nonscore[i].destroyed = true
                            end
                            card.ability.extra.nonscore = {}
                    return true end }))
                    
                end
            end     
        end
    end

    --- Rubber Ducky

    if config.j_zach_ducky then

        local j_zach_ducky = SMODS.Joker:new(
            "ducky", "zach_ducky",
            {extra = {oddsWin=3,odds=4, chips=30, mult=10}}, {x=0, y=0},
            {
                name = "Rubber Ducky",
                text = {
                    "{C:green}#1# in #2#{} chance",
                    "for {C:chips}+#3#{} and {C:mult}+#4#{}",
                }
            }, 1, 3, true, true, true, false
        )

        register_elem(j_zach_ducky)

        SMODS.Jokers.j_zach_ducky.loc_def = function(card)
            return {''..(G.GAME and card.ability.extra.oddsWin),card.ability.extra.odds,card.ability.extra.chips,card.ability.extra.mult}
        end

        SMODS.Jokers.j_zach_ducky.calculate = function(card, context)
            if SMODS.end_calculate_context(context) and pseudorandom(pseudoseed('ducky')) < card.ability.extra.oddsWin/card.ability.extra.odds then
            return {
                chip_mod = card.ability.extra.chips,
                mult_mod = card.ability.extra.mult,
                message = "Quack",
                colour =  G.C.MONEY,
            }
            end
        end
    end


    --- CR45H

    if config.j_zach_CR45H then

        local j_zach_CR45H = SMODS.Joker:new(
            "CR45H", "zach_CR45H",
            {extra = {chipBonus=101}}, {x=0, y=0},
            {
                name = "CR45H",
                text = {
                    "All cards score as",
                    "{C:blue}1{} Chip, {C:blue}+#1#{} Chips",
                }
            }, 2, 5, true, true, true, false
        )

        register_elem(j_zach_CR45H)

        SMODS.Jokers.j_zach_CR45H.loc_def = function(card)
            return {card.ability.extra.chipBonus}
        end

        SMODS.Jokers.j_zach_CR45H.calculate = function(card, context)
            local chipSub = 0
            if context.cardarea == G.play then
                if context.individual then
                    if (context.other_card:is_face()) then
                        chipSub=9
                    elseif (context.other_card:get_id() == 14) then
                        chipSub=10
                    else
                        chipSub = (context.other_card:get_id()-1)
                    end
                    if context.other_card.ability.effect == "Bonus Card" then
                        chipSub=chipSub+30
                    end
                    return{
                        chips = -chipSub
                    }
                end
            end
            if SMODS.end_calculate_context(context) then
                return {
                    message = localize{type='variable',key='a_chips',vars={card.ability.extra.chipBonus}},
                    chip_mod = card.ability.extra.chipBonus,
                    colour = G.C.CHIPS
                }
            end
        end
    end

    --Trash

    if config.j_zach_trash then

        local j_zach_trash = SMODS.Joker:new(
            "trash", "zach_trash",
            {extra = 15}, {x=0, y=0},
            {
                name = "Trash",
                text = {
                    "{C:blue}+#1#{} Chips",
                }
            }, 1, 0, true, true, true, false
        )

        register_elem(j_zach_trash)

        SMODS.Jokers.j_zach_trash.yes_pool_flag = 'trash_can'

        SMODS.Jokers.j_zach_trash.loc_def = function(card)
            return {card.ability.extra}
        end

        SMODS.Jokers.j_zach_trash.calculate = function(card, context)
            if SMODS.end_calculate_context(context) then
                return {
                    message = localize{type='variable',key='a_chips',vars={card.ability.extra}},
                    chip_mod = card.ability.extra,
                    colour = G.C.CHIPS
                }
            end
        end
    end

    --- Trash Can

    if config.j_zach_trashCan then

        local j_zach_trashCan = SMODS.Joker:new(
            "trashCan", "zach_trashCan",
            {extra = {max=3}}, {x=0, y=0},
            {
                name = "Trash Can",
                text = {
                    "When {C:attention}Blind{} is selected,",
                    "create {C:attention}1{} {C:dark_edition}Negative{} Trash",
                    "{C:inactive}(#1# max){}"
                }
            }, 2, 6, true, true, true, false
        )

        register_elem(j_zach_trashCan)

        SMODS.Jokers.j_zach_trashCan.loc_def = function(card)
            return {card.ability.extra.max}
        end
        
        SMODS.Jokers.j_zach_trashCan.calculate = function(card, context)
            if context.setting_blind and not (context.blueprint_card or card).getting_sliced then
                
                local trashCount = 0
                for i = 1, #G.jokers.cards do
                    if G.jokers[i] == j_zach_trash then
                        trashCount = trashCount + 1
                    end
                end

                if #G.jokers.cards <= G.jokers.config.card_limit and (trashCount < (card.ability.extra.max+1)) then 
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = 'Trash!'})
                    G.E_MANAGER:add_event(Event({func = function()
                        --local newCard = create_card('Joker', G.jokers, nil, 2, nil, nil, nil, 'strongHeart')
                        local newCard = create_card('Joker', nil, nil, nil, nil, nil, 'j_zach_trash', 'trashed')
                        edition = {negative = true}
                        newCard:set_edition(edition, true)
                        newCard:add_to_deck()
                        G.jokers:emplace(newCard)
                        return true end }))
                    return {}
                else
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_no_room_ex')})
                end
            end
        end
    end

    --- Clown

    if config.j_zach_clown then

        local j_zach_clown = SMODS.Joker:new(
            "clown", "zach_clown",
            {extra = {sum = 0, add=6}}, {x=0, y=0},
            {
                name = "Clown",
                text = {
                    "This Joker gains {C:chips}+#2#{} Chips",
                    "for every different played",
                    "{C:attention}poker hand{} type played this round",
                    "{C:inactive}(Currently {C:chips}+#1#{} {C:inactive}Chips){}",
                }
            }, 1, 3, true, true, true, false
        )

        register_elem(j_zach_clown)

        SMODS.Jokers.j_zach_clown.loc_def = function(card)
            return {card.ability.extra.sum, card.ability.extra.add}
        end

        tempHands={}

        SMODS.Jokers.j_zach_clown.calculate = function(card, context)
            if context.cardarea == G.jokers then
                if context.before then
                    findDupHand=true
                    for k, v in  pairs(tempHands) do
                        if v==context.scoring_name then
                            findDupHand=false
                            break
                        end 
                    end
                    if findDupHand then
                        table.insert(tempHands, context.scoring_name)
                        card.ability.extra.sum = card.ability.extra.sum + card.ability.extra.add
                        return {
                            message = localize('k_upgrade_ex'),
                            colour = G.C.CHIPS,
                            card = self
                        }
                    end
                end
            end

                if SMODS.end_calculate_context(context) then
                    return {
                        message = localize{type='variable',key='a_chips',vars={card.ability.extra.sum}},
                        chip_mod = card.ability.extra.sum,
                        colour = G.C.CHIPS
                    }
                end
        end
    end

    --- Double Or Nothing

    if config.j_zach_DON then

        local j_zach_DON = SMODS.Joker:new(
            "DON", "zach_DON",
            {extra=0}, {x=0, y=0},
            {
                name = "Double or Nothing",
                text = {
                    "Base chips and Mult for playing",
                    "a poker hand are doubled",
                }
            }, 1, 3, true, true, true, false
        )

        register_elem(j_zach_DON)

        SMODS.Jokers.j_zach_DON.loc_def = function(card)
            return {}
        end

        SMODS.Jokers.j_zach_DON.calculate = function(card, context)
                if context.cardarea == G.jokers then
                    if context.before then

                        function Blind:modify_hand(cards, poker_hands, text, mult, hand_chips)
                            --self.triggered = true
                            return math.max(math.floor(mult*2 + 0.5), 1), math.max(math.floor(hand_chips*2 + 0.5), 0), true
                        end
                        return {
                            message = "Doubled",
                            colour = G.C.FILTER
                        }
                        --[[G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
                            play_sound('tarot1')
                            if card then card:juice_up(0.8, 0.5) end
                            G.TAROT_INTERRUPT_PULSE = nil
                            return true end }))
                            --]]
                    end
                end
        end
    end

    --- Offhand

    if config.j_zach_offhand then

        local j_zach_offhand = SMODS.Joker:new(
            "offhand", "zach_offhand",
            {extra = 1}, {x=0, y=0},
            {
                name = "Offhand",
                text = {
                    "{C:attention}Consumable{} cards retrigger their",
                    "associated {C:attention}card type{}",
                }
            }, 1, 3, true, true, true, false
        )

        register_elem(j_zach_offhand)

        SMODS.Jokers.j_zach_offhand.loc_def = function(card)
            return {}
        end

        SMODS.Jokers.j_zach_offhand.calculate = function(card, context)
            
            if context.cardarea == G.jokers and context.before and G.consumeables.cards[1] then
                consumeScore={}
                for k, v in pairs(G.consumeables.cards) do
                    if v.ability.name == "The Magician" then
                        table.insert(consumeScore, "Lucky Card")
                        sendDebugMessage("lucky")
                    end
                    if v.ability.name == "The Tower" then
                        table.insert(consumeScore, "Stone Card")
                    end
                    if v.ability.name == "The Empress" then
                        table.insert(consumeScore, "Mult Card")
                    end
                    if v.ability.name == "The Hierophant" then
                        table.insert(consumeScore, "Bonus Card")
                    end
                    if v.ability.name == "The Lovers" then
                        table.insert(consumeScore, "Wild Card")
                    end
                    if v.ability.name == "Justice" then
                        table.insert(consumeScore, "Glass Card")
                    end
                    if v.ability.name == "The Chariot" then
                        table.insert(consumeScore, "Steel Card")
                    end
                    if v.ability.name == "The Devil" then
                        table.insert(consumeScore, "Gold Card")
                    end
                    --[[
                    maybe implement if I hate myself (aura cards repeat)
                    if v.ability.name == "The Wheel of Fortune" then
                        table.insert(consumeScore, "Lucky Card")
                    end
                    ]]
                end
                sendDebugMessage("consumeScore contents: " .. table.concat(consumeScore, ", "))
                cardReps=0
            end


            if context.repetition then
                cardReps=0
                if not context.individual and context.cardarea == G.play then
                    sendDebugMessage("working")
                    for k, v in pairs(consumeScore) do
                        if context.other_card.ability.effect == v then
                            cardReps=cardReps+card.ability.extra
                        end
                    end
                    return {
                        message = localize('k_again_ex'),
                        repetitions = cardReps,
                        card = card
                    }
                elseif context.cardarea == G.hand then
                    for k, v in pairs(consumeScore) do
                        if context.other_card.ability.effect == v then
                            cardReps=cardReps+card.ability.extra
                        end
                    end
                    return {
                        message = localize('k_again_ex'),
                        repetitions = cardReps,
                        card = card
                    }
                end
            end


        end
    end

    --- Chaos

    if config.j_zach_chaos then

        local j_zach_chaos = SMODS.Joker:new(
            "chaos", "zach_chaos",
            {extra = 2.5}, {x=0, y=0},
            {
                name = "Chaos",
                text = {
                    "Shuffles all jokers",
                    "for {C:chips}+#3#{} and {C:mult}+#4#{}",
                }
            }, 1, 3, true, true, true, false
        )

        register_elem(j_zach_chaos)

        SMODS.Jokers.j_zach_chaos.loc_def = function(card)
            return {card.ability.extra}
        end

        SMODS.Jokers.j_zach_chaos.calculate = function(card, context)
                if context.cardarea == G.jokers then
                    if context.before then
                        if #G.jokers.cards > 1 then 
                            G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 0.85);return true end })) 
                            delay(0.15)
                            G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 1.15);return true end })) 
                            delay(0.15)
                            G.E_MANAGER:add_event(Event({ func = function() G.jokers:shuffle('aajk'); play_sound('cardSlide1', 1);return true end })) 
                            delay(0.5)
                        end
                        
                    end
                end

                if SMODS.end_calculate_context(context) then
                    return {
                        message = localize{type='variable',key='a_xmult',vars={card.ability.extra}},
                        Xmult_mod = card.ability.extra
                    }
                end
        end
    end


    --[[
    --- Jimbo

    if config.j_zach_jimbo then

        local j_zach_jimbo = SMODS.Joker:new(
            "jimbo", "zach_jimbo",
            {extra = {Xmult=4, decay=.5}}, {x=0, y=0},
            {
                name = "{C:attention}Jimbo{}",
                text = {
                    "Hiya!",
                }
            }, 3, 8, true, true, true, false
        )

        register_elem(j_zach_jimbo)

        local additional_quips = {
            sq1 = {"Guess what?", "Chicken butt!"}
        }

        for k, v in pairs(additional_quips) do
            G.localization.misc.quips[k] = v
            G.localization.quips_parsed[k] = {multi_line = true}
            for kk, vv in ipairs(v) do
                G.localization.quips_parsed[k][kk] = loc_parse_string(vv)
            end
        end


        SMODS.Jokers.j_zach_jimbo.loc_def = function(card)
            return {card.ability.extra.Xmult, card.ability.extra.decay}
        end

        SMODS.Jokers.j_zach_jimbo.calculate = function(card, context)    
            card:add_speech_bubble2('lq_'..math.random(1,10), nil, {quip = true})
            card:say_stuff22(5)
        end
            
    end
    ]]

    --[[
    --- Car Accident

    if config.j_zach_carAccident then

        local j_zach_carAccident = SMODS.Joker:new(
            "carAccident", "zach_carAccident",
            {extra = {h_plays = 2, dollars=5}}, {x=0, y=0},
            {
                name = "Car Accident",
                text = {
                    "{C:blue}#1#{} hand each round, earn {C:money}$#2#{} at",
                    "end of round",
                }
            }, 1, 4, true, true, true, false
        )

        register_elem(j_zach_carAccident)

        SMODS.Jokers.j_zach_carAccident.loc_def = function(card)
            return {-card.ability.extra.h_plays, card.ability.extra.dollars}
        end
        
        SMODS.Jokers.j_zach_carAccident.calculate = function(card, context)
            if context.setting_blind and not card.getting_sliced then
                ease_hands_played(card.ability.hand_mod)
            end
        end

    end

    local calculate_dollar_bonusref = Card.calculate_dollar_bonus
    function Card.calculate_dollar_bonus(self)
        if self.debuff then return end
        if self.ability.set == "Joker" then
            --car accident
            if self.config.center_key == 'j_zach_carAccident' then
                return self.ability.extra.dollars
            end
        end
    end
    --]]


    --- Loan Shark

    --[[
    if config.j_zach_loanShark then

        local j_zach_loanShark = SMODS.Joker:new(
            "loanShark", "zach_loanShark",
            {extra = {loan = 20}, dollars = 2}, {x=0, y=0},
            {
                name = "Loan Shark",
                text = {
                    "Gain {C:money}$#1#{} when bought",
                    "Loses {C:money}$#2#{} sell value",
                    "at the end of round",
                }
            }, 2, -22, true, true, true, false
        )

        register_elem(j_zach_loanShark)

        SMODS.Jokers.j_zach_loanShark.loc_def = function(card)
            return {card.ability.extra.loan, card.ability.dollars}
        end

        SMODS.Jokers.j_zach_loanShark.calculate = function(card, context)
            if context.end_of_round and not (context.individual or context.repetition or context.blueprint) then
                return card.ability.dollars
            end
        end
    end
    --]]

end