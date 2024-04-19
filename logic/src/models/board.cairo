use starknet::ContractAddress;

#[derive(Model, Drop, Serde)]
struct Board {
    #[key]
    game_id: u32,
    slots: u32,
    occupied: u32,
}


trait BoardTrait {
    fn new_board(game_id: u32) -> Board;
}

impl BoardImpl of BoardTrait {
   
    fn new_board(game_id: u32) -> Board {
        
        Board {
            game_id: game_id,
            slots: 111111111,
            occupied: 111111111,
        }
    }
}
