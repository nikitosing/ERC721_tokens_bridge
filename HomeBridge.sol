pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract HomeToken{
    function getSerializedData(uint _tokenId) returns (bytes[]);
    function recoveryToken(uint _tokenId, bytes[] _tokenData);
    function transfer(uint _tokenId, address _to) public;
}

contract HomeBridge{
    
    constructor(address _addr) public{
        homeContractAddr = _addr;
    }
    
    address homeContractAddr;
    
    HomeToken homeToken = HomeToken(homeContractAddr);
    
    event userRequestForSignature(uint _tokenId, bytes[] _tokenData);
    
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4){
        emit userRequestForSignature(_tokenId, homeToken.getSerializedData(_tokenId));
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }   
    
    event transferCompleted(uint _tokenId);
    
    function transferApproved(address _owner, uint _tokenId, bytes[] _tokenData){
        homeToken.recoveryToken(_tokenId, _tokenData);
        homeToken.transfer(_tokenId, _owner);
        emit transferCompleted(_tokenId);    }
}
