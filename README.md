# README #

This repo contains example of the proxifing smart-contract (SM) for the bank, that servers as a bank entity in an Ethereum blockchain, as well as examples of proposed deposit/swap contracts.

### Smart-contracts ###

SM IssuingBank - bank entity in a blockchain. Minimal set of data - bank name, link to set of main documents and cryptographic hash of this documents.

SM DepositContract - deposit/swap contract example. Bank makes a public offering for securitization of 100 deposits of 1000 USD equivalent, price for each - 1 ETH, offer (rate) validity - 3 days from 03/07/2017. Any member of Ethereum blockchain can buy one by using corresponding method. At the end of the term bank pays equivalent of final amount (base value + interest over term) in ETH back to buyer. Over a time of contract validity owner of corresponding IssuingBank account can withdraw funds, accumulated on this contract, with only reponsibility - to pay back equivalents at the end of the term. This allow banks to have working funds in ETH, and allows owners of the ETH to hedge there risks and even have a small interest. 

### Architecture ###

Smart-contracts are written in Solidity, with a REST API build on top of it using WEB3 + NodeJS + Express v4. So, set a test chain, start GETH, set a gateway address in "server.js" and try to open first bank.

### Team members ###

Team members have experience in system programming (C/C++/Linux kernel), modern backend languages (Python/JS) and smart-contracts (Solidity), as well as in financial services (10 years in the largest Russian bank) and financial law.

### Terms ###

In case of use any parts of the code from this repository, including separate functions, link to this repository is mandatory, as well as reference to Vlasov Alexander
