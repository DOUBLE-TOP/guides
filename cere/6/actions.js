import { importProvider, getFreeportAddress, createFreeport, getNFTAttachmentAddress, createNFTAttachment } from "@cere/freeport-sdk";
import { get as httpGet, post as httpPost } from "axios";
import bs58 from 'bs58';


export const connectWallet = async () => {
  // Check if window.ethereum is enabled in your browser (i.e., metamask is installed)
  if (window.ethereum) {
    try {
      // Prompts a metamask popup in browser, where the user is asked to connect a wallet.
      const addressArray = await window.ethereum.request({method: "eth_requestAccounts"});
      // Return an object containing a "status" message and the user's wallet address.
      return { status: "Follow the steps below.", address: addressArray[0] };
    } catch (err) { return { address: "", status: err.message}; }
    // Metamask injects a global API into websites visited by its users at 'window.ethereum'.
    // If window.ethereum is not enabled, then metamask must not be installed.
  } else { return { address: "", status: "Please install the metamask wallet" }; }
};

export const getCurrentWalletConnected = async () => {
  if (window.ethereum) {
    try {
      // Get the array of wallet addresses connected to metamask
      const addressArray = await window.ethereum.request({ method: "eth_accounts" });
      // If it contains at least one wallet address
      if (addressArray.length > 0) {
        return { address: addressArray[0], status: "Follow the steps below." };
        // If this list is empty, then metamask must not be connected.
      } else { return { address: "", status: "Please connect to metamask." }; }
      // Catch any errors here and return them to the user through the 'status' state variable.
    } catch (err) { return { address: "", status: err.message }; }
    // Again, if window.ethereum is not enabled, then metamask must not be installed.
  } else { return { address: "", status: "Please install the metamask wallet" }; }
};

export const upload2DDC = async (data, title, description) => {
  // Get the wallets that are connected to metamask
  const accounts = await window.ethereum.request({ method: "eth_accounts" });
  // Get the user's wallet address
  const minter = accounts[0]
  // Here we request that the user shares their public encryption key.
  const minterEncryptionKey = await window.ethereum.request({ method: 'eth_getEncryptionPublicKey', params: [minter] });
  // Create a new provider, which is an abstraction of a connection to the Ethereum network
  const provider = importProvider()
  // Get the user's account. A 'signer' is an abstraction of an Ethereum account.
  const signer = provider.getSigner();
  // Wait one second.
  await sleepFor(1);
  // Create the signature
  const signature = await signer.signMessage(`Confirm asset upload\nTitle: ${title}\nDescription: ${description}\nAddress: ${minter}`);
  // Construct a set of key/value pairs representing the fields required by the Cere DDC API.
  let fdata = new FormData();
  fdata.append('minter', minter);
  fdata.append('file', data);
  fdata.append('signature', signature);
  fdata.append('minterEncryptionKey', minterEncryptionKey);
  fdata.append('description', description);
  fdata.append('title', title);
  // Make an HTTP post request to the Cere DDC API using the FormData object we defined above.
  const httpPostResponse = await httpPost("https://ddc.freeport.stg.cere.network/assets/v1", fdata, { headers: {'Content-Type': 'multipart/form-data'} });
  // This post request contains a string corresponding to the uploadId of your upload request.
  const uploadId = httpPostResponse.data.id
  // With this uploadId, we make a get request to the Cere DDC API to get the contentId of our upload.
  // This content will not exist until the upload is complete.
  // We repeat this request until the file is uploaded or the upload fails (max 3 attempts)
  let contentId = null;
  var attempts = 1;
  while (!contentId) {
    attempts ++;
    let httpGetResponse = await httpGet(`https://ddc.freeport.stg.cere.network/assets/v1/${uploadId}`);
    contentId = httpGetResponse.data.result;
    // When the contentId is no longer null, the upload is considered successful. Return the contentId of this upload.
    if (contentId){ return {contentId: contentId, status: "Upload successful."}; }
    // If HTTP get request fails, then the upload was not successful. Return an empty string.
    if (httpGetResponse.failed) { return { contentId: "", status: "DDC upload failed" }; }
    // If this while loop unsucessfully makes 3 attempts at receiving a non-null contentId, give up and return an empty string.
    if (attempts == 3){ return { contentId: "", status: "Unable to get upload status after 3 attempts" }; }
    // Wait 10 seconds before trying again.
    await sleepFor(10);
  }
};

export const downloadFromDDC = async (contentId) => {
  // Create a new provider, which is an abstraction of a connection to the Ethereum network.
  const provider = importProvider();
  // Get the wallets that are connected to metamask
  const accounts = await window.ethereum.request({ method: "eth_accounts" });
  // Get the user's wallet address
  const minter = accounts[0];
  // Get the user's account. A 'signer' is an abstraction of an Ethereum account.
  const signer = provider.getSigner();
  // Wait one second.
  await sleepFor(1);
  // Create the signature
  const signature = await signer.signMessage(`Confirm identity:\nMinter: ${minter}\nCID: ${contentId}\nAddress: ${minter}`);
  // Construct a set of key/value pairs representing the fields required by the Cere DDC API.
  const results = await httpGet(`https://ddc.freeport.stg.cere.network/assets/v1/${minter}/${contentId}/content`, {
      responseType: 'blob',
      headers: { 'X-DDC-Signature': signature, 'X-DDC-Address': minter }});
  // Return the downloaded data
  return { status: "Download complete.", content: results.data };
};

export const mintNFT = async (quantity, metadata) => {
  // Do not allow the user to mint an NFT without metadata. Must not be empty string.
  if (metadata.trim() == "" || (quantity < 1)) { return { success: false, status: "Please complete all fields before minting." } }
  // Create a new provider, which is an abstraction of a connection to the Ethereum network.
  const provider = importProvider();
  // Select 'dev', 'stage', or 'prod' environment to determine which smart contract to use. Default is 'prod'.
  const env = "dev";
  // Get the appropriate Freeport contract address, based on environment selected above.
  const contractAddress = await getFreeportAddress(provider, env);
  // Create an instance of the Freeport contract using the provider and Freeport contract address
  const contract = createFreeport( { provider, contractAddress } );
  try {
    // Call the issue() function from the Freeport smart contract.
    const tx = await contract.issue(quantity, utilStr2ByteArr(metadata));
    const receipt = await tx.wait();
    const nftId = receipt.events[0].args[3].toString();
    // Return the transaction hash and the NFT id.
    return { status: "Minting complete.", tx: tx.hash, nftId: nftId }
    // If something goes wrong, catch that error.
  } catch (error) { return { status: "Something went wrong: " + error.message }; }
};

export const attachNftToCid = async (nftId, cid) => {
  // Do not allow the user call this function without a nftId and cid
  if ( !nftId || !cid) { return { success: false, status: "Please complete all fields before attaching." } }
  // Create a new provider, which is an abstraction of a connection to the Ethereum network.
  const provider = importProvider();
  // Select 'dev', 'stage', or 'prod' environment to determine which smart contract to use. Default is 'prod'.
  const env = "dev";
  // Get the appropriate Freeport contract address, based on environment selected above.
  const contractAddress = await getNFTAttachmentAddress(provider, env);
  // Create an instance of the Freeport contract using the provider and Freeport contract address
  const contract = createNFTAttachment({ provider, contractAddress });
  // You need 46 bytes to store a IPFS CID.
  // If you express it in hexadecimal, it becomes 34 bytes long (68 characters with 1 byte per 2 characters).
  // However, the first two characters of the hexadecimal represent the hash function being used.
  // Since that's the only format that IPFS uses, we can drop this information and obtain a 32 byte long
  // value that fits in a bytes32 fixed-size byte array required by 'attachToNFT' smart contract function below.
  const bytes32FromIpfsHash = "0x"+bs58.decode(cid).slice(2).toString('hex');
  try {
    // Call the attachToNFT() function from the CreateNFTAttachment smart contract.
    const tx = await contract.attachToNFT(nftId, bytes32FromIpfsHash);
    // Return the transaction hash of this attachement.
    return { success: true, status: "NFT and CID attached.", tx: tx.hash };
    // If something goes wrong, catch that error.
  } catch (error) { return { success: false, status: "Something went wrong: " + error.message }; }
};

// Helper functions
const sleepFor = async (x) => new Promise((resolve, _) => {
  setTimeout(() => resolve(), x*1000);
});

export const utilStr2ByteArr = (str) => {
    const arr = [];
    for (let i = 0; i < str.length; i++) {
        arr.push(str.charCodeAt(i));
    }
    return arr;
}
