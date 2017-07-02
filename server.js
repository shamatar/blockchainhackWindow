const express        = require('express');
const bodyParser     = require('body-parser');
const app            = express();
const expressValidator     = require('express-validator');
var Web3 = require('web3');
var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider('http://localhost:8090'));
var coinbase = web3.eth.coinbase;
console.log(coinbase);
var password = "testing";
try {
    web3.personal.unlockAccount(web3.eth.coinbase, password);
} catch(e) {
    console.log(e);
    return;
}

const fs = require('fs');
const input = fs.readFileSync('Contract.sol');
const solc = require('solc');
const output = solc.compile(input.toString(), 1);
console.log(output.contracts);
const bankBytecode = output.contracts[':IssuingBank'].bytecode;
const bankABI = JSON.parse(output.contracts[':IssuingBank'].interface);

const depositBytecode = output.contracts[':DepositContract'].bytecode;
const depositABI = JSON.parse(output.contracts[':DepositContract'].interface);




const port = 8000;

app.use(bodyParser.json());


app.use(function (req, res, next) {
  console.log(req.body)
  console.log(req.headers)
  next()
});
require('./app/routes')(app,{bankBytecode, depositBytecode}, {bankABI,depositABI}, web3);



app.listen(port, () => {
  console.log('We are live on ' + port);
  app._router.stack.forEach(function(r){
  if (r.route && r.route.path){
      console.log(r.route.path)
      }
    })
  });             
// })
