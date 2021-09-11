pragma solidity >=0.4.16 <0.7.0;
 
    // Smart contracts by QuillPlay



    /* https://github.com/LykkeCity/EthereumApiDotNetCore/blob/master/src/ContractBuilder/contracts/token/SafeMath.sol */
   contract SafeMath {
       uint256 constant private MAX_UINT256 =
       0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
   
       function safeAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
           if (x > MAX_UINT256 - y) revert();
           return x + y;
       }
   
       function safeSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
           if (x < y) revert();
           return x - y;
       }
   
       function safeMul(uint256 x, uint256 y) internal pure returns (uint256 z) {
           if (y == 0) return 0;
           if (x > MAX_UINT256 / y) revert();
           return x * y;
       }
   }
   
    contract ContractReceiver {
       function tokenFallback(address _from, uint _value, bytes _data) public;
   }
    
   contract MimirToken is SafeMath {
       
     event Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
   
     mapping(address => uint) balances;
     
       string public symbol = "MIMR";
       string public name = "Mimir";
       uint256 public decimals = 18;
       address public owner= address(0x2Fd2dc35E398c9a97fF533fe36a077B8BDd1C477);
       uint256 public totalSupply = 100000000*10**18 ;  
       
     constructor() public
     {
       balances[owner] = totalSupply;
     }
     
     
     // Function to access name of token .
     function name() public constant returns (string) {
         return name;
     }
     // Function to access symbol of token .
     function symbol()  public constant returns (string) {
         return symbol;
     }
     // Function to access decimals of token .
     function decimals() public constant returns (uint256) {
         return decimals;
     }
     // Function to access total supply of tokens .
     function totalSupply() public constant returns (uint256) {
         return totalSupply;
     }
     
     
     // Function that is called when a user or another contract wants to transfer funds .
     function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
         
       if(isContract(_to)) {
           if (balanceOf(msg.sender) < _value) revert();
           balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
           balances[_to] = safeAdd(balanceOf(_to), _value);
           assert(_to.call.value(0)(bytes4(keccak256(abi.encodePacked(_custom_fallback))), msg.sender, _value, _data));
           emit Transfer(msg.sender, _to, _value, _data);
           return true;
       }
       else {
           return transferToAddress(_to, _value, _data);
       }
   }
     
   
     // Function that is called when a user or another contract wants to transfer funds .
     function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
         
       if(isContract(_to)) {
           return transferToContract(_to, _value, _data);
       }
       else {
           return transferToAddress(_to, _value, _data);
       }
   }
     
     // Standard function transfer similar to ERC20 transfer with no _data .
     // Added due to backwards compatibility reasons .
     function transfer(address _to, uint _value) public returns (bool success) {
         
       //standard function transfer similar to ERC20 transfer with no _data
       //added due to backwards compatibility reasons
       bytes memory empty;
       if(isContract(_to)) {
           return transferToContract(_to, _value, empty);
       }
       else {
           return transferToAddress(_to, _value, empty);
       }
   }
   
   //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
     function isContract(address _addr) private view returns (bool is_contract) {
         uint length;
         assembly {
               //retrieve the size of the code on target address, this needs assembly
               length := extcodesize(_addr)
         }
         return (length>0);
       }
   
     //function that is called when transaction target is an address
     function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
       if (balanceOf(msg.sender) < _value) revert();
       balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
       balances[_to] = safeAdd(balanceOf(_to), _value);
       emit Transfer(msg.sender, _to, _value, _data);
       return true;
     }
     
     //function that is called when transaction target is a contract
     function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
       if (balanceOf(msg.sender) < _value) revert();
       balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
       balances[_to] = safeAdd(balanceOf(_to), _value);
       ContractReceiver receiver = ContractReceiver(_to);
       receiver.tokenFallback(msg.sender, _value, _data);
       emit Transfer(msg.sender, _to, _value, _data);
       return true;
   }
   
   
     function balanceOf(address _owner) public view returns (uint balance) {
       return balances[_owner];
     }
   }
    
    
    
    
    
