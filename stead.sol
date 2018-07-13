pragma solidity ^0.4.24;
contract Check{
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);    
}

contract Stead{
    event OnERC721Received();
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4){
        emit OnERC721Received();
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }    
    
    struct Section{
        uint scale;
        string place;
        address owner;
        uint tokenId;
        bool withHouse;
        string cadastralNumber;
    } 
    
    address supplier;
    Section[] sections;
    
    constructor() public{
        supplier = msg.sender;
    }
    
    event FirstRegSection (uint _tokenId, uint _scale, string _location, bool _withHouse, string _cadastralNumber);
    
    function firstRegSection(uint _scale, string _location, bool _withHouse, string _cadastralNumber) public{
        require(supplier==msg.sender);
        
        sections.push(Section(_scale, _location, supplier, sections.length, _withHouse, _cadastralNumber));
        emit FirstRegSection ((sections.length-1), _scale, _location,  _withHouse,  _cadastralNumber);
    }
    
    event Transfer (address _from, address _to, uint _tokenId);
    
    function transfer(uint _tokenId, address _to) public{
        require(sections[_tokenId].owner==msg.sender);
        sections[_tokenId].owner=_to;
        emit Transfer(msg.sender, _to, _tokenId);
    }
    
    event SafeTransferFrom (address _from, address _to, uint _tokenId);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{
        require(msg.sender==_from);
        require(sections[_tokenId].owner==msg.sender);
        if (isContract(_to)){
            Check check = Check(_to);
            require(check.onERC721Received(_to, _from, _tokenId, "")==bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
        }
        sections[_tokenId].owner=_to;
        emit SafeTransferFrom(_from, _to, _tokenId);
    }
    
    function isContract(address addr) returns (bool) {
         uint size;
         assembly { size := extcodesize(addr) }
         return size > 0;
    }
    
    function buildHouse(uint _tokenId) public{
        require(msg.sender==sections[_tokenId].owner);
        require(!sections[_tokenId].withHouse);
        sections[_tokenId].withHouse = true;
    }
    
    function destroyHouse(uint _tokenId) public{
        require(msg.sender==sections[_tokenId].owner);
        require(sections[_tokenId].withHouse);
        sections[_tokenId].withHouse = false;
    }
    
}
