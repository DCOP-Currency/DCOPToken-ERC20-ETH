// SPDX-License-Identifier: MIT
// contracts/DCOPToken.sol
// @title DCOP Token equivalent to the currency COP
// @author FelipheGomez
pragma solidity ^0.8.0 >= 0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// @title DCOP Token equivalent to the currency COP
// @author FelipheGomez
contract DCOPToken is ERC20, AccessControl, Ownable {
    // metadata
    string public version = "1.1";
    
    // crowdsales
    bool public mintActived;
    bool public buyActived;
    bool public sellActived;
    
    uint256 public sellPrice = 14358339;
    uint256 public buyPrice  = 14358340;
    
    // roles
    bytes32 public constant MINTER_ROLE   = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE   = keccak256("BURNER_ROLE");
    bytes32 public constant EXCHAN_ROLE  = keccak256("EXCHAN_ROLE");
    
    constructor() ERC20("Peso Colombiano Digital", "DCOP") {
        mintActived = true;
        sellActived = true;
        buyActived = true;
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);
        _setupRole(EXCHAN_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _mint(address(this), 1000000000000000000000000000000000);
        _transfer(address(this), msg.sender, 10000000000000000000000000);
    }
    
    function decimals() public view virtual override returns (uint8) {
      return 18;
    }
    
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(mintActived);
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
        uint256 amount = (msg.value * buyPrice);
        if (this.balanceOf(address(this)) >= amount) {
            _transfer(address(this), msg.sender, amount);
        } else {
            require(mintActived);
            _mint(msg.sender, amount);
        }
    }
    
    function buyTo(address to) payable public {
        require(buyActived);
        uint256 amount = (msg.value * buyPrice);
        if (this.balanceOf(address(this)) >= amount) {
            _transfer(address(this), to, amount);
        } else {
            require(mintActived);
            _mint(to, amount);
        }
    }
    
    function sell(uint256 amountSell) public {
        require(sellActived);
        address account = payable(address(this));
        uint256 amount = (amountSell / sellPrice);
        require(account.balance >= amount);
        _transfer(msg.sender, account, amountSell);
        payable(msg.sender).transfer(amount);
    }
}
