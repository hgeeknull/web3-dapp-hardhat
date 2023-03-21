//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.9.0;

// Represent a 18 decimal, 256 bit wide fixed point type using a use-defined value type
type UFixed256x18 is uint256;

library FixedMath {
    uint constant multiplier = 10**18;

    function add(UFixed256x18 a, UFixed256x18 b) internal pure returns (UFixed256x18) {
        return UFixed256x18.wrap(UFixed256x18.unwrap(a) + UFixed256x18.unwrap(b));
    }

    function mul(UFixed256x18 a, uint256 b) internal pure returns (UFixed256x18) {
        return UFixed256x18.wrap(UFixed256x18.unwrap(a) * b);
    }

    function floor(UFixed256x18 a) internal pure returns (uint256) {
        return UFixed256x18.unwrap(a) / multiplier;
    }

    function toUFixed256x18(uint256 a) internal pure returns (UFixed256x18) {
        return UFixed256x18.wrap(a * multiplier);
    }
}

library ArrayUtils {
    function map(uint[] memory self, function (uint) pure returns (uint) f) 
      internal
      pure
      returns (uint[] memory r)
    {
        r = new uint[](self.length);
        for(uint i=0; i<self.length; i++) {
            r[i] = f(self[i]);
        }
    }

    function reduce(
        uint[] memory self,
        function (uint, uint) pure returns (uint) f
    )
      internal
      pure
      returns (uint r)
    {
        r = self[0];
        for(uint i=1; i<self.length; i++) {
            r = f(r, self[i]);
        }
    }

    function range(uint length) internal pure returns (uint[] memory r) {
        r = new uint[](length);
        for(uint i=0; i<r.length; i++) {
            r[i] = i;
        }
    }
}

struct IndexValue { uint keyIndex; uint value; }
struct KeyFlag { uint key; bool deleted; }

struct itmap {
    mapping(uint => IndexValue) data;
    KeyFlag[] keys;
    uint size;
}

type Iterator is uint;

library IterableMapping {
    
}

contract Test {
    using ArrayUtils for *;

    // 数字字面常数
    uint128 a = 1;
    // 以下编译不能通过
    // uint128 b = 2.5 + a + 0.5;

    // 枚举类型
    enum ActionChoices { GoLeft, GoRight, GoStraight, SitStill }
    ActionChoices choice;
    ActionChoices constant defaultChoice = ActionChoices.GoStraight;

    // The data location of x is storage
    // This is the only place where the
    // data location can be ommitted
    uint[] x;

    function g(uint[] memory memoryArray) public {
        // assigments between storage and memory
        // always create an independent copy
        x = memoryArray;
        // assigments from storage to a local storage variable
        // assign a reference
        uint[] storage y = x;
        y[7];   // fine, returens the 8th element
        y.pop(); // fine, modifies x through y
        delete x; // fine, clears the array, also modifies y
        // 需要在 storage 中创建新的未命名的临时数组
        // 但 storage 是“静态”分配的
        // Type uint256[] memory is not implicitly convertible to expected type uint256[] storage pointer.
        // y = memoryArray;
        // Built-in unary operator delete cannot be applied to type uint256[] storage pointer.
        // delete y; // 不可行
    }

    function f() public pure returns (bytes4) {
        return this.f.selector;
    }

    function setGoStraight() public {
        choice = ActionChoices.GoStraight;
    }

    function getChoice() public view returns (ActionChoices) {
        return choice;
    }

    function getDefaultChoice() public pure returns (uint) {
        return uint(defaultChoice);
    }

    // 内部函数调用
    function pyramid(uint l) public pure returns (uint) {
        return ArrayUtils.range(l).map(square).reduce(sum);
    }
    function square(uint x) internal pure returns (uint) {
        return x * x;
    }
    function sum(uint x, uint y) internal pure returns (uint) {
        return x + y;
    }
}

contract C {
    string s = "Storage";

    function f(bytes calldata bc, string memory sm, bytes16 b) public view {
        string memory concatString = string.concat(s, string(bc), "Literal", sm);
        assert(bytes(s).length + bc.length + 7 + bytes(sm).length == bytes(concatString).length);

        bytes memory concatBytes = bytes.concat(bytes(s), bc, bc[:2], "Literal", bytes(sm), b);
        assert(bytes(s).length + bc.length + 2 + 7 + bytes(sm).length == concatBytes.length);
    }

    function g(uint len) public pure {
        // new operator
        // it is not possible to resize memory arrays
        uint[] memory a = new uint[](7);
        bytes memory b = new bytes(len);
        assert(a.length == 7);
        assert(b.length == len);
        // fine, update
        a[6] = 8;
    }
}

contract ArrayContract {
    uint[2**20] aLotOfIntegers;
    // Note that the following is not a pair of dynamic arrays but a
    // dynamic array of pairs (i.e. of fixed size arrays of length two).
    // In solidity, T[k] and T[] are always arrays with elements of type T,
    // even if T itself is an array.
    // Because of that, bool[2][] is a dynamic array of elements
    // that are bool[2]. This is different from other languages, like C.
    // Data location for all state variables is storage.
    bool[2][] pairsOfFlags;

    // newPairs is stored in memory - the only possibility
    // for public contract function arguments
    function setAllFlagPairs(bool[2][] memory newPairs) public {
        // assigment to s storage array performs a copy of ``newPairs`` and
        // replaces the complete array ``pairsOfFlags``
        pairsOfFlags = newPairs;
    }

    struct StructType {
        uint[] contents;
        uint moreInfo;
    }
    StructType s;

    function f(uint[] memory c) public {
        // stores a reference to ``s`` in ``g``
        StructType storage g = s;
        // also chages ``s.moreInfo``
        g.moreInfo = 2;
        // assigns a copy because ``g.contents``
        // is not a local variable, but a member of
        // a local variable.
        g.contents = c;
    }

    function setFlagPair(uint index, bool flagA, bool flagB) public {
        // access to a non-existing index will throw an exception
        pairsOfFlags[index][0] = flagA;
        pairsOfFlags[index][1] = flagB;
    }

    function changeFlagArraySize(uint newSize) public {
        // using push and pop is the only way to change the
        // length of an array
        if(newSize < pairsOfFlags.length) {
            while(pairsOfFlags.length > newSize) {
                pairsOfFlags.pop();
            }
        } else if (newSize > pairsOfFlags.length) {
            while(pairsOfFlags.length < newSize) {
                pairsOfFlags.push();
            }
        }
    }

    function clear() public {
        // these clear the arrays completely
        delete pairsOfFlags;
        delete aLotOfIntegers;

        // identical effect here
        pairsOfFlags = new bool[2][](0);
    }

    bytes byteData;
    function byteArrays(bytes memory data) public {
        // byte arrays ("bytes") are different as they are sotred without padding,
        // but can be treated identical to "uint8[]"
        byteData = data;
        for(uint i=0; i<7; i++)
            byteData.push();
        byteData[3] = 0x08;
        delete byteData[2];
    }

    function addFlag(bool[2] memory flag) public returns (uint) {
        pairsOfFlags.push(flag);
        return pairsOfFlags.length;
    }

    function createMemoryArray(uint size) public pure returns (bytes memory) {
        // Dynamic memory arrays are created using `new`
        uint[2][] memory arrayOfPairs = new uint[2][](size);

        // Inline arrays are always statically-sized and if you only
        // use literals, you have to provide at least one type
        arrayOfPairs[0] = [uint(1), 2];

        // Create a dynamic byte array:
        bytes memory b = new bytes(200);
        for(uint i=0; i<b.length; i++) {
            b[i] = bytes1(uint8(i));
        }

        return b;
    }
 }

 contract D {
    uint[][] s;

    function f() public {
        uint[] storage ptr = s[s.length - 1];
        s.pop();
        ptr.push(0x42);
        s.push();
        assert(s[s.length-1][0] == 0x42);
    }
 }

 contract Proxy {
    address client;

    constructor(address client_) {
        client = client_;
    }

    function forward(bytes calldata payload) external {
        bytes4 sig = bytes4(payload[:4]);

        if(sig == bytes4(keccak256("setOwner(address)"))) {
            address owner = abi.decode(payload[4:], (address));
            require(owner != address(0), "Address of owner cannot be zero.");
        }

        (bool status,) = client.delegatecall(payload);
        require(status, "Forwarded call failed.");
    }
 }

struct Funder {
    address addr;
    uint amount;
}

 contract CrowdFunding {
    struct Campaign {
        address payable beneficiary;
        uint fundingGoal;
        uint numFunders;
        uint amount;
        mapping(uint => Funder) funders;
    }

    uint numCampaigns;
    mapping(uint => Campaign) campaigns;

    function newCampaign(address payable beneficiary, uint goal) public returns (uint campaignID) {
        campaignID = numCampaigns++;
        Campaign storage c = campaigns[campaignID];
        c.beneficiary = beneficiary;
        c.fundingGoal = goal;
    }

    function contribute(uint campaignID) public payable {
        Campaign storage c = campaigns[campaignID];
        c.funders[c.numFunders++] = Funder({addr: msg.sender, amount: msg.value});
        c.amount += msg.value;
    }

    function checkGoalReached(uint campaignID) public returns (bool reached) {
        Campaign storage c = campaigns[campaignID];
        if(c.amount <c.fundingGoal)
            return false;
        uint amount = c.amount;
        c.amount = 0;
        c.beneficiary.transfer(amount);
        return true;
    }

 }

 contract MappingExample {
    mapping(address user => uint balance) public balances;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function update(uint newBalance) public {
        balances[msg.sender] = newBalance;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "ERC20: Allowance not high enough.");
        _allowances[sender][msg.sender] -= amount;
        _transfer(sender, recipient,amount);
        return true;
    }

    function approve(address spender, uint amount) public returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: Not enough funds.");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
 }

 contract MappingUser {
    function f() public returns (uint) {
        MappingExample m = new MappingExample();
        m.update(100);
        return m.balances(address(this));
    }
 }