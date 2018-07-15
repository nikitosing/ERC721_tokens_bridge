pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract Bridge{
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);    
}

contract HomeToken{
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
    
    mapping (address => uint[]) public indexTokenOfOwner;
    mapping (address => uint) countOfOwner;
    mapping (address => bool) permissionToRecover;
    mapping (address => bool) permissionToDemolish;
    
    address supplier;
    Section[] sections;
    string total_info = "";
    bool canCreate = false;
    
    constructor(bool _can) public{
        supplier = msg.sender;
        canCreate = _can;
    }
    
    event FirstRegSection (uint _tokenId, uint _scale, string _location, bool _withHouse, string _cadastralNumber);
    
    function firstRegSection(uint _scale, string _location, bool _withHouse, string _cadastralNumber) public{
        require(supplier==msg.sender);
        require(canCreate);
        sections.push(Section(_scale, _location, supplier, sections.length, _withHouse, _cadastralNumber));
        countOfOwner[supplier]++;
//        indexTokenOfOwner[supplier].push((sections.length-1));//need change
        emit FirstRegSection ((sections.length-1), _scale, _location,  _withHouse,  _cadastralNumber);
    }
    
    function ownerOf(uint256 _tokenId) external view returns (address){
        return sections[_tokenId].owner;
    }
    
    function balanceOf(address _owner) external view returns (uint256){
        return countOfOwner[_owner];
    }
    
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256){
        return ;//need change
    }
    
    function setPermissionToRecover(address _addr){
        permissionToRecover[_addr] = true;
    }
    
     function setPermissionToDemolish(address _addr){
        permissionToDemolish[_addr] = true;
    }
    
    function getSerializedData(uint _tokenId) returns (bytes[]){
        bytes[] memory data = new bytes [](6);
        data[0] = (abi.encodePacked(sections[_tokenId].scale));
        data[1] = (abi.encodePacked(sections[_tokenId].place));
        data[2] = (abi.encodePacked(sections[_tokenId].owner));
        if (sections[_tokenId].withHouse){
            data[4] = (abi.encodePacked(1));    
        } else{
             data[4] = (abi.encodePacked(0));    
        }
        data[3] = (abi.encodePacked(sections[_tokenId].tokenId));
        data[5] = (abi.encodePacked(sections[_tokenId].cadastralNumber));
        return data;
    }
    
    function recoveryToken(uint _tokenId, bytes[] _tokenData){
        require(permissionToRecover[msg.sender]);
        bytes[] memory _data = _tokenData;
        sections[_tokenId].scale = bytesToUint(_data[0]);
        sections[_tokenId].place = string(_data[1]);
        sections[_tokenId].owner = bytesToAddress(_data[2]);
        sections[_tokenId].tokenId = bytesToUint(_data[3]);
        if (bytesToUint(_data[4])==1){
            sections[_tokenId].withHouse = true;    
        } else {
            sections[_tokenId].withHouse = false;    
        }
        sections[_tokenId].cadastralNumber = string(_data[5]);
        //return (sections[_tokenId]);
    }

    function bytesToAddress(bytes _address) constant returns(address){
        uint res = 0;
        for (uint i = _address.length-1; i+1 > 0; i--){
            uint c = uint(_address[i]);
            uint to_inc = c * (16 ** ((_address.length - i - 1) * 2 ));
            res += to_inc;
        }
        return address(res);
    }
    
    function bytes32ToString(bytes32 x) public returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
    
    function bytesToUint(bytes b) public returns (uint256){
        uint256 number;
        for(uint i = 0; i<b.length; i++){
            number = number + uint(b[i]) * (2 ** (8 * (b.length - (i+1))));
        }
        return number;
    }
    
    event Transfer (address _from, address _to, uint _tokenId);
    
    function transfer(uint _tokenId, address _to) public{
        require(sections[_tokenId].owner==msg.sender);
        sections[_tokenId].owner=_to;
        countOfOwner[msg.sender]--;
        countOfOwner[_to]++;
        //delete indexTokenOfOwner[supplier].[]
       // push((sections.length-1));
        emit Transfer(msg.sender, _to, _tokenId);
    }
    
    event SafeTransferFrom (address _from, address _to, uint _tokenId);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{
        require(msg.sender==_from);
        require(sections[_tokenId].owner==msg.sender);
        if (isContract(_to)){
            Bridge bridge = Bridge(_to);
            require(bridge.onERC721Received(_to, _from, _tokenId, "")==bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
        }
        sections[_tokenId].owner=_to;
        countOfOwner[_from]--;
        countOfOwner[_to]++;
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
    
    function demolishToken(uint _tokenId){
        require(permissionToDemolish[msg.sender]);
        delete sections[_tokenId];
    }
    
}
