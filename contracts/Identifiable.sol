contract Identifiable {

    address private creator;

    address public owner;

    /**
   * @dev The Identifiable constructor sets the original `creator` of the contract to the sender
   * account.
   */
    function Identifiable() {
        creator = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyCreator() {
        require(msg.sender == creator);
        _;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getCreator() public view returns (address) {
        return creator;
    }
}