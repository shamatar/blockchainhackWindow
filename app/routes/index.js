const routes = require('./api_routes');
module.exports = function(app, bytecode, abi, web3) {
  routes(app, bytecode, abi, web3);
};