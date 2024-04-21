use starknet::ContractAddress;

#[dojo::interface]
trait IActions {
    fn spawn(cross_address: ContractAddress, circle_address: ContractAddress) -> u32;
    fn move(game_id: u32, next_position: u32, caller: ContractAddress);
}

#[dojo::contract]
mod actions {
    use super::{IActions, check_win, check_occupied, occupy_slot, build_up_slots, number_retrieved};
    use starknet::{ContractAddress, get_caller_address};
    use array::ArrayTrait;

    use tic_tac_toe::models::player::{Player, Symbol};
    use tic_tac_toe::models::game::{Game, GameTurn, GameTurnTrait};
    use tic_tac_toe::models::board::{Board, BoardTrait};

    #[abi(embed_v0)]
    impl IActionsImpl of IActions<ContractState> {

        fn spawn(
            world: IWorldDispatcher,
            cross_address: ContractAddress,
            circle_address: ContractAddress
        ) -> u32 {
            let game_id = world.uuid();

            set!(
                world,
                (
                    Player {game_id, address: cross_address, symbol: Symbol::Cross},
                    Player {game_id, address: circle_address, symbol: Symbol::Circle},
                )
            );

            set!(
                world,
                (
                    Board {game_id, slots: 111111111, occupied: 111111111},
                )
            );

            set!(
                world,
                (
                    Game {
                        game_id, winner: Symbol::None, cross: cross_address, circle: circle_address
                    },
                    GameTurn {game_id, player_symbol: Symbol::Cross},
                )
            );

            game_id
        }

        fn move(
            world: IWorldDispatcher,
            game_id: u32,
            next_position: u32, 
            caller: ContractAddress, 
        ) {

            // check out of range
            if next_position < 0 || next_position > 8 {
                panic!("Out of range");
            }

            let player = get!(world, (game_id, caller), (Player));
            let mut board = get!(world, game_id, (Board));

            // check slot occupied
            if check_occupied(next_position, board.occupied) {
                panic!("Position has been occupied");
            } else {
                occupy_slot(next_position, ref board.occupied);
            }

            // check_win
            if check_win(board.slots) {
                panic!("The game is over");
            }
            
            let mut target = 0;

            if player.symbol == Symbol::Cross {
                target = target + 1;
            } else {
                target = target + 2;
            }

            let new_slots = build_up_slots(board.slots, next_position, target);
            board.slots = new_slots;

            set!(world,(board));

            if check_win(new_slots) {
                set!(
                    world, 
                    (
                        Game {
                            game_id,
                            winner: player.symbol,
                            cross: caller,
                            circle: caller
                        }
                    )
                )
            }

            // change turn
            let mut game_turn = get!(world, game_id, (GameTurn));
            game_turn.player_symbol = game_turn.next_turn();
            set!(world, (game_turn));
        }
    }
}

fn check_occupied(next_position: u32, occupied: u32) -> bool {
    let (slot_0, slot_1, slot_2, slot_3, slot_4, slot_5, slot_6, slot_7, slot_8) = number_retrieved(occupied);

    if next_position == 0 && slot_0 == 2 {
        return true;
    } else if next_position == 1 && slot_1 == 2 {
        return true;
    } else if next_position == 2 && slot_2 == 2 {
        return true;
    } else if next_position == 3 && slot_3 == 2 {
        return true;
    } else if next_position == 4 && slot_4 == 2 {
        return true;
    } else if next_position == 5 && slot_5 == 2 {
        return true;
    } else if next_position == 6 && slot_6 == 2 {
        return true;
    } else if next_position == 7 && slot_7 == 2 {
        return true;
    } else if next_position == 8 && slot_8 == 2 {
        return true;
    }

    return false;
}

fn occupy_slot(next_position: u32, ref occupied: u32) {
    let (mut slot_0, mut slot_1, mut slot_2, mut slot_3, mut slot_4, mut slot_5, mut slot_6, mut slot_7, mut slot_8) = number_retrieved(occupied);

    if next_position == 0 {
        slot_0 = 2;
    } else if next_position == 1 {
        slot_1 = 2;
    } else if next_position == 2 {
        slot_2 = 2;
    } else if next_position == 3 {
        slot_3 = 2;
    } else if next_position == 4 {
        slot_4 = 2;
    } else if next_position == 5 {
        slot_5 = 2;
    } else if next_position == 6 {
        slot_6 = 2;
    } else if next_position == 7 {
        slot_7 = 2;
    } else if next_position == 8 {
        slot_8 = 2;
    }

    occupied = slot_0 * 100000000 + slot_1 * 10000000 + slot_2 * 1000000 + slot_3 * 100000 + slot_4 * 10000 + slot_5 * 1000 + slot_6 * 100 + slot_7 * 10 + slot_8;
}

fn check_win(slots: u32) -> bool {
    let (slot_0, slot_1, slot_2, slot_3, slot_4, slot_5, slot_6, slot_7, slot_8) = number_retrieved(slots);

    if slot_0 == slot_1 && slot_1 == slot_2 && slot_2 != 1 {
        return true;
    } else if slot_3 == slot_4 && slot_4 == slot_5 && slot_5 != 1 {
        return true;
    } else if slot_6 == slot_7 && slot_7 == slot_8 && slot_8 != 1 {
        return true;
    } else if slot_0 == slot_3 && slot_3 == slot_6 && slot_6 != 1 {
        return true;
    } else if slot_1 == slot_4 && slot_4 == slot_7 && slot_7 != 1 {
        return true;
    } else if slot_2 == slot_5 && slot_5 == slot_8 && slot_8 != 1 {
        return true;
    } else if slot_0 == slot_4 && slot_4 == slot_8 && slot_8 != 1 {
        return true;
    } else if slot_2 == slot_4 && slot_4 == slot_6 && slot_6 != 1 {
        return true;
    }

    return false;
}

fn build_up_slots(slots: u32, next_position: u32, target: u32) -> u32 {
    let (slot_0, slot_1, slot_2, slot_3, slot_4, slot_5, slot_6, slot_7, slot_8) = number_retrieved(slots);

    let mut array = ArrayTrait::new();
    array.append(slot_0);
    array.append(slot_1);
    array.append(slot_2);
    array.append(slot_3);
    array.append(slot_4);
    array.append(slot_5);
    array.append(slot_6);
    array.append(slot_7);
    array.append(slot_8);

    let mut i: u32 = 0;
    let mut new_slots: u32 = *array.at(i);

    loop {
        if i > 7 {
            if next_position == 8 {
                new_slots = new_slots + target;
            }

            break();
        }

        if i == next_position {
            new_slots = new_slots + target;
        }

        new_slots = new_slots * 10;
        i = i + 1;
        new_slots = new_slots + *array.at(i);
    };

    return new_slots;
}

fn number_retrieved (slots: u32) -> (u32, u32, u32, u32, u32, u32, u32, u32, u32) {
    let slot_0 = slots / 100000000;
    let slot_1 = (slots % 100000000) / 10000000;
    let slot_2 = (slots % 10000000) / 1000000;
    let slot_3 = (slots % 1000000) / 100000;
    let slot_4 = (slots % 100000) / 10000;
    let slot_5 = (slots % 10000) / 1000;
    let slot_6 = (slots % 1000) / 100;
    let slot_7 = (slots % 100) / 10;
    let slot_8 = (slots % 10) / 1;

    return (slot_0, slot_1, slot_2, slot_3, slot_4, slot_5, slot_6, slot_7, slot_8);
}