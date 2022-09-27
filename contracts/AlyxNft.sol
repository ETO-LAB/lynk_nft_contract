// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "./baseContract.sol";
import "./DBContract.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract AlyxNft is ERC721EnumerableUpgradeable,baseContract {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter public currentTokenId;

    uint256 private randomSeed;
    mapping(uint256 => NFTInfo) public nftInfoOf;
    mapping(address => uint256) public lastMintTime;

    enum NFTType {
        Boy,
        Girl
    }

    struct NFTInfo {
        NFTType nftType;
        uint256 charisma;
        uint256 dexterity;
        uint256 vitality;
        uint256 intellect;
    }

    constructor(address dbAddress) baseContract(dbAddress){

    }

    function __KeyToken_init() public initializer {
        __AlyxNft_init_unchained();
        __ERC721Enumerable_init();
        __ERC721_init("AlyxNft","AlyxNft");
        __baseContract_init();
    }

    function __AlyxNft_init_unchained() private onlyInitializing {
        _randomSeedGen();
    }

    function mintTo(NFTType _nftType, address _to, uint256 _numNFT, address _payment) external {
        require(
            _numNFT <= DBContract(DB_CONTRACT).maxMintPerDayPerAddress() &&
            block.timestamp - lastMintTime[_msgSender()] >= 1 days,
                'AlyxNft: cannot mint more in a day.'
        );
        lastMintTime[_msgSender()] = block.timestamp;

        require(
            DBContract(DB_CONTRACT).AU_TOKEN() == _payment ||
            DBContract(DB_CONTRACT).USDT_TOKEN() == _payment,
                'AlyxNft: unsupported payment.'
        );
        uint256 mintPrice = DBContract(DB_CONTRACT).mintPriceInAU();
        if (DBContract(DB_CONTRACT).USDT_TOKEN() == _payment)
            mintPrice = DBContract(DB_CONTRACT).mintPriceInUSDT();
        uint256 mintPriceTotal = mintPrice * _numNFT;

        require(
            IERC20Upgradeable(_payment).allowance(_msgSender(), address(this)) >= mintPriceTotal,
                'AlyxNft: insufficient allowance'
        );
        IERC20Upgradeable(_payment).safeTransferFrom(_msgSender(), DBContract(DB_CONTRACT).recipient(), mintPriceTotal);

        for (uint256 index; index < _numNFT; index++) {
            uint256 tokenId = currentTokenId.current();

            (uint256 vitality, uint256 intellect) = _attributesGen(_msgSender());
            nftInfoOf[tokenId] = NFTInfo({
                nftType: _nftType,
                vitality: vitality,
                intellect: intellect,
                dexterity: 0,
                charisma: 0
            });
            ERC721Upgradeable._safeMint(_to, tokenId);
        }
    }

    function _attributesGen(address _minter) private returns (uint256 _vitality, uint256 _intellect) {
        uint256 _randomSeed = _randomSeedGen();
        _randomSeed = uint256(keccak256(abi.encodePacked(_randomSeed, _minter)));
        _vitality = ((_randomSeed & 0xff) % 5) + 1;
        _intellect = (((_randomSeed >> 128) & 0xff) % 3) + 1;
    }

    function _randomSeedGen() private returns (uint256 _randomSeed) {
        _randomSeed = uint256(keccak256(abi.encodePacked(randomSeed, block.timestamp, block.difficulty)));
        randomSeed = _randomSeed;
    }
}
