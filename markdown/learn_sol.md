### sol笔记
#### 类型（Types）
##### 值类型
01. 布尔类型
02. 整型
03. 定长浮点型
04. 地址类型
    - 地址类型存储一个**20字节**的值
    - 地址类型成员变量：`balance`和`transfer`; `send`; `call`， F 和 `delegatecall`
    - call函数：可以接受任意类型任意数量参数。这些参数会被打包到**以32字节为单位**的连续区域中存放。 其中一个例外是当**第一个参数被编码成正好 4 个字节**的情况。
        > address nameReg = 0x72ba7d8e73fe8eb666ea66babc8116a41bfb10e2;
        > nameReg.call(bytes4(keccak256("fun(uint256)")), a);
    - `delegatecall` 的目的是使用存储在另外一个合约中的库代码
    - 不鼓励使用 `callcode`，在未来也会将其移除。
05. 定长字节数组
    - 关键字有：`bytes1`， `bytes2`， `bytes3`， ...， `bytes32`。`byte` 是 `bytes1` 的别名
06. 变长字节数组
    - `bytes`, `string` ————不是值类型
07. 地址字面常数
    - 通过了地址校验和测试的十六进制字面常数属于 address 类型
    - **长度在 39 到 41 个数字的**，没有通过校验和测试而产生了一个警告的十六进制字面常数视为正常的有理数字面常数
    - 混合大小写的地址校验和格式定义在**EIP-55**中
08. 有理数和整数字面常数
    - 数值字面常数表达式本身支持任意精度。这意味着在数值常量表达式中, 计算不会溢出而除法也不会截断。
    - 整数字面常数和有理数字面常数都属于数值字面常数类型。
    - 所有的数值字面常数表达式（即只包含数值字面常数和运算符的表达式）都属于数值字面常数类型。
    - 数值字面常数表达式只要在非字面常数表达式中使用就会转换成非字面常数类型。如下，编译不通过：
        > uint128 a = 1;
        > uint128 b = 2.5 + a + 0.5;
09. 字符串字面常数
10. 十六进制字面常数
11. 枚举类型
12. 函数类型
    - 函数类型是一种表示函数的类型。可以将一个函数赋值给另一个函数类型的变量，也可以将一个函数作为参数进行传递，还能在函数调用中返回函数类型变量。函数类型有两类：- 内部（`internal`） 函数和 外部（`external`） 函数：
    - 内部函数只能在当前代码块内调用，包括内部库函数和继承得函数中；内部函数的调用时通过跳转到它的入口标签来实现；
    - 外部函数由一个地址和一个函数签名组成，可以通过外部函数调用传递或者返回；
    - **函数类型**默认是内部函数，因此不需要声明 `internal` 关键字。 与此相反的是，合约中的**函数本身**默认是 `public` 的，只有当它被当做类型名称时，默认才是内部函数；
    - 如果外部函数类型在 Solidity 的上下文环境以外的地方使用，它们会被视为 `function` 类型。 该类型**将函数地址紧跟其函数标识一起编码为一个 bytes24 类型**；
    - `public`（或 `external`）函数也有一个特殊的成员变量称作 `selector`，可以返回 ABI 函数选择器；

##### 引用类型
###### 数据位置
- 所有的复杂类型，即 ***数组*** 和 ***结构*** 类型，都有一个额外属性，“数据位置”，说明数据是保存在 内存memory（并不是永久存储） 中还是 存储storage（保存状态变量的地方） 中。
- 函数参数（包括返回的参数）的数据位置默认是 memory， 局部变量的数据位置默认是 storage，状态变量的数据位置强制是 storage （这是显而易见的）。
- 也存在第三种数据位置， calldata ，这是一块只读的，且不会永久存储的位置，用来存储函数参数。 外部函数的参数（非返回参数）的数据位置被强制指定为 calldata ，效果跟 memory 差不多。
- 数据位置的指定非常重要，因为它们影响着赋值行为： 在 存储storage 和 内存memory 之间两两赋值，或者 存储storage 向状态变量（甚至是从其它状态变量）赋值都会创建一份独立的拷贝。 然而状态变量向局部变量赋值时仅仅传递一个引用，而且这个引用总是指向状态变量，因此后者改变的同时前者也会发生改变。 另一方面，从一个 内存memory 存储的引用类型向另一个 内存memory 存储的引用类型赋值并不会创建拷贝。
01. 数组
    - 一个元素类型为 T，固定长度为 k 的数组可以声明为 T[k]，而动态数组声明为 T[]；
    - T也可以是一个数组，举个例子，一个长度为 5，元素类型为 uint 的动态数组的数组，应声明为 uint[][5]，要访问第三个动态数组的第二个元素，你应该使用 x[2][1];
    - bytes 和 string 类型的变量是特殊的数组。 bytes 类似于 byte[]，但它在 calldata 中会被“紧打包”。string 与 bytes 相同，但（暂时）不允许用长度或索引来访问。
    - sol没有字符串操作函数，但有第三方字符串库
    - 字符串比较：keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2))
    - 字符串连接：string.concat(s1, s2)
    - bytes还是byte1[]？
    - bytes(s), low-level bytes of the utf-8
    - bytes.concat函数和string.concat函数：紧打包的方式连接任意数量的字节值或字符值，返回单一的bytes和string内存数组
    - 分配内存数组
        - 使用new操作符创建
        - 数组大小不可改变
        - 如有必要，只能创建一个新的内存数组，并一个个拷贝元素
    - 数组字面常数
        - 静态大小的内存数组，长度即列表元素（表达式）数量
        - 数组的类型与列表中第一个元素（表达式）一致，其他元素要能隐式转换，否则报错
        - [1, 2, 3] is uint8[3] memory, [1, -1] is invalid
    - 固定大小的内存数组不能赋值给动态大小的内存数组
    - 动态大小数组的赋值需逐一赋值
    - 成员变量
        - length
        - push(): 动态存储数组和bytes（非string）有该成员函数，附加零初始化的元素到数组末尾，并返回元素引用
            - x.push().t = 2 or x.push() = b
        - push(x): 动态存储数组和bytes（非string）有该成员函数，附加给定元素到数组末尾，无返回
        - pop(): 动态存储数组和bytes（非string）有该成员函数，从数组末尾移除元素，隐式调用delete 被移除元素，无返回
        - push()有常量的油气消耗, pop()的油气消耗依赖于移除元素的大小
    - 悬浮引用
        - 使用存储数组时，要小心**避免悬浮引用**
        - 场景1：存储一个数组元素的引用到本地变量，尔后调用.pop()从数组中移除了该元素
        - 场景2：在元组赋值中使用了复杂的表达式
        - bytes数组元素的引用？--***为什么？***
    - 数组切片
        - x[start:end]
        - array slices only exist in intermediate expressions.
        - as of now, array slices are only implemented for calldata arrays.
02. 结构体
    - 结构体可以用在映射和数组，也可以包含映射和数组
    - 不可以在结构体中包含自身类型的成员
    - 在函数中使用结构体，结构体是赋值给storage数据位置的本地变量（非拷贝，仅存储引用），所以对局部变量的成员访问实际上会被写入状态；当然也可以直接访问结构体的成员来赋值
03. 映射
    - mapping(KeyType KeyName? => ValueType ValueName?)
    - keyType: 可以是任何内建值类型、bytes、string或任何合约、枚举类型；用户自定义类型或复杂类型，如映射、结构体、数组不允许；valueType：可以是任何类型; 名字是可选的
    - 它们在实际的初始化过程中创建每个可能的key，并将其映射到字节形式全是零的值：一个类型的默认值。然而下面是映射与哈希表不同的地方：在映射中，实际上并不存储key，而是存储它的keccak256哈希值，从而便于查询实际的值
    - 正因如此，映射没有长度，key的集合或value的集合的概念
    - 只有状态变量（或者在内部函数中的对于存储变量的引用，或作为库函数的参数）可以使用映射类型。不能用作公共可见的函数的参数或者返回值。对于包含映射的结构体和数组同样遵循此原则
    - public state variable -> getter -> KeyType KeyName -> ValueType ValueName -> array or mapping -> the getter has one parameter for each KeyType, recursively
##### 操作符
- 类型决断
- 三元运算符
- 复合运算 和 自增、自减
- delete: 有点类似，赋值？ 

### sol笔记（en）
#### 值类型及可用操作符
01. bool
    - 布尔型
    - value-range: true、false
    - operators：!, &&, ||, ==, !=
02. int/uint(int256/uint256), int8~int256, uint8~uint256
    - 整型
    - value-range: type(X).min ~ type(X).max
    - eg: uint32's value range is 0 up to 2**32-1
    - operators: 
        - comparisons: <, <=, ==, !=, >, >=
        - bit: &, |, ^, ~
        - shift: <<, >>
        - arithmetic: +, -, *, /, %, **, unary -
        - two modes: wrapping or unchecked, checked
        - 移位：结果取决于运算符左边的类型；按负数位移动会引发运行时异常；0.5.0之前向0截断，0.5.0之后向负无穷截断。
        - 加、减、乘：会存在上溢下溢，checked模式会引发异常。
        - 除法：除法总是会截断，但操作数都是字面常数则不会截断；除法向0截断；除0运算会引发异常；除法唯一溢出的场景是type(int).min/-1。
        - 模：结果取决于运算符左边的类型；模0运算会引发异常；
        - 指数：结果取决于基数类型；仅适用于指数中的无符号类型；x\*\*3=>x\*x\*x；0\*\*0等于1。
03. fixed/ufixed(fixed128x18/ufixed128x18)(fixedMxN/ufixedMxN, M: 8~256, N: 0-80)
    - 定长浮点型
    - sol还没有完全支持定长浮点型。可以声明定长浮点型的变量，但不能给它们赋值或把它们赋值给其他变量
    - value-range: 
    - operators:
        - comparisons: <, <=, ==, !=, >, >=
        - arithmetic: +, -, *, /, %, unary -
    - 浮点型float, double--无。
04. address/address payable
    - 20 byte value
    - conversions: 
        - implicit conversions from address payable to address are allowed
        - explicit conversions to and from address are allowed for: uint160, integer literals, bytes20 and contract type
        - address payable: only expressions of type address and contract-type can
        - bytes32, address(uint160(bytes20(b))), address(uint160(uint256(b)))
    - 地址类型成员变量
        - balance和transfer
            > address payable x = payable(0x123);
            > address myAddress = address(this);
            > if (x.balance < 10 && myAddress.balance >= 10) x.transfer(10);
            - 如果x是合约函数，它的接收函数或fallback函数（如果有的话）会跟随transfer调用一起执行
        - send
        - call, delegatecall and staticcall
            > bytes memory payload = abi.encodeWithSignature("register(string)", "MyName");
            > (bool success, bytes memory returnData) = address(nameReg).call(payload);
            > require(success);
            - All these functions are low-level functions and should be used with care
            - The regular way to interact with other contracts is to call a function on a contract object (x.f()).
            - gas modifier, value modifier
            > address(nameReg).call{gas: 1000000, value: 1 ether}(abi.encodeWithSignature("register(string)", "MyName"));
        - code and codehash
            - .code -> bytes memory
            - .codehash -> Keccak-256 hash of that code:bytes32
            - note: addr.codehash is cheaper than using keccak256(addr.code)
05. Contract Types
    - Every contract defines its own type: MyContract c
    - conversion:
        - can implicitly convert contracts to contracts they inherit from
        - explicit conversion to and from the address payable: has a receive or payable fallback function
        - explicit conversion to and from the address: does not have a receive or payable fallback function
        - address payable conversion: payable(address(x))
    - The members of contract types are the external functions of the contract including any state variables marked as public
06. bytes1, bytes2, bytes3, …, bytes32
    - operators:
        - comparisons: <, <=, ==, !=, >, >=
        - bit: &, |, ^, ~
        - shift: <<, >>
        - index access: If x is of type bytesI, then ***x[k] for 0 <= k < I*** returns the k th byte
    - members:
        - .length
        - Prior to version 0.8.0, byte used to be an alias for bytes1
07. bytes/string
08. Literals
    - Address Literals
        - Hexadecimal literals that pass the address checksum test(EIP-55)
        - 39 and 41 digits long and **do not pass the checksum test produce an error**
    - Rational and Integer Literals
        - 整型字面常数: 0-9组成的数字序列
        - 分数字面常数：小数点.且之后至少一位数字（如.1, 1.3）
        - 科学计数的字面常数：MeE => M * 10**E，尾数可以是小数，指数必须是整数
        - 下划线的使用，增加字面常数可读性
        - 数值字面常数表达式可以保留任意精度直到被转换成非字面类型，即不会发生溢出或者截断
        - 大部分操作符应用到字面常数结果也是字面常数，有两类不符合这种情形：
            - 三元运算符：... ? ... : ...
            - 数组裁剪： <array>[<index>]
    - String Literals and Types
        - 单引号或双引号引起来的字符串
        - 可隐式转换：bytes1~bytes32, bytes, string
        - 支持转义字符如：\n, \xNN, \uNNNN
    - Unicode Literals
        > string memory a = unicode"Hello 😃";
    - Hexadecimal Literals
        - hex"001122FF", hex'0011_22_FF'
09. Enums
    - They are explicitly convertible to and from all integer types but implicit conversion is not allowed
    - type(NameOfEnum).min and type(NameOfEnum).max
10. User-defined Value Types
    - type C is V

#### 单位和全局变量

### 应用二进制接口
01. 函数选择器
    - 一个函数调用数据的前4字节，指定了要调用的函数。这就是某个函数签名的Keccak(SHA-3)哈希的前4个字节（高位在左的大端序）
02. 参数编码
    - 第5个字节开始时被编码的参数
03. 类型
    - uint<M>, int<M>, address, uint256(uint), int256(int), uint8(bool), finxed<M>x<N>, ufixed<M>x<N>, fixed128x18(fixed), ufixed128x18(ufixed), bytes<M>, function(bytes24), <type>[M], bytes, string, <type>[], (T1,T2,...,Tn)
    - ABI元组时用sol的structs编码得到
04. 编码的形式化说明
    - 读取次数取决于参数数组结构中的最大深度
    - 一个变量或数组元素的数据，不会被插入其他的数据，并且是可以再定位的（相对“地址”）
    - 静态类型会被直接编码；动态类型会在当前数据块之后单独分配的位置被编码
    - 动态：bytes, string, 任意类型T的变成数组T[\], 任意动态类型T的定长数组T[k], 由动态的Ti构成的元组
    - len(enc(X)), enc定义为一个由ABI类型到二进制字符串的值的映射，X是动态的，len(enc(X))才会依赖于X
    - 对任意X，len(enc(X))都是32的倍数
05. 函数选择器何参数编码
    - function_selector(f) enc((a_1, ..., a_n)), enc((v_1, ..., v_k))
    - 字节数偏移量是他们的数据区域的起始位置

NatSpec
Yul