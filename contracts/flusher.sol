pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

interface IERC20 {
  function balanceOf(address) external view returns (uint);
  function allowance(address, address) external view returns (uint256);
  function approve(address, uint256) external;
}

interface YieldPool {
  function baseToken() external view returns (address);
  function balanceOf(address) external view returns (uint);
  function deposit(uint) external returns (uint);
  function withdraw(uint, address) external returns (uint);
}

interface ManagerInterface {
  function managers(address) external view returns (bool);
}

contract Flusher {

  address payable public owner;

  function deposit(address poolToken) public {
    require(address(poolToken) != address(0), "invalid-token");

    YieldPool poolContract = YieldPool(poolToken);
    IERC20 tokenContract = IERC20(poolContract.baseToken());

    if (address(tokenContract) == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {
      payable(poolToken).transfer(address(this).balance);
    } else {
      if (tokenContract.allowance(address(this), address(poolContract)) == 0)
        tokenContract.approve(address(poolContract), uint(-1));
      poolContract.deposit(tokenContract.balanceOf(address(this)));
    }

  }

  function withdraw(uint amount, address poolToken) external returns (uint) {

    ManagerInterface IManager = ManagerInterface(0x0000000000000000000000000000000000000000);
    require(IManager.managers(msg.sender), "not-manager");

    YieldPool poolContract = YieldPool(poolToken);
    uint poolBalance = poolContract.balanceOf(address(this));
    if (amount > poolBalance) amount = poolBalance;
    return poolContract.withdraw(amount, owner);

  }

  function init(address _owner, address _token) external {
    owner = payable(_owner);
    deposit(_token);
  }

}