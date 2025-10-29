// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SafeProof {
    //  Structure to hold product info
    struct Product {
        uint256 id;
        string name;
        address manufacturer;
        address currentOwner;
        uint256 warrantyPeriod; // in seconds
        uint256 purchaseDate;
        bool registered;
    }

    //  Mappings to track products
    mapping(uint256 => Product) public products;

    //  Manufacturer address
    address public manufacturer;

    //  Events for blockchain logs
    event ProductRegistered(uint256 productId, string name, uint256 warrantyPeriod);
    event OwnershipTransferred(uint256 productId, address from, address to);

    //  Constructor to set manufacturer
    constructor() {
        manufacturer = msg.sender;
    }

    //  Register new product (only manufacturer)
    function registerProduct(
        uint256 _id,
        string memory _name,
        uint256 _warrantyPeriod
    ) public {
        require(msg.sender == manufacturer, "Only manufacturer can register");
        require(!products[_id].registered, "Product already exists");

        products[_id] = Product({
            id: _id,
            name: _name,
            manufacturer: manufacturer,
            currentOwner: manufacturer,
            warrantyPeriod: _warrantyPeriod,
            purchaseDate: block.timestamp,
            registered: true
        });

        emit ProductRegistered(_id, _name, _warrantyPeriod);
    }

    //  Transfer ownership
    function transferOwnership(uint256 _id, address _newOwner) public {
        require(products[_id].registered, "Product not found");
        require(msg.sender == products[_id].currentOwner, "You are not the owner");
        require(_newOwner != address(0), "Invalid address");

        address previousOwner = products[_id].currentOwner;
        products[_id].currentOwner = _newOwner;

        emit OwnershipTransferred(_id, previousOwner, _newOwner);
    }

    //  Check if warranty is valid
    function isWarrantyValid(uint256 _id) public view returns (bool) {
        require(products[_id].registered, "Product not found");
        Product memory p = products[_id];
        return (block.timestamp <= p.purchaseDate + p.warrantyPeriod);
    }

    //  Get product info
    function getProductInfo(uint256 _id)
        public
        view
        returns (string memory, address, bool)
    {
        require(products[_id].registered, "Product not found");
        Product memory p = products[_id];
        bool warrantyValid = isWarrantyValid(_id);
        return (p.name, p.currentOwner, warrantyValid);
    }
}
