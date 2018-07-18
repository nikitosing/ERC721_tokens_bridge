from web3 import Web3, HTTPProvider

print('BEGIN')

#initialization
sokol = Web3(HTTPProvider('https://sokol.poa.network/'))
kovan = Web3(HTTPProvider('https://kovan.infura.io/'))


abiForeign = """
[
	{
		"constant": false,
		"inputs": [
			{
				"name": "_operator",
				"type": "address"
			},
			{
				"name": "_from",
				"type": "address"
			},
			{
				"name": "_tokenId",
				"type": "uint256"
			},
			{
				"name": "_data",
				"type": "bytes"
			}
		],
		"name": "onERC721Received",
		"outputs": [
			{
				"name": "",
				"type": "bytes4"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_owner",
				"type": "address"
			},
			{
				"name": "_tokenId",
				"type": "uint256"
			},
			{
				"name": "_tokenData",
				"type": "bytes[]"
			},
			{
				"name": "_txHash",
				"type": "bytes32"
			}
		],
		"name": "transferApproved",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"name": "_addr",
				"type": "address"
			},
			{
				"name": "_valiodators",
				"type": "address[]"
			},
			{
				"name": "_requredSignature",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "_tokenId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "_tokenData",
				"type": "bytes[]"
			}
		],
		"name": "userRequestForSignature",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "_tokenId",
				"type": "uint256"
			}
		],
		"name": "transferCompleted",
		"type": "event"
	}
]
"""

abiHome = """
[
	{
		"constant": false,
		"inputs": [
			{
				"name": "_operator",
				"type": "address"
			},
			{
				"name": "_from",
				"type": "address"
			},
			{
				"name": "_tokenId",
				"type": "uint256"
			},
			{
				"name": "_data",
				"type": "bytes"
			}
		],
		"name": "onERC721Received",
		"outputs": [
			{
				"name": "",
				"type": "bytes4"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "_owner",
				"type": "address"
			},
			{
				"name": "_tokenId",
				"type": "uint256"
			},
			{
				"name": "_tokenData",
				"type": "bytes[]"
			},
			{
				"name": "_txHash",
				"type": "bytes32"
			}
		],
		"name": "transferApproved",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"name": "_addr",
				"type": "address"
			},
			{
				"name": "_valiodators",
				"type": "address[]"
			},
			{
				"name": "_requredSignature",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "_from",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "_tokenId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "_tokenData",
				"type": "bytes[]"
			}
		],
		"name": "userRequestForSignature",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "_tokenId",
				"type": "uint256"
			}
		],
		"name": "transferCompleted",
		"type": "event"
	}
]
"""

home = kovan.eth.contract(
    address = Web3.toChecksumAddress("0x55133D6dE29F06f9d516e7F1A514af05031483E9"),
    abi = abiHome,
)

foreign = kovan.eth.contract(
    address = Web3.toChecksumAddress("0x55133D6dE29F06f9d516e7F1A514af05031483E9"),
    abi = abiForeign,
)
#endInitilization

x = 0

to_block = kovan.eth.getBlock("latest")['number']

filter_params = {
    "fromBlock": x,
    'toBlock': to_block,
    "address": home.address,
}

result = kovan.eth.getLogs(filter_params)

#x = to_block + 1

for i in result:
    tx = i['transactionHash']
    rec = kovan.eth.getTransactionReceipt(tx)
    events = home.events.userRequestForSignature().processReceipt(rec)
    if(len(events) != 0):
        print(kovan.toHex(tx))
        for ev in events:
            print("  "+str(ev.args))


print('END')
