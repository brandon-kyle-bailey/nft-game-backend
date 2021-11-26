const deploy = async (contractName) => {
    const contractFactory = await hre.ethers.getContractFactory(contractName);
    const boss = {
        name: "Elon Musk",
        image_uri: "https://i.imgur.com/AksR0tt.png",
        hp: "10000",
        max_hp: "10000",
        attack_damage: "50"        
    };
    const characters = [
        {
            index: 0,
            name: "Leo",
            image_uri: "https://i.imgur.com/pKd5Sdk.png",
            hp: "100",
            max_hp: "100",
            attack_damage: "100"
        },
        {
            index: 1,
            name: "Aang",
            image_uri: "https://i.imgur.com/xVu4vFL.png",
            hp: "200",
            max_hp: "200",
            attack_damage: "50"
        },
        {
            index: 2,
            name: "Pikachu",
            image_uri: "https://i.imgur.com/WMB6g9u.png",
            hp: "300",
            max_hp: "300",
            attack_damage: "25"
        },
    ];
    const contract = await contractFactory.deploy(characters, boss);
    await contract.deployed();
    console.log(`Contract deployed: ${contract.address}`);
    // let txn;
    // for(let i = 0; i < characters.length; i++) {
    //     txn = await contract.mint(i, {gasLimit: 10000000});
    //     await txn.wait();
    //     console.log(`Minted NFT #${i}`);
    //     txn = await contract.attackBoss({gasLimit: 10000000});
    //     await txn.wait();
    //     txn = await contract.attackBoss({gasLimit: 10000000});
    //     await txn.wait();
    // }
    // console.log("Done deploying and minting!");
}

const main = async () => {
    try {
        await deploy("GenesisGame");
        process.exit(0);
    } catch (error) {
        console.log(error)
        process.exit(1);
    }
}

main();