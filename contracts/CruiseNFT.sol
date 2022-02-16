// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract CruiseNFT is ERC721, ERC721URIStorage, Ownable {
    using Address for address;
    using Strings for uint256;

    string public baseURI = "";
    uint256 public mintIndex = 1;
    uint256 public availSupply = 5850;
    uint256 public withheldSupply = 150;
    uint256 public mintPrice = 0.3 ether;
    uint256 public salePrice;
    uint32 public denominator = 1000;

    struct CruiseSelect {
        uint256 tokenId;
        string tokenURI;
        address mintedBy;
        address currentOwner;
        address previousOwner;
        uint256 price;
        bool isForSale;
        bool isWithheld;
        uint16 votingCount;
    }

    mapping(uint256 => CruiseSelect) public allCruiseSelect;

    mapping(address => uint256) public mintedTotal;

    uint256 public maxCountPerWallet = 10;

    address private  cruiseOperationsWallet = 0x2947d8134f148B2A7Ed22C10FAfC4d6Cd42C1054;
    address private  devWallet = 0x86b5e7d1e189E3b4240A717C36C85C8bBf97a5FB;
    address private  investorGBWallet = 0x49C4D560C2b8C2C72962dA8B02B1C428d745a6Fd;
    address private  futureEmploymentWallet = 0xce9F8dDA015702E40cF697aDd3D55E2cF122c641;
    address private  ownershipWallet = 0xe34f72eD903c9f997B9f8658a1b082fd55093DA7;
    address private  eMaloneCDWallet = 0x79C61C20e9C407E4D768a78F7350B78157530183;
    address private  cruiseDaoWalletForCommunity = 0x12A75919B84810e02B1BD4b30b9C47da4c893B10;
    address private  cruiseDaoCharityWallet = 0xD48b024D9d0751f19Ab3D255101405EB534Ea76A;

    constructor() ERC721("CruiseNFT", "CDN") {}

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function setBaseUri(string memory _uri) external onlyOwner {
        baseURI = _uri;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function mint(address _to, string memory _tokenURI) public payable {
        if (msg.sender == cruiseOperationsWallet) {
            require(withheldSupply > 0, "Supply exceeded");
            _safeMint(_to, mintIndex);
            mintIndex += 1;
            _setTokenURI(mintIndex, _tokenURI);
            withheldSupply -= 1;

            CruiseSelect memory newCruiseSelect = CruiseSelect(
                mintIndex,
                _tokenURI,
                msg.sender,
                msg.sender,
                address(0),
                0,
                false,
                true,
                5
            );
            // add the token id and it's crypto boy to all crypto boys mapping
            allCruiseSelect[mintIndex] = newCruiseSelect;
        } else {
            require(availSupply > 0, "Supply exceeded");
            require(mintedTotal[msg.sender] < maxCountPerWallet, "Count per wallet exceeded");
            require(msg.value == mintPrice, "Ether value incorrect");
            _safeMint(_to, mintIndex);
            mintIndex += 1;
            _setTokenURI(mintIndex, _tokenURI);
            mintedTotal[msg.sender] += 1;
            availSupply -= 1;

            CruiseSelect memory newCruiseSelect = CruiseSelect(
                mintIndex,
                _tokenURI,
                msg.sender,
                msg.sender,
                address(0),
                mintPrice,
                false,
                false,
                5
            );
            // add the token id and it's crypto boy to all crypto boys mapping
            allCruiseSelect[mintIndex] = newCruiseSelect;
            distribute(mintPrice);
        }
        
    }

    function changeTokenPrice(uint256 _tokenId, uint256 _newPrice) public {
        // require caller of the function is not an empty address
        require(msg.sender != address(0), "Shouldn't be empty address");
        // require that token should exist
        require(_exists(_tokenId), "Token not exist");
        // require that token should not be withheld
        require(!allCruiseSelect[_tokenId].isWithheld, "Token shuold be reserve one");
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // check that token's owner should be equal to the caller of the function
        require(tokenOwner == msg.sender, "Invalid owner");
        // get that token from all crypto boys mapping and create a memory of it defined as (struct => CryptoBoy)
        CruiseSelect memory cruiseselect = allCruiseSelect[_tokenId];
        // update token's price with new price
        cruiseselect.price = _newPrice;
        // set and update that token in the mapping
        allCruiseSelect[_tokenId] = cruiseselect;
    }

    // switch between set for sale and set not for sale
    function toggleForSale(uint256 _tokenId) public {
        // require caller of the function is not an empty address
        require(msg.sender != address(0), "Shouldn't be empty address");
        // require that token should exist
        require(_exists(_tokenId), "Token not exist");
        // require that token should not be withheld
        require(!allCruiseSelect[_tokenId].isWithheld, "Token shuold be reserve one");
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // check that token's owner should be equal to the caller of the function
        require(tokenOwner == msg.sender, "Invalid owner");
        // get that token from all crypto boys mapping and create a memory of it defined as (struct => CryptoBoy)
        CruiseSelect memory cruiseselect = allCruiseSelect[_tokenId];
        // if token's forSale is false make it true and vice versa
        if(cruiseselect.isForSale) {
            cruiseselect.isForSale = false;
        } else {
            cruiseselect.isForSale = true;
        }
        // set and update that token in the mapping
        allCruiseSelect[_tokenId] = cruiseselect;
    }

    function distribute(uint256 _amount) private onlyOwner {
        payable(cruiseOperationsWallet).transfer(_amount * 150 / denominator);
        payable(devWallet).transfer(_amount * 25 / denominator);
        payable(investorGBWallet).transfer(_amount * 35 / denominator);
        payable(futureEmploymentWallet).transfer(_amount * 40 / denominator);
        payable(ownershipWallet).transfer(_amount * 200 / denominator);
        payable(eMaloneCDWallet).transfer(_amount * 100 / denominator);
        payable(cruiseDaoWalletForCommunity).transfer(_amount * 400 / denominator);
        payable(cruiseDaoCharityWallet).transfer(_amount * 50 / denominator);
    }

    // 
    function purchaseToken(uint256 _tokenId) public payable {
        // check if the function caller is not an zero account address
        require(msg.sender != address(0), "Shouldn't be empty address");
        // check if the token id of the token being bought exists or not
        require(_exists(_tokenId), "Token not exist");
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // token's owner should not be an zero address account
        require(tokenOwner != address(0), "Owner can't be empty address");
        // require that token should not be withheld
        require(!allCruiseSelect[_tokenId].isWithheld, "Token shuold not be withheld");
        // the one who wants to buy the token should not be the token's owner
        require(tokenOwner != msg.sender, "Shouldn't be owner");
        // get that token from all crypto boys mapping and create a memory of it defined as (struct => CryptoBoy)
        CruiseSelect memory cruiseselect = allCruiseSelect[_tokenId];
        // price sent in to buy should be equal to or more than the token's price
        require(msg.value == cruiseselect.price, "Ether value incorrect");
        // token should be for sale
        require(cruiseselect.isForSale, "Token is not for sale");
        // transfer the token from owner to the caller of the function (buyer)
        _transfer(tokenOwner, msg.sender, _tokenId);
        // send token's worth of ethers to the owner
        payable(cruiseselect.currentOwner).transfer(msg.value);
        // update the token's previous owner
        cruiseselect.previousOwner = cruiseselect.currentOwner;
        // update the token's current owner
        cruiseselect.currentOwner = msg.sender;
        distribute(cruiseselect.price / 10);
        // set and update that token in the mapping
        allCruiseSelect[_tokenId] = cruiseselect;
    }

}