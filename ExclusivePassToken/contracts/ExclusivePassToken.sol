// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ExclusivePassToken is ERC20 {
    address public organizer;
    uint256 public maxAttendees;
    uint256 public totalAttendees;
    uint256 public tokenPrice; // Price per token in wei

    // Mapping to keep track of whether a token has been used or not
    mapping(address => bool) public hasAttended;

    event TokenPurchased(address indexed buyer, uint256 amount, uint256 totalPrice);
    event AttendanceRecorded(address indexed attendee);
    event PriceUpdated(uint256 newPrice);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxAttendees,
        uint256 _tokenPrice
    ) ERC20(_name, _symbol) {
        organizer = msg.sender;
        maxAttendees = _maxAttendees;
        tokenPrice = _tokenPrice;
    }

    // Modifier to restrict access to the organizer only
    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Solo un organizzatore puo eseguire questa azione");
        _;
    }

    // Function to allow organizer to update the token price
    function updateTokenPrice(uint256 _newPrice) external onlyOrganizer {
        tokenPrice = _newPrice;
        emit PriceUpdated(_newPrice);
    }

    // Function to allow purchase of tokens
    function purchaseTokens(uint256 _amount) external payable {
        uint256 totalPrice = _amount * tokenPrice;
        require(totalSupply() + _amount <= maxAttendees, "Superato il numero massimo di partecipanti");
        require(msg.value == totalPrice, "Importo inviato non corretto");

        _mint(msg.sender, _amount);
        totalAttendees += _amount;

        emit TokenPurchased(msg.sender, _amount, totalPrice);
    }

    // Function to record attendance and burn token
    function recordAttendance() external {
        require(balanceOf(msg.sender) > 0, "Nessun token posseduto");
        require(!hasAttended[msg.sender], "Token utilizzato");

        hasAttended[msg.sender] = true;
        totalAttendees--;

        _burn(msg.sender, 1);

        emit AttendanceRecorded(msg.sender);
    }

    // Function to withdraw funds (only available to organizer)
    function withdrawFunds() external onlyOrganizer {
        payable(organizer).transfer(address(this).balance);
    }

    // Function to get the number of available seats
    function getAvailableSeats() external view returns (uint256) {
        return maxAttendees - totalAttendees;
    }

    // Function to get the number of tickets sold
    function getTicketsSold() external view returns (uint256) {
        return totalAttendees;
    }

    // Function to get the total amount accumulated
    function getTotalAccumulated() external view returns (uint256) {
        return totalAttendees * tokenPrice;
    }
}