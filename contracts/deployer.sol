pragma solidity ^0.6.8;

interface IFlusher {
  function init(address, address) external;
}

contract Deployer {

  event LogNewFlusher(
    address indexed owner,
    address proxy,
    address indexed logic,
    address indexed token
  );

  /**
    * @dev deploy create2 + minimal proxy
    * @param owner owner address used for salt
    * @param logic flusher contract address
    * @param token token address
  */
  function deploy(address owner, address logic, address token) public returns (address proxy) {
    bytes32 salt = keccak256(abi.encodePacked(owner));
    bytes20 targetBytes = bytes20(logic);
    // solium-disable-next-line security/no-inline-assembly
    assembly {
        let clone := mload(0x40)
        mstore(
            clone,
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
        )
        mstore(add(clone, 0x14), targetBytes)
        mstore(
            add(clone, 0x28),
            0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
        )
        proxy := create2(0, clone, 0x37, salt)
    }
    IFlusher(proxy).init(owner, token);

    emit LogNewFlusher(owner, proxy, logic, token);
  }

  /**
    * @dev compute create2 + minimal proxy address
    * @param owner owner address used for salt
    * @param logic flusher contract address
  */
  function getAddress(address owner, address logic) public view returns (address) {
    bytes32 codeHash = keccak256(getCreationCode(logic));
    bytes32 salt = keccak256(abi.encodePacked(owner));
    bytes32 rawAddress = keccak256(
      abi.encodePacked(
        bytes1(0xff),
        address(this),
        salt,
        codeHash
      ));
      return address(bytes20(rawAddress << 96));
  }
  
  function getCreationCode(address logic) public pure returns (bytes memory) {
    bytes20 a = bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73);
    bytes20 b = bytes20(logic);
    bytes15 c = bytes15(0x5af43d82803e903d91602b57fd5bf3);
    return abi.encodePacked(a, b, c);
  }
}