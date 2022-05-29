import * as nearAPI from "near-api-js";
import { generateSeedPhrase, parseSeedPhrase } from 'near-seed-phrase';
import config from './config'
import { PublicKey } from 'near-api-js/lib/utils';
let controller;

async function listAccountsByPublicKey(publicKey) {
  return await fetch(`${config.INDEXER_SERVICE_URL}/publicKey/${publicKey}/accounts`)
    .then((res) => res.json());
}

async function getAccountIds(publicKey) {
  send("config", config)
  send("publicKey", publicKey)
  controller = new AbortController();
  // if (!USE_INDEXER_SERVICE) {
  return await fetch(`${config.ACCOUNT_HELPER_URL}/publicKey/${publicKey}/accounts`, { signal: controller.signal }).then((res) => res.json());
  // }
  // return await listAccountsByPublicKey(publicKey);
}

async function getAccountIdsBySeedPhrase(seedPhrase) {
  const { secretKey } = parseSeedPhrase(seedPhrase);
  const keyPair = nearAPI.KeyPair.fromString(secretKey);
  const publicKey = keyPair.publicKey.toString();
  return getAccountIds(publicKey);
}

const initializeRecoveryMethodNewImplicitAccount = async (method) => {
  const { seedPhrase } = generateSeedPhrase();
  const { secretKey } = parseSeedPhrase(seedPhrase);
  const recoveryKeyPair = nearAPI.KeyPair.fromString(secretKey);
  const implicitAccountId = Buffer.from(recoveryKeyPair.publicKey.data).toString('hex');
  const body = {
    accountId: implicitAccountId,
    method,
    seedPhrase
  };
  await sendJson('POST', ACCOUNT_HELPER_URL + '/account/initializeRecoveryMethodForTempAccount', body);
  return seedPhrase;
}

const recover = async (seedPhrase) => {
 
  const { secretKey } = parseSeedPhrase(seedPhrase);
  const keyPair = nearAPI.KeyPair.fromString(secretKey);
  const publicKey = keyPair.publicKey.toString();

  const tempKeyStore = new nearAPI.keyStores.InMemoryKeyStore();
  const implicitAccountId = Buffer.from(PublicKey.fromString(publicKey).data).toString('hex');


  const accountIdsByPublickKey = await getAccountIds(publicKey);

  let accountId = implicitAccountId;
  if (accountIdsByPublickKey?.length) {
    accountId = accountIdsByPublickKey[0];
  }
  const connection = nearAPI.Connection.fromConfig({
    networkId: "testnet",
    provider: { type: 'JsonRpcProvider', args: { url: config.NODE_URL + '/' } },
    signer: new nearAPI.InMemorySigner(tempKeyStore)
  });
  let account = new nearAPI.Account(connection, accountIdsByPublickKey[0]);
  
  return account

}

export default {
  recover,
  initializeRecoveryMethodNewImplicitAccount
}