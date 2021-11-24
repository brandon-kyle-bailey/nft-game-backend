const deploy = async () => {
    const contractFactory = await hre.ethers.getContractFactory("MyEpicGame");
    const contract = await contractFactory.deploy(
        ["Leo", "Aang", "Pikachu"],
        ["https://i.imgur.com/pKd5Sdk.png",
        "https://i.imgur.com/xVu4vFL.png",
        "https://i.imgur.com/WMB6g9u.png"],
        [100, 200, 300],
        [100, 50, 25]
    );
    await contract.deployed();
    console.log(`Contract deployed: ${contract.address}`);

    // let txn;
    // txn = await contract.mint(0);
    // await txn.wait();
    // console.log("Minted NFT #1");
  
    // txn = await contract.mint(1);
    // await txn.wait();
    // console.log("Minted NFT #2");
  
    // txn = await contract.mint(2);
    // await txn.wait();
    // console.log("Minted NFT #3");
  
    // txn = await contract.mint(3);
    // await txn.wait();
    // console.log("Minted NFT #4");
  
    // console.log("Done deploying and minting!");
}

const main = async () => {
    try {
        await deploy();
        process.exit(0);
    } catch (error) {
        console.log(error)
        process.exit(1);
    }
}

main();