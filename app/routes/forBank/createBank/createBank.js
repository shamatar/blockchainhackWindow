

module.exports = function(app, {bankBytecode}, {bankABI}, web3) {
  app.post('/banks/create', (req, res) => {

    const name = req.body.name;
    const url = req.body.url;
    const hash = 0x00;

    var password = "testing";
    try {
        web3.personal.unlockAccount(web3.eth.coinbase, password);
    } catch(e) {
        console.log(e);
        return;
    }
    // const contract = web3.eth.contract(abi);
    var BankContract = web3.eth.contract(bankABI);

// instantiate by address
    // var contractInstance = BankContract.at([address]);



// deploy new contract
    var contractInstance = BankContract.new("testBank", "https://testBank.url", 0x00, 
        {data: "0x"+bankBytecode, from: web3.eth.coinbase, gas: 3500000}, 
        function(e, contract){
            console.log(e);
            if (contractInstance.address){
                console.log(contractInstance);
                res.send({"ok":true, "address":contractInstance.address});
            }
        }
    );
  });
};

//     const contractInstance = contract.new({
//     data: '0x' + bytecode,
//     from: web3.eth.coinbase,
//     gas: 90000*2
// }, (err, res) => {
//     if (err) {
//         console.log(err);
//         return;
//     }

//     // Log the tx, you can explore status with eth.getTransaction()
//     console.log(res.transactionHash);

//     // If we have an address property, the contract was deployed
//     if (res.address) {
//         console.log('Contract address: ' + res.address);
//         // Let's test the deployed contract
//         testContract(res.address);
//     }
// });
//   });
// };