use tic_tac_toe::models::player::Symbol;
use starknet::ContractAddress;

#[derive(Model, Drop, Serde)]
struct Game {
    #[key]
    game_id: u32,
    winner: Symbol,
    cross: ContractAddress,
    circle: ContractAddress
}

#[derive(Model, Drop, Serde)]
struct GameTurn {
    #[key]
    game_id: u32,
    player_symbol: Symbol
}

trait GameTurnTrait {
    fn next_turn(self: @GameTurn) -> Symbol;
}

impl GameTurnImpl of GameTurnTrait {
    fn next_turn(self: @GameTurn) -> Symbol {
        match self.player_symbol {
            Symbol::Cross => Symbol::Circle,
            Symbol::Circle => Symbol::Cross,
            Symbol::None => panic(array!['Illegal turn'])
        }
    }
}