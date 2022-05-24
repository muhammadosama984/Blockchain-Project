//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract auction {
    address public owner;
    uint256 public auctionEndTime;
    address withdrawAdress;
    uint256 withdrawValue;

    address public highestBidder;
    uint256 public highestBid = 0;
    uint256 public bidincrement;

    mapping(address => uint256) public BiddersToBids;
    bool isCancel = false;
    bool ownerHasWithdrawn;
    event HighestBidIncrease(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event AuctionCanceled();

    // contructor take 2 parameters which are end time of this auction and secondly, fixed bidincrement
    constructor(uint256 _bidincrement, uint256 _auctionEndTime) {
        bidincrement = _bidincrement; //_bidincrement;
        auctionEndTime = block.timestamp + _auctionEndTime; //_auctionEndTime;
        owner = msg.sender; // a person who call this contract
    }

    // function is used by various addresses to put their bids for this auction.
    function placebid(uint256 _value) public payable returns (bool) {
        // 3 conditions require to perform this functions
        // Firstly, auction must not be cancelled by the owner.
        // Secondly, time must not been past by the end time
        // last, value that is being placed must be greater than the previous highest bid as no
        // place lower bid in auction
        require(!isCancel);
        require(block.timestamp < auctionEndTime);
        require(_value > highestBid);

        // to get the last highest bid recorded
        uint256 currentHighestBid = BiddersToBids[highestBidder];
        BiddersToBids[msg.sender] = BiddersToBids[msg.sender] + _value;

        // the person who is placing the bid have less bid than the highestbid which is more than bidincrement
        if (BiddersToBids[msg.sender] <= currentHighestBid) {
            if (BiddersToBids[msg.sender] + bidincrement < currentHighestBid) {
                highestBid = BiddersToBids[msg.sender] + bidincrement;
            } else {
                highestBid = currentHighestBid;
            }
        } else {
            // the bid is place other than the owner himself
            if (msg.sender != highestBidder) {
                highestBidder = msg.sender;
                if (
                    BiddersToBids[msg.sender] < currentHighestBid + bidincrement
                ) {
                    highestBid = BiddersToBids[msg.sender];
                } else {
                    highestBid = currentHighestBid + bidincrement;
                }
            }
            currentHighestBid = BiddersToBids[msg.sender];
        }

        return true;
    }

    // simple function only be called by the owner to cancel the auction in the middle
    function cancelAuction() external {
        require(msg.sender == owner);
        isCancel = true;
        emit AuctionCanceled();
    }

    // function used by all addresses to withdraw the money which is not the highest bid.
    function withdraw() public returns (bool) {
        require(isCancel || block.timestamp > auctionEndTime);

        // this if condition will perform when auction is cancelled by the owner himself in the middle
        if (isCancel == true) {
            withdrawAdress = msg.sender;
            withdrawValue = BiddersToBids[withdrawAdress];
        }
        // when time has been past
        // the auction finished without being canceled
        else {
            if (msg.sender == owner) {
                // the auction's owner should be allowed to withdraw the highestBindingBid
                withdrawAdress = highestBidder;
                withdrawValue = highestBid;
                ownerHasWithdrawn = true;
            } else if (msg.sender == highestBidder) {
                // the highest bidder should only be allowed to withdraw the difference between their
                // highest bid and the highestBindingBid
                withdrawAdress = highestBidder;
                if (ownerHasWithdrawn) {
                    withdrawValue = BiddersToBids[highestBidder];
                } else {
                    withdrawValue = BiddersToBids[highestBidder] - highestBid;
                }
            } else {
                // in this a person who lost the auction can take out their amount
                withdrawAdress = msg.sender;
                withdrawValue = BiddersToBids[withdrawAdress];
            }
        }
        // if there is not value to withdraw to end this function
        // it could be if someone again call withdraw after withdrawing earlier
        if (withdrawValue == 0) revert();
        BiddersToBids[withdrawAdress] =
            BiddersToBids[withdrawAdress] -
            withdrawValue;
        return true;
    }
}
