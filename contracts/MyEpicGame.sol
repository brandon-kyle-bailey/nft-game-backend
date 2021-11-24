//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";
import "./lib/Base64.sol";

contract MyEpicGame is ERC721{

    using SafeMath for uint;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;


    struct CharacterAttributesStruct {
        uint index;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    CharacterAttributesStruct[] defaultCharacters;
    
    mapping(uint => CharacterAttributesStruct) public nftHolderAttributes;
    mapping(address => uint) public nftHolders;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg
        ) ERC721("Heroes", "HERO") {
            for(uint i = 0; i < characterNames.length; i+=1) {
                defaultCharacters.push(CharacterAttributesStruct({
                    index: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
                    attackDamage: characterAttackDmg[i]
                }));
                console.log("Done initializing %s w/ HP %s, img %s", characterNames[i], characterHp[i], characterImageURIs[i]);
                _tokenIds.increment();
            }
    }

    function mint(uint _index) external {
        uint newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        nftHolderAttributes[newItemId] = CharacterAttributesStruct({
        index: _index,
        name: defaultCharacters[_index].name,
        imageURI: defaultCharacters[_index].imageURI,
        hp: defaultCharacters[_index].hp,
        maxHp: defaultCharacters[_index].maxHp,
        attackDamage: defaultCharacters[_index].attackDamage
        });
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        CharacterAttributesStruct memory charAttributes = nftHolderAttributes[_tokenId];
        string memory strHp = Strings.toString(charAttributes.hp); 
        string memory strMaxHp = Strings.toString(charAttributes.maxHp); 
        string memory strAttackDamage = Strings.toString(charAttributes.attackDamage); 

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        ' -- NFT #: ',
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,'} ]}'
                    )
                )
            )
        );

        string memory output = string(abi.encodePacked("data:application/json;base64,", json));
        return output;
    }
}