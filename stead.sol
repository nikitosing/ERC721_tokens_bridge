pragma solidity ^0.4.24;
contract Stead
{
    
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
