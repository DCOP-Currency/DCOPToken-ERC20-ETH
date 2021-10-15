// contracts/DCOPToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0 >= 0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title DCOP Token equivalent to the currency COP
/// @author FelipheGomez
contract DCOPToken is ERC20, AccessControl, Ownable {
    // metadata
    string public version = "1.0";
    
    // crowdsales
    bool public mintActived;
    bool public buyActived;
    bool public sellActived;
    uint256 public sellPrice = 10187675;
    uint256 public buyPrice  = 12128225;
    
    // roles
    bytes32 public constant MINTER_ROLE   = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE   = keccak256("BURNER_ROLE");
    bytes32 public constant EXCHAN_ROLE  = keccak256("EXCHAN_ROLE");
    
    constructor(uint256 initialSupply) ERC20("DCOP", "DCOP") {
        mintActived = true;
        sellActived = true;
        buyActived = true;
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);
        _setupRole(EXCHAN_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _mint(address(this), initialSupply);
        _mint(msg.sender, 10000000000000000000000000); // payment of remuneration for the creator
    }
    
    function decimals() public view virtual override returns (uint8) {
      return 18;
    }
    
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }
    
    function buyOn() public onlyRole(EXCHAN_ROLE) {
        buyActived = false;
    }
    
    function buyOff() public onlyRole(EXCHAN_ROLE) {
        buyActived = true;
    }
    
    function sellOn() public onlyRole(EXCHAN_ROLE) {
        sellActived = false;
    }
    
    function sellOff() public onlyRole(EXCHAN_ROLE) {
        sellActived = true;
    }
    
    function mintOn() public onlyRole(MINTER_ROLE) {
        mintActived = true;
    }
    
    function mintOff() public onlyRole(MINTER_ROLE) {
        mintActived = false;
    }
    
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyRole(EXCHAN_ROLE) {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
    
    function buy() payable public {
        require(buyActived);
        uint amount = msg.value / buyPrice;               // calculates the amount
        if ((balanceOf(address(this)) / buyPrice) >= amount) {
            _transfer(address(this), msg.sender, amount);              // makes the transfers
        } else {
            require(mintActived);
            _mint(msg.sender, msg.value / buyPrice);
        }
    }
    
    function buyTo(address to) payable public {
        require(buyActived);
        uint amount = msg.value / buyPrice;               // calculates the amount
        if ((balanceOf(address(this)) / buyPrice) >= amount) {
            _transfer(address(this), to, amount);              // makes the transfers
        } else {
            require(mintActived);
            _mint(to, msg.value / buyPrice);
        }
    }
    
    function sell(uint256 amount) public {
        require(sellActived);
        address account = payable(address(this));
        require(account.balance >= amount * sellPrice);      // checks if the contract has enough ether to buy
        _transfer(msg.sender, account, amount);              // makes the transfers
        payable(msg.sender).transfer(amount * sellPrice);          // sends ether to the seller. It's important to do this last to avoid recursion attacks
    }
}
