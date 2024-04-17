import { Account, CallData, Contract, RpcProvider } from "starknet";
import { abi } from "./abi";

export const KATANA_ACCOUNT_ADDRESS = "0xb3ff441a68610b30fd5e2abbf3a1548eb6ba6f3559f2862bf2dc757e5828ca";
export const KATANA_ACCOUNT_PRIVATE_KEY = "0x2bbf4f9fd0bbb2e60b0316c1fe0b76cf7a4d0198bd493ced9b8df2a3a24d68a";
export const WORLD_CONTRACT_ADDRESS = "0x2ae4f22faea88b6e51d23fdf907ca12be8e48ef73693b6e9f4d8fc42549f5d2";
export const KATANA_RPC = "http://localhost:5050/";


export function setupNetwork() {
  const provider = new RpcProvider({ nodeUrl: KATANA_RPC });

  const signer = new Account (
    provider,
    KATANA_ACCOUNT_ADDRESS,
    KATANA_ACCOUNT_PRIVATE_KEY
  );

  return {
    provider,
    signer,
  }
}

export async function SpawnGame({ provider, signer }: { provider: RpcProvider; signer: Account }) {
  const cross_player = generateRandomHexString();
  const circle_player = generateRandomHexString();

  const contractCallData = new CallData(abi);
  const system_contract = new Contract(abi, WORLD_CONTRACT_ADDRESS, provider);
  system_contract.connect(signer);

  await system_contract.invoke(
    'spawn',
    contractCallData.compile('spawn', {
      cross_address: cross_player,
      circle_address: circle_player,
    }),
    {
      maxFee: 0,
    }
  )

  return {cross_player, circle_player}
}

export async function callMove(next_position: number, caller: String, game_id: number, {provider, signer}:{provider: RpcProvider, signer: Account}) {
  const contractCallData = new CallData(abi);
  const system_contract = new Contract(abi, WORLD_CONTRACT_ADDRESS, provider);
  system_contract.connect(signer);

  await system_contract.invoke(
    'move',
    contractCallData.compile('move', {
      next_position: next_position,
      caller: caller,
      game_id: game_id
    }), {
      maxFee: 0,
    }
  )
}

function generateRandomHexString(length = 32) {
  const allowedChars = '0123456789abcdef';

  // Loop until a valid random value is generated
  let randomString;
  do {
    randomString = '';
    for (let i = 0; i < length; i++) {
      randomString += allowedChars[Math.floor(Math.random() * allowedChars.length)];
    }
  } while (parseInt(randomString, 16) === 0); // Check if the value is zero

  // Prefix the string with "0x"
  return `0x${randomString}`;
}