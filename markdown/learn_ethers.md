### 事件
1. 检索获取事件
contract.queryFilter('事件名', 起始区块, 结束区块)
要检索的事件必须包含在合约的abi中

```
{
  blockNumber: 8741481,
  blockHash: '0xb5842eb1883cca1e43729d3a7a694fbda910cf11ca0b6e5d9c124531c289247e',
  transactionIndex: 24,
  removed: false,
  address: '0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6',
  data: '0x00000000000000000000000000000000000000000000000000038d7ea4c68000',
  topics: [
    '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
    '0x000000000000000000000000f5de760f2e916647fd766b4ad9e85ff943ce3a2b',
    '0x00000000000000000000000021e08c04f29febce461be04789c1ee44d0e15da8'
  ],
  transactionHash: '0x1a49069e790ad8c88639cb0536ef858e176f977d3b501a33dae7563ce6a368c2',
  logIndex: 4,
  removeListener: [Function (anonymous)],
  getBlock: [Function (anonymous)],
  getTransaction: [Function (anonymous)],
  getTransactionReceipt: [Function (anonymous)],
  event: 'Transfer',
  eventSignature: 'Transfer(address,address,uint256)',
  decode: [Function (anonymous)],
  args: [
    '0xf5de760f2e916647fd766B4AD9E85ff943cE3A2b',
    '0x21E08c04f29FEbcE461BE04789c1eE44d0E15da8',
    BigNumber { _hex: '0x038d7ea4c68000', _isBigNumber: true },
    from: '0xf5de760f2e916647fd766B4AD9E85ff943cE3A2b',
    to: '0x21E08c04f29FEbcE461BE04789c1eE44d0E15da8',
    amount: BigNumber { _hex: '0x038d7ea4c68000', _isBigNumber: true }
  ]
}
```
2. 解析事件数据
智能合约释放出的事件存储于EVM的日志中。日志分为两个主题`topics`和数据`data`部分，其中事件哈希和`indexed`变量存储在`topics`中，作为索引方便以后搜索；没有`indexed`变量存储在`data`中，不能被直接检索，但可以存储更复杂的数据结构。

transferEvents[0].args
```
BigNumber { _hex: '0x09184e72a000', _isBigNumber: true }
0.00001
0xB92b733a115AE64A886A419F22123E19f303e684
0x2ed6c4B5dA6378c7897AC67Ba9e43102Feb694EE
```
### 监听
1. 基本概念
在`ethersjs`中，
合约对象有一个`contract.on`的监听方法，让我们持续监听合约的事件。
有一个`contract.once`的监听方法，让我们只监听一次合约释放事件。
他们有两个参数，一个是要监听的事件名称`"eventName"`，需要包含在合约`abi`中；另一个是我们在事件发生时调用的函数。

语法
```js
contract.on("eventName", function)
contract.once("eventName", function)
```

2. 执行结果
利用contract.once(), 监听一次Transfer事件
```

```

利用contract.on(), 持续监听Transfer事件
```
0xf5de760f2e916647fd766B4AD9E85ff943cE3A2b->0x8676F6bD83186D43232b0cD0210Cd86D2f2DFA47 1000000000.0
0xf5de760f2e916647fd766B4AD9E85ff943cE3A2b->0x8676F6bD83186D43232b0cD0210Cd86D2f2DFA47 1000000000.0
0xf5de760f2e916647fd766B4AD9E85ff943cE3A2b->0x2C452A89213dCe8A752ADd5FDd8Fe7d025D5D8F3 1000000000.0
0xf5de760f2e916647fd766B4AD9E85ff943cE3A2b->0x29d09EA548d103efb43942001CF34D1012528D20 1000000000.0
```

### 事件过滤
1. 基本概念
当合约创建日志（释放事件）时，它最多可以包含[4]条数据作为索引（`indexed`）。索引数据经过哈希处理并包含在[布隆过滤器](https://en.wikipedia.org/wiki/Bloom_filter)中，这是一种允许有效过滤的数据结构。因此，一个事件过滤器最多包含`4`个主题集，每个主题集是个条件，用于筛选目标事件。规则：

- 如果一个主题集为`null`，则该位置的日志主题不会被过滤，任何值都匹配。
- 如果主题集是单个值，则该位置的日志主题必须与该值匹配。
- 如果主题集是数组，则该位置的日志主题至少与数组中其中一个匹配。

2. 语法
`ethers.js`中的合约类提供了`contract.filters`来简化过滤器的创建：

```js
const filter = contract.filters.EVENT_NAME( ...args ) 
```

其中`EVENT_NAME`为要过滤的事件名，`..args`为主题集/条件。每个主题或条件参数可有`null`，单值或数组。
```js
contract.filters.Transfer(myAddress)
contract.filters.Transfer(null, myAddress)
contract.filters.Transfer(myAddress, otherAddress)
contract.filters.Transfer(null, [ myAddress, otherAddress ])
```

3. 执行结果
```
balance1: 453948002.925838
{
  address: '0xdac17f958d2ee523a2206206994597c13d831ec7',
  topics: [
    '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
    null,
    '0x00000000000000000000000028c6c06298d514db089934071355e5743bf21d60'
  ]
}
{
  address: '0xdac17f958d2ee523a2206206994597c13d831ec7',
  topics: [
    '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
    '0x00000000000000000000000028c6c06298d514db089934071355e5743bf21d60'
  ]
}

转出
0x28C6c06298d514Db089934071355E5743bf21d60->0x11F594ABA62Cb56e038bfe49AF4A5f115e2ef875 95.5
转出
0x28C6c06298d514Db089934071355E5743bf21d60->0xed012409c4a37d060c875C122853a2B01dEEc4FE 745.5
转出
0x28C6c06298d514Db089934071355E5743bf21d60->0x3D8A0B9a90a50c12591F15cF4350B3024dA04dB2 1774.5
转出
0x28C6c06298d514Db089934071355E5743bf21d60->0xf4cBB0B48d6AE901712077DE24d8C9c4a7f8Ad1C 1129.68
```

### BigNumber和单位转换
1. 基本概念
- BigNumber
E中许多对超出js最大安全整数的计算，js中最大安全整数为`9007199254740991`，Number.MAX_SAFE_INTEGER。
因此，`ethers.js`使用`BigNumber`类安全地对任何数量级的数字进行数学运算。在`ethers.js`中，大多数需要返回值的操作将返回`BigNumber`，而接受值的参数也会接受它们。
你可以利用`ethers.BigNumber.from()`函数将`string`，`number`，`BigNumber`等类型转换为`BigNumber`。超出js最大安全整数的数值不能被转换。
`BigNumber`支持很多运算，例如加减乘除、取模`mod`，幂运算`pow`，绝对值`abs`等运算。

```
BigNumber { _hex: '0x3b9aca00', _isBigNumber: true }
BigNumber { _hex: '0x3b9aca00', _isBigNumber: true }
BigNumber { _hex: '0x3b9aca00', _isBigNumber: true }
js中最大安全整数:  9007199254740991
overflow [ See: https://links.ethers.org/v5-errors-NUMERIC_FAULT-overflow ] (fault="overflow", operation="BigNumber.from", value=9007199254740991, code=NUMERIC_FAULT, version=bignumber/5.7.0)
加法 1000000001
减法 999999999
除法 2000000000
乘法 500000000
是否相等 true
```

2. 单位转换
`1 ether` = `10^18 wei`
`1 gwei` = `10^9 wei`
用户可读：机器可读，交易时需换成以`wei`为单位的数值

- `formatUnits(变量, 单位)`：格式化，小单位转大单位，比如`wei` -> `ether`，在显示余额时很有用。参数中，单位填位数（数字）或指定的单位（字符串）。

```
2. 格式化：小单位转大单位，formatUtils
  1000000000
  1.0
  1.0
  0.000000001
  1.0
  0.000000001
```

- `parseUnits`：解析，大单位转小单位，比如`ether` -> `wei`，在将用户输入的值转为`wei`为单位的数值很有用。参数中，单位填位数（数字）或指定的单位（字符串）。

```
3.解析：大单位转小单位，parseUnits
  1000000000000000000
  1000000000000000000
  BigNumber { _hex: '0x0de0b6b3a7640000', _isBigNumber: true }
  1000000000000000000
  1000000000
  1000000000
  1000000000000000000
```

### CallStatic
1. 基本概念
- 在发送交易之前检查交易是否会失败。`callStatic`方法是属于```ethers.Contract```类的编写方法分析，同类的还有`populateTransaction`和`estimateGas`方法。
- 在`ethers.js`中你可以利用`contract`对象的`callStatic()`来调用节点的`eth_call`。如果调用成功，则返回`ture`；如果失败，则报错并返回失败原因。

2. 语法
```js
    const tx = await contract.callStatic.函数名( 参数, {override})
    console.log(`交易会成功吗？：`, tx)
```

- 函数名：为模拟调用的函数名。
- 参数：调用函数的参数。
- {override}：选填，可包含一下参数：
    - `from`：执行时的`msg.sender`，也就是你可以模拟任何一个人的调用，比如V神。
    - `value`：执行时的`msg.value`。
    - `blockTag`：执行时的区块高度。
    - `gasPrice`
    - `gasLimit`
    - `nonce`

### ERC721Check
1. 基本概念
```solidity
   function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId 
    }
```

**只有支持`ERC165`标准的合约才能用这个方法识别**

```
contract address: 0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d
name: BoredApeYachtClub
symbol: BAYC
isERC721: true
```

### calldata编码
1. 基本概念
`ethers.js`的接口类抽象了与E网络上的合约交互所需的`ABI`编码和解码。我们可以利用`abi`生成或者直接从合约中获取`interface`变量。接口类封装了一些编码解码的方法。与一些特殊的合约交互时（比如代理合约），你需要编码参数、解码返回值。**相关函数必须包含在`abi`中**。

```js
// 利用abi生成
const interface = ethers.utils.Interface(abi)
// 直接从contract中获取
const interface2 = contract.interface
```

- `getSighash()`：获取函数选择器（function selector），参数为函数名或函数签名。
- `encodeDeploy()`：编码构造器的参数，然后可以附在合约字节码的后面。
- `encodeFunctionData()`：编码函数的`calldata`。
- `decodeFunctionResult()`：解码函数的返回值。

2. 操作结果
```
balanceOf编码结果：**********************
balance1: 0.054
deposit编码结果：**********************
交易详情： {
  type: 2,
  chainId: 5,
  nonce: 12,
  maxPriorityFeePerGas: BigNumber { _hex: '0x59682f00', _isBigNumber: true },
  maxFeePerGas: BigNumber { _hex: '0x6027dd43ca', _isBigNumber: true },
  gasPrice: null,
  gasLimit: BigNumber { _hex: '0x6d3e', _isBigNumber: true },
  to: '0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6',
  value: BigNumber { _hex: '0x2386f26fc10000', _isBigNumber: true },
  data: '0xd0e30db0',
  accessList: [],
  hash: '**********************',
  v: 1,
  r: '**********************',
  s: '**********************',
  from: '**********************',
  confirmations: 0,
  wait: [Function (anonymous)]
}
balance2: 0.064
```
### HDWallet
1. 基本概念
- HD钱包（Hierarchical Deterministic Wallet，多层确定性钱包）是一种数字钱包。通过它，用户可以从一个随机种子创建一系列密钥对，更加便利、安全、隐私。
- BIP32, BIP44, BIP39
`BIP32`提出可以用一个随机种子衍生多个私钥，更方便的管理多个钱包。钱包的地址由衍生路径决定，例如`“m/0/0/1”`。
`BIP44`为`BIP32`的衍生路径提供了一套通用规范，适配比特币、以太坊等多链。这一套规范包含六级，每级之间用"/"分割：
```
m / purpose' / coin_type' / account' / change / address_index
```
其中：
- m: 固定为"m"
- purpose：固定为"44"
- coin_type：代币类型，比特币主网为0，比特币测试网为1，以太坊主网为60
- account：账户索引，从0开始。
- change：是否为外部链，0为外部链，1为内部链，一般填0.
- address_index：地址索引，从0开始，想生成新地址就把这里改为1，2，3。

举个例子，以太坊的默认衍生路径为`"m/44'/60'/0'/0/0"`。

`BIP39`让用户能以一些人类可记忆的助记词的方式保管私钥，而不是一串16进制的数字：

2. HDNode类（批量生成钱包）
```js
// 生成随机助记词
const mnemonic = utils.entropyToMnemonic(utils.randomBytes(32))
// 创建HD钱包
const hdNode = utils.HDNode.fromMnemonic(mnemonic)
console.log(hdNode);

const numWallet = 20
// 派生路径：m / purpose' / coin_type' / account' / change / address_index
// 我们只需要切换最后一位address_index，就可以从hdNode派生出新钱包
let basePath = "m/44'/60'/0'/0";
let wallets = [];
for (let i = 0; i < numWallet; i++) {
    let hdNodeNew = hdNode.derivePath(basePath + "/" + i);
    let walletNew = new ethers.Wallet(hdNodeNew.privateKey);
    console.log(`第${i+1}个钱包地址： ${walletNew.address}`)
    wallets.push(walletNew);
}
```

3. 加密json
```
const pwd = "password";
const json = await wallet.encrypt(pwd)
const wallet2 = await ethers.Wallet.fromEncryptedJson(json, pwd);
```

4. 操作记录
```
助记词：**********************
派生20个：
第0个钱包地址为：0x505c25952A076Aafc843f934D137C7028a9Ca305
第1个钱包地址为：0x0D00D6CFe0593963cD109ccD9fFDC456099890D1
第2个钱包地址为：0x558FC2B9F6D4c0D3c75a843118FD8B280619e09d
第3个钱包地址为：0xcEeef7D9D2f778f505E0142b8Dc67fe57520d9AD
第4个钱包地址为：0x0b26792EE26482486B764b55779796f7D2b4875a
第5个钱包地址为：0xAcB65DDc1748C5B06e1977c1bdcBF17F10fe533e
第6个钱包地址为：0x75E33f753c96cAaB2bD5b03343384895C3a7ABdb
第7个钱包地址为：0x8dC50699C098fA3Ff44f4Eb3f619BA91281Ca057
第8个钱包地址为：0x76D7C8714D358F98720B10806710BA58641968af
第9个钱包地址为：0x69471c0edA2949A3E6dD87651C0CD4a04c269E18
第10个钱包地址为：0xfEc880242e790f8d724B4CE6deDD6FF9906B02b9
第11个钱包地址为：0x5489E53b3c9EEa36235D548e2aF5FE5b03Bd8973
第12个钱包地址为：0x4f1bDd0df1c757cf4776f57EB3244018315742CE
第13个钱包地址为：0x2A2bF7399C91f857F41F7Bf67174DBA031cf5E30
第14个钱包地址为：0x3D3e431b3C789CA9FB0D34eBe1E1BDf440990C41
第15个钱包地址为：0xd28340Df9CfDDF6e4e916043D0cE18f4A1B97c61
第16个钱包地址为：0x25de8Ff5e2603fE2a9be5bB90BBDb7C7A0F1bbd5
第17个钱包地址为：0x2eEE9E6c6993ba1D1dc9F3098a0C65820Af4A0b8
第18个钱包地址为：0xD2abe4f3B6D6E08C155bbfaA0A13598B6640CcFD
第19个钱包地址为：0x44B56dFD617F46b2d1a131bFEFE842fCa224a8E7
加密JSON：
walletToJson json: **********************
walletFromJson address: 0x505c25952A076Aafc843f934D137C7028a9Ca305
```
### 批量转账





