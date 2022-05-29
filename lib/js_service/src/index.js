import "@babel/polyfill";

import account from './account'
import * as nearAPI from "near-api-js";
import { generateSeedPhrase, parseSeedPhrase } from 'near-seed-phrase';
import { ACCOUNT_HELPER_URL } from './config'


// send message to app
function send(path, data) {
  console.log(JSON.stringify({ path, data }));
}
send("log", "main js loaded");
window.send = send;


function connect(endpoint) {
  return new Promise(async (resolve, reject) => {

    const { keyStores, KeyPair, WalletConnection } = nearAPI;
    const keyStore = new keyStores.InMemoryKeyStore();
    // const PRIVATE_KEY =
    //   "by8kdJoJHu7uUkKfoaLd2J2Dp1q1TigeWMG123pHdu9UREqPcshCM223kWadm";
    // const seedPhraseData = generateSeedPhrase()
    // console.log(seedPhraseData)
    const { secretKey } = parseSeedPhrase("flight people bracket rapid cave unable worth repeat clay enhance arrive alpha");

    // creates a public / private key pair using the provided private key
    const keyPair = KeyPair.fromString(secretKey);
    // adds the keyPair you created to keyStore
    await keyStore.setKey("testnet", "tangke.testnet", keyPair);

    const publicKey = keyPair.getPublicKey().toString()

    try {
      const { connect } = nearAPI;

      const config = {
        networkId: "testnet",
        keyStore,
        nodeUrl: endpoint,
        walletUrl: "https://wallet.testnet.near.org",
        helperUrl: ACCOUNT_HELPER_URL,
        explorerUrl: "https://explorer.testnet.near.org",
      };
      const near = await connect(config);
      // const wallet = new WalletConnection(near);
      // const signedInWalletId = wallet.getAccountId();
      // console.log("signedInWalletId", signedInWalletId);
      const account = await near.account("tangke.testnet");

      const detail = await account.getAccountDetails();
      send("detail", detail)
      const balance = await account.getAccountBalance(false);
      send("balance", balance)
      send("log", `${endpoint} wss ready`);
      resolve(endpoint);
    } catch (error) {
      send("log", `connect ${endpoint} failed`);
      send(error)
      resolve(null);
    }


  });
}

const test = async (address) => {

};

window.settings = {
  test,
  connect,

};

window.account = account;