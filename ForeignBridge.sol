    pragma solidity ^0.4.24;
    pragma experimental ABIEncoderV2;
    
    contract ForeignToken{
        function getSerializedData(uint _tokenId) returns (bytes[]);
        function recoveryToken(uint _tokenId, bytes[] _tokenData);
        function transfer(uint _tokenId, address _to) public;
        function demolishToken(uint _tokenId);
    }
    
    contract ForeignBridge{
        
        constructor(address _addr) public{
            homeContractAddr = _addr;
        }
        
        address homeContractAddr;
        
        ForeignToken foreignToken = ForeignToken(homeContractAddr);
        
        event userRequestForSignature(uint _tokenId, bytes[] _tokenData);
        
        function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4){
            emit userRequestForSignature(_tokenId, foreignToken.getSerializedData(_tokenId));
            foreignToken.demolishToken(_tokenId);
            return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
        }   
        
        event transferCompleted(uint _tokenId);
        
        function transferApproved(address _owner, uint _tokenId, bytes[] _tokenData){
            foreignToken.recoveryToken(_tokenId, _tokenData);
            foreignToken.transfer(_tokenId, _owner);
            emit transferCompleted(_tokenId);    }
    }
