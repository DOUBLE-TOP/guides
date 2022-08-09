import { React, useEffect, useState } from "react";
import { connectWallet, getCurrentWalletConnected, mintNFT, upload2DDC, downloadFromDDC, attachNftToCid } from "./actions.js";

const Main = (props) => {

  // State variables - Connecting wallet
  const [walletAddress, setWalletAddress] = useState("");
  // State variables - Upload content
        const [uploadData, setUploadData] = useState(null);
  const [uploadDataTitle, setUploadDataTitle] = useState("")
  const [uploadDataDescription, setUploadDataDescription] = useState("")
  const [cid, setCid] = useState(null);
  // State variables - Download content
  const [preview, setPreview] = useState(null);
  const [downloadedImage, setDownloadedImage] = useState(null);
  // State variables - Mint NFT
  const [metadata, setMetadata] = useState("");
  const [qty, setQty] = useState(1);
  const [nftId, setNftId] = useState(null);
  // State variables - Statuses
  const [status, setStatus] = useState("");
  const [uploadOutput, setUploadOutput] = useState("Content ID:");
  const [mintOutput, setMintOutput] = useState("NFT ID:");
  const [attachOutput, setAttachOutput] = useState("Attachment transaction link:");


  function addWalletListener() {
    // Check if metamask is installed
    if (window.ethereum) {
        // Listen for state changes in the metamask wallet such as:
        window.ethereum.on("accountsChanged", (accounts) => {
          // If there is at least one account, update the state variables 'walletAddress' and 'status'
          if (accounts.length > 0) {
            setWalletAddress(accounts[0]);
            setStatus("Follow the steps below.");
          // If metamask is installed but there are no accounts, then it must not be connected.
          } else { setStatus("Connect to Metamask using the top right button."); }
        });
      // If metamask is not installed, then ask them to install it.
    } else { setStatus("Please install metamask and come back"); }
  };

  const connectWalletPressed = async () => {
    // Call our connectWallet function from the previous step and await response.
    const { status, address } = await connectWallet();
    setStatus(status);
    setWalletAddress(address);
  };

  useEffect(async () => {
    // The 'callback' side-effect logic
    const {address, status} = await getCurrentWalletConnected();
    setWalletAddress(address)
    setStatus(status);
    addWalletListener();
    // The 'dependencies' array
  }, []);

  const onUploadPressed = async () => {
    const { contentId, status } = await upload2DDC(uploadData, uploadDataTitle, uploadDataDescription);
    setStatus(status);
    setUploadOutput("Content ID: " + contentId);
  }

  const onDownloadPressed = async () => {
    const { status, content} = await downloadFromDDC(cid);
    setStatus(status);
    setDownloadedImage(URL.createObjectURL(content));
  };

  const onMintPressed = async () => {
    const { tx, nftId, status } = await mintNFT(+qty, metadata)
    setStatus(status);
    setMintOutput("NFT ID: " + nftId);
  };


  const onAttachPressed = async () => {
    const { status, tx } = await attachNftToCid(nftId, cid);
    setStatus(status);
    setAttachOutput(<a href={"https://mumbai.polygonscan.com/tx/"+tx}>Attachment transaction hash: {tx}</a>)
  };

  const onClearOutputPressed = async () => {
    setStatus("Follow the steps below.");
    setUploadData(null);
    setPreview(null);
    setUploadOutput("Content ID:")
    setMintOutput("NFT ID:")
    setAttachOutput("Attachment transaction link:")
  };

  return (
    <div className="Main">
      <br></br>
      <button id="walletButton" onClick={connectWalletPressed}>
        {walletAddress.length > 0 ? ("Connected: " + String(walletAddress).substring(0, 6) + "..." + String(walletAddress).substring(38)) : (<span>Connect Wallet</span>)}
      </button>
      <br></br>
      <h1 id="title"> Create an NFT with Cere Freeport and DDC </h1>

      <div class="header">
        <h3>Status message:</h3>
      <p id="status"> {status} </p>
      </div>

      <div class="header2">
        <h3>Outputs:</h3>
      <p id="output"> {uploadOutput} </p>
      <p id="output"> Downloaded image: </p>
      {downloadedImage ? <img src={downloadedImage} style={{width: "200px"}}></img>: null}
      <p id="output"> {mintOutput} </p>
      <p id="output"> {attachOutput} </p>
      </div>
      <button id="actionButton" onClick={onClearOutputPressed}>Clear output</button>

      <br></br><br></br><br></br>
      <h2> Upload your content to DDC </h2>
      {<img src={preview} style={{width: "200px"}}></img>}
      <br></br>
      <form class="form" id="myform">
      <input type="file" id="inpFile" onChange={(event) => { setUploadData(event.target.files[0]); setPreview(URL.createObjectURL(event.target.files[0])); }}></input>
      </form>
      &nbsp;
      <input type="text" placeholder="Give your content a title." onChange={(event) => setUploadDataTitle(event.target.value)}/>
      &nbsp;
      <input type="text" placeholder="Give your content a description." onChange={(event) => setUploadDataDescription(event.target.value)}/>
      <button id="actionButton" onClick={onUploadPressed}> Upload </button>

      <br></br><br></br>
      &nbsp;
      <h2> Verify that your content was uploaded by downloading it from DDC </h2>
      <input type="text" placeholder="Enter content ID returned from upload step." onChange={(event) => setCid(event.target.value)}/>
      <button id="actionButton" onClick={onDownloadPressed}> Download </button>

      <br></br><br></br>
      &nbsp;
      <h2> Mint NFT(s) with the Freeport Smart Contract </h2>
      <input type="text" placeholder="Enter some token metadata." onChange={(event) => setMetadata(event.target.value)}/>
      &nbsp;
      <input type="number" placeholder="Enter the number of copies to mint." value={qty} onChange={(event) => setQty(event.target.value)}/>
      <button id="actionButton" onClick={onMintPressed}> Mint NFT</button>

      <br></br><br></br>
      <h2> Attach NFT to CID </h2>
      <input type="text" placeholder="Enter your NFT id." onChange={(event) => setNftId(event.target.value)}/>
      &nbsp;
      <input type="text" placeholder="Enter your content id." onChange={(event) => setCid(event.target.value)}/>
      <button id="actionButton" onClick={onAttachPressed}> Attach</button>
      <br></br><br></br><br></br><br></br>
    </div>
  );
};

export default Main;
