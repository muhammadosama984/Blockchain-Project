//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract ERC20 {
    // Variables declared in ERC-20
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;

    // mapping is used to check the balances of the address that send ethereum
    // another mapping is used to check which address has been given permission of approving
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events - fire events on state changes etc
    event Transfer(address from, address to, uint256 value);
    event Approval(address owner, address spender, uint256 value);

    // intialise the variables and put all the tokens in the account of owner (msg.sender).
    constructor() {
        name = "ZapCoin";
        symbol = "ZC";
        decimals = 18;
        totalSupply = 100000;
        balanceOf[msg.sender] = totalSupply;
    }

    // this function transfer the token to a given address
    function transfer(address _to, uint256 _value)
        external
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] = balanceOf[msg.sender] - (_value);
        balanceOf[_to] = balanceOf[_to] + (_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // in this function owner of contract approve the spender to sent value
    function approve(address _spender, uint256 _value) external returns (bool) {
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // in this _from address will must be approve by the msg.sender from approve function
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] = allowance[_from][msg.sender] - (_value);
        balanceOf[_from] = balanceOf[_from] - (_value);
        balanceOf[_to] = balanceOf[_to] + (_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
}

contract ICO is ERC20 {
    address payable public admin;
    uint256 public saleStart = block.timestamp;
    uint256 public saleEnd = block.timestamp + 604800;
    uint256 public raisedAmount;
    uint256 public maxInvestment = 5 ether;
    uint256 public minInvestment = 0.0001 ether;
    uint256 public Price = 1 ether;
    address payable public deposit;

    mapping(address => uint256) public balances;

    constructor() {
        admin = payable(msg.sender);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    function buyTokens(uint256 _value) public payable {
        require(block.timestamp >= saleStart && block.timestamp <= saleEnd);
        uint256 tokens = _value;
        uint256 saleAmount = _value * 1;
        totalSupply = totalSupply = saleAmount;
        balances[msg.sender] = balances[msg.sender] + tokens;
    }

    // owner can get withdraw of its amount
    function withdraw() public payable onlyAdmin {
        deposit.transfer(myBalance());
    }

    // to check how much money has been raised
    function myBalance() public view onlyAdmin returns (uint256) {
        return (balances[msg.sender]);
    }

    // this function is used to end the ICO
    function endSale() public {
        admin.transfer(address(this).balance);
    }
}
