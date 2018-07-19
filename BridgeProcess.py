from web3 import Web3, HTTPProvider

print('BEGIN')

#initialization
sokol = Web3(HTTPProvider('https://sokol.poa.network/'))
kovan = Web3(HTTPProvider('https://kovan.infura.io/'))
privateKey =  "48656c6c6f2c20776f726c6448656c6c6f2c20776f726c6448656c6c6f2c2048"

acct = sokol.eth.account.privateKeyToAccount(privateKey)

abiForeign = """
[
  {
    "constant": false,
    "inputs": [
      {
        "name": "_owner",
        "type": "address"
      },
      {
        "name": "_tokenVIN",
        "type": "string"
      },
      {
        "name": "_serializedData",
        "type": "bytes"
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
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "name": "_from",
        "type": "address"
      },
      {
        "indexed": false,
        "name": "_tokenVIN",
        "type": "string"
      },
      {
        "indexed": false,
        "name": "_data",
        "type": "bytes"
      }
    ],
    "name": "UserRequestForSignature",
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
        "name": "_owner",
        "type": "address"
      },
      {
        "name": "_tokenVIN",
        "type": "string"
      },
      {
        "name": "_serializedData",
        "type": "bytes"
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
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "name": "_from",
        "type": "address"
      },
      {
        "indexed": false,
        "name": "_tokenVIN",
        "type": "string"
      },
      {
        "indexed": false,
        "name": "_data",
        "type": "bytes"
      }
    ],
    "name": "UserRequestForSignature",
    "type": "event"
  }
]
"""

home = sokol.eth.contract(
    address = Web3.toChecksumAddress("0xaf5d6cceab8c071741545fe7e0da0512461f6b62"),
    abi = abiHome
)

foreign = kovan.eth.contract(
    address = Web3.toChecksumAddress("0xaf5d6cceab8c071741545fe7e0da0512461f6b62"),
    abi = abiForeign
)
#endInitilization

"""x = 0

to_block = kovan.eth.getBlock("latest")['number']

filter_params = {
    "fromBlock": x,
    'toBlock': to_block,
    "address": home.address,
}

result = kovan.eth.getLogs(filter_params)"""

#x = to_block + 1

lastProcessedHomeBlock = 0
nonce = kovan.eth.getTransactionCount(acct.address)
tx_foreign = {
"gas":7000000,
"gasPrice":Web3.toWei(1, "gwei"),
"nonce":nonce

}

filter_ = {
  "fromBlock": lastProcessedHomeBlock,
    'toBlock': "latest",
    "address": home.address,
}
result = sokol.eth.getLogs(filter_)
for i in result:
    tx = i['transactionHash']
    rec = sokol.eth.getTransactionReceipt(tx)
    print(rec)
    events = home.events.UserRequestForSignature().processReceipt(rec)
    print(events)
    for ev in events:
      foreign.functions.transferApproved(
        ev.args['_from'],
        ev.args['_tokenVIN'],
        ev.args['_data'],
        ev.transactionHash,
      ).buildTransaction(tx_foreign)
      signed_tx = acct.signTransaction(tx)
      tx_hash = kovan.eth.sendRawTransaction(signed_tx.rawTransaction)
      kovan.eth.waitForTransactionReceipt(tx_hash)
      print(tx_hash)
      break
    break   

print('END')
