#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use dojo::test_utils::{spawn_test_world,deploy_contract};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use tic_tac_toe::models::player::{Player,Symbol,player};
    use tic_tac_toe::models::board::{Board,board};
    use tic_tac_toe::models::game::{Game,GameTurn,game,game_turn};
    use tic_tac_toe::systems::actions::{actions,IActionsDispatcher,IActionsDispatcherTrait};

    fn setup_world() -> (IWorldDispatcher,IActionsDispatcher) {
        let mut models = array![
            game::TEST_CLASS_HASH,
            board::TEST_CLASS_HASH,
            player::TEST_CLASS_HASH,
            game_turn::TEST_CLASS_HASH,
        ];

        let world = spawn_test_world(models);

        let contract_address = world.deploy_contract('salt',actions::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IActionsDispatcher {contract_address} ;
        (world,actions_system)
    }
    #[test]
    fn test_init_board() {
        let circle = starknet::contract_address_const::<0x01>();
        let cross = starknet::contract_address_const::<0x02>();
        let (world,actions_system) = setup_world();

        let game_id = actions_system.spawn(cross, circle);

        let game = get!(world, game_id, (Game));
        let game_turn = get!(world, game_id, (GameTurn));
        assert!(game_turn.player_symbol == Symbol::Cross, "should be Cross");
        assert!(game.circle == circle, "circle address is incorrect");
        assert!(game.cross == cross, "cross address is incorrect");
        
    }
    #[test] 
    fn test_play() {
        let circle = starknet::contract_address_const::<0x01>();
        let cross = starknet::contract_address_const::<0x02>();
        let (world, actions_system) = setup_world();

        let game_id = actions_system.spawn(cross,circle);

        // Cross goes into slot_0
        actions_system.move(0, cross.into(), game_id);
        let board = get!(world, game_id, (Board));
        assert!(board.slots == 211111111, "This board should be 211111111");

        // Check turn changed
        let game_turn = get!(world, game_id,(GameTurn));
        assert!(game_turn.player_symbol == Symbol::Circle, "Should be circle");

        // Circle goes into slot_1
        actions_system.move(1, circle.into(), game_id);
        let board = get!(world, game_id, (Board));
        assert!(board.slots == 231111111, "This board should be 231111111");
        
        // Cross goes into slot_6
        actions_system.move(6, cross.into(), game_id);
        let board = get!(world, game_id, (Board));
        assert!(board.slots == 231111211, "This board should be 231111211");
    }
}