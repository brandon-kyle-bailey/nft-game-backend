//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./lib/Base64.sol";


contract GenesisGame is ERC721 {

    modifier canMint(uint256 token_count, uint256 index_value) {
        require(
            index_value >= 0 && index_value < token_count,
            "A token does not exist as this index."
        );
        _;
    }

    modifier canAttack(address sender) {
        require(
            token_holder_character[token_holders[sender]].hp > 0 && boss_character.hp > 0,
            "Error: Boss and Character must have HP to attack."
        );
        _;
    }

    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _token_id_counter;

    struct CharacterStruct {
        uint256 index;
        string name;
        string image_uri;
        uint256 hp;
        uint256 max_hp;
        uint256 attack_damage;
    }

    struct BossCharacterStruct {
        string name;
        string image_uri;
        uint256 hp;
        uint256 max_hp;
        uint256 attack_damage;
    }

    CharacterStruct[] genesis_characters;
    
    BossCharacterStruct public boss_character;
    
    mapping(uint256 => CharacterStruct) public token_holder_character;
    mapping(address => uint256) public token_holders;

    event TokenMinted(address sender, uint256 token_id, uint256 token_index);
    event AttackComplete(uint256 new_boss_hp, uint256 new_player_hp);

    constructor(CharacterStruct[] memory _genesis_tokens, BossCharacterStruct memory _boss_character) ERC721("Heroes", "HERO") {
        boss_character = BossCharacterStruct({
        name: _boss_character.name,
        image_uri: _boss_character.image_uri,
        hp: _boss_character.hp,
        max_hp: _boss_character.max_hp,
        attack_damage: _boss_character.attack_damage
        });

        for (uint256 i = 0; i < _genesis_tokens.length; i += 1 ) {
            genesis_characters.push(CharacterStruct({
                index: i,
                name:_genesis_tokens[i].name,
                image_uri:_genesis_tokens[i].image_uri,
                hp:_genesis_tokens[i].hp,
                max_hp:_genesis_tokens[i].max_hp,
                attack_damage:_genesis_tokens[i].attack_damage
            }));
        }
    }

    function mint(uint256 _token_index) external canMint(genesis_characters.length, _token_index) {
        
        uint256 new_token_id = _token_id_counter.current();
        
        _safeMint(msg.sender, new_token_id);

        token_holder_character[new_token_id] = CharacterStruct({
        index: _token_index,
        name: genesis_characters[_token_index].name,
        image_uri: genesis_characters[_token_index].image_uri,
        hp: genesis_characters[_token_index].hp,
        max_hp: genesis_characters[_token_index].max_hp,
        attack_damage: genesis_characters[_token_index].attack_damage
        });
        
        token_holders[msg.sender] = new_token_id;

        _token_id_counter.increment();
        emit TokenMinted(msg.sender, new_token_id, _token_index);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        CharacterStruct memory character = token_holder_character[_tokenId];
        string memory strHp = Strings.toString(character.hp);
        string memory strMaxHp = Strings.toString(character.max_hp);
        string memory strAttackDamage = Strings.toString(character.attack_damage);
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',character.name, ' -- NFT #: ', Strings.toString(_tokenId), '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "', character.image_uri, '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value": ',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',strAttackDamage,', "max_value": ', strAttackDamage, '} ]}'
                    )
                )
            )
        );
        string memory output = string(abi.encodePacked("data:application/json;base64,", json));
        return output;
    }

    function attackBoss() public canAttack(msg.sender) {
        uint256 token_id_of_player = token_holders[msg.sender];
        CharacterStruct storage player = token_holder_character[token_id_of_player];
        console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attack_damage);
        console.log("Boss %s has %s HP and %s AD", boss_character.name, boss_character.hp, boss_character.attack_damage);

        require(player.hp > 0 && boss_character.hp > 0, "Error: Boss and Character must have HP to attack.");
        
        if (boss_character.hp < player.attack_damage) {
            boss_character.hp = 0;
        } else {
            boss_character.hp -= player.attack_damage;
        }

        if (player.hp < boss_character.attack_damage) {
            player.hp = 0;
        } else {
            player.hp -= boss_character.attack_damage;
        }

        console.log("Player attacked boss. New boss hp: %s", boss_character.hp);
        console.log("Boss attacked player. New player hp: %s\n", player.hp);
        emit AttackComplete(boss_character.hp, player.hp);
    }

    function getUsersToken() public view returns (CharacterStruct memory) {
        uint256 token_id = token_holders[msg.sender];
        if (token_id > 0) {
            return token_holder_character[token_id];
        }
        CharacterStruct memory emptyStruct;
        return emptyStruct;
    }

    function getGenesisCharacters() public view returns (CharacterStruct[] memory) {
        return genesis_characters;
    }

    function getBoss() public view returns (BossCharacterStruct memory) {
        return boss_character;
    }
}