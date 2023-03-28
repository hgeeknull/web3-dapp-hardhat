import { ethers } from "ethers";

// 00 init
const account1 = "vitalik.eth"

// 01 hello
const providerMain = new ethers.providers.JsonRpcProvider("https://rpc.builder0x69.io", 1);

// 02 provider - infura-fail
// const INFURA_ID = ""
// const providerMain = new ethers.providers.JsonRpcProvider(`https://mainnet.infura.io/v3/${INFURA_ID}`)
// const providerTest = new ethers.providers.JsonRpcProvider(`https://mainnet.infura.io/v3/${INFURA_ID}`)

// 03 contract
// 声明只读合约的规则：
// 参数分别为合约地址`address`，合约ABI `abi`，Provider变量`provider`
// const contract = new ethers.Contract(`address`, `abi`, `provider`);

// 第1种输入abi的方式: 复制abi全文
// WETH的abi可以在这里复制：https://etherscan.io/token/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code
const abiWETH = '[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"guy","type":"address"},{"name":"wad","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"src","type":"address"},{"name":"dst","type":"address"},{"name":"wad","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"wad","type":"uint256"}],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"dst","type":"address"},{"name":"wad","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"deposit","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"payable":true,"stateMutability":"payable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"src","type":"address"},{"indexed":true,"name":"guy","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"src","type":"address"},{"indexed":true,"name":"dst","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"dst","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Deposit","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"src","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Withdrawal","type":"event"}]';
const addressWETH = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2' // WETH Contract
const contractWE = new ethers.Contract(addressWETH, abiWETH, providerMain)

// 第2种输入abi的方式：输入程序需要用到的函数，逗号分隔，ethers会自动帮你转换成相应的abi
// 人类可读abi，以ERC20合约为例
const abiERC20 = [
    "function name() view returns (string)",
    "function symbol() view returns (string)",
    "function totalSupply() view returns (uint256)",
    "function balanceOf(address) view returns (uint)",
];
const addressDAI = '0x6B175474E89094C44Da98b954EedeAC495271d0F' // DAI Contract
const contractDI = new ethers.Contract(addressDAI, abiERC20, providerMain)

const main = async () => {
    // 02 provider
    // const balance = await providerMain.getBalance(`${account1}`);
    // console.log(`balance: ${ethers.utils.formatEther(balance)}`);

    // const network = await providerMain.getNetwork();
    // console.log(`network: ${network}`);

    // const blockNumber = await providerMain.getBlockNumber();
    // console.log(`blockNumber: ${blockNumber}`);

    // const gasPrice = await providerMain.getGasPrice();
    // console.log(`gasPrice: ${gasPrice}`);

    // const feeData = await providerMain.getFeeData();
    // console.log(`feeData: ${feeData}`);

    // const block = await providerMain.getBlock(0);
    // console.log(`block: ${JSON.stringify(block)}`);

    // const code = await providerMain.getCode("0xc778417e063141139fce010982780140aa0cd5ab");
    // console.log(`code: ${code}`)

    // 03 contract
    const nameWE = await contractWE.name();
    const symbolWE = await contractWE.symbol();
    const totalSupplyWE = await contractWE.totalSupply();
    const balanceWE = await contractWE.balanceOf(`${account1}`);
    console.log(`name: ${nameWE}, symbol: ${symbolWE}, totalSupply: ${totalSupplyWE}, balance: ${balanceWE}`);

    const nameDI = await contractDI.name();
    const symbolDI = await contractDI.symbol();
    const totalSupplyDI = await contractDI.totalSupply();
    const balanceDI = await contractDI.balanceOf(`${account1}`);
    console.log(`name: ${nameDI}, symbol: ${symbolDI}, totalSupply: ${totalSupplyDI}, balance: ${balanceDI}`);
}

main();