const glob = require("glob");
const path = require( 'path' );
var routes = [];
glob.sync("app/routes/*/**/*.js", {}).forEach(( file ) => {
        console.log(file)
        const f = require(file);  
        routes.push(f);
});

module.exports = function(app, bytecode, abi, web3) {

    // helloRoute(app,db);
    routes.forEach((route) => {
        route(app, bytecode, abi, web3);
    });

};