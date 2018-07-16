    pragma solidity ^0.4.24;
    pragma experimental ABIEncoderV2;
    
    contract ForeignToken{
        function getSerializedData(uint _tokenId) returns (bytes[]);
        function recoveryToken(uint _tokenId, bytes[] _tokenData);
        function transfer(uint _tokenId, address _to) public;
        function demolishToken(uint _tokenId);
    }
    
    contract ForeignBridge{
        
        constructor(address _addr, address[] _valiodators, uint _requredSignature) public{
            homeContractAddr = _addr;
            requiredSignatures = _requredSignature;
            for (uint i = 0; i < _valiodators.length; i++){
                isValidator[_valiodators[i]] = true;
            }
        }
        
        address homeContractAddr;
        uint requiredSignatures;
        
        mapping (address => bool) isValidator;
        mapping (bytes32 => bool) isTokenRecovered;
        mapping (bytes32 => bool) isValidatorAlrHanded;
        mapping (bytes32 => uint) countForRecovery;
            
        ForeignToken foreignToken = ForeignToken(homeContractAddr);
        
        event userRequestForSignature(uint _tokenId, bytes[] _tokenData);
        
        function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4){
            emit userRequestForSignature(_tokenId, foreignToken.getSerializedData(_tokenId));
            foreignToken.demolishToken(_tokenId);
            return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
        }   
        
        event transferCompleted(uint _tokenId);
        
        function transferApproved(address _owner, uint _tokenId, bytes[] _tokenData, bytes32 _txHash){
            require(isValidator[msg.sender]);
            require(!isTokenRecovered[_txHash]);
            bytes32 hash = keccak256(abi.encodePacked(_txHash, msg.sender));
            require(!isValidatorAlrHanded[hash]);
            isValidatorAlrHanded[hash] = true;
            bytes memory _tokenData1;
            for (uint i = 0; i < _tokenData.length; i++){
                _tokenData1 =  abi.encodePacked(_tokenData1, _tokenData[i]);
            }
            hash = keccak256(abi.encodePacked(_txHash, msg.sender, _tokenId, _tokenData1));
            countForRecovery[hash]++;
            if(countForRecovery[hash] >= requiredSignatures){
                foreignToken.recoveryToken(_tokenId, _tokenData);
                foreignToken.transfer(_tokenId, _owner);
                isTokenRecovered[_txHash] = true;
                emit transferCompleted(_tokenId);    
            }
        }
    }
